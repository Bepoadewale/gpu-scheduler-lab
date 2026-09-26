#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

admission_is_empty() {
  test -z "$(kubectl_lab get workload inference-blocked -n team-inference -o jsonpath='{.status.admission.clusterQueue}')"
}

inference_is_admitted() {
  kubectl_lab get workload inference-blocked -n team-inference -o jsonpath='{.status.admission.clusterQueue}' | grep -qx inference-cq
}

kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-research --ignore-not-found
kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-inference --ignore-not-found

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata:
  name: research-borrower
  namespace: team-research
spec:
  queueName: research
  priority: 0
  podSets:
    - name: main
      count: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: work
              image: registry.k8s.io/pause:3.10
              resources:
                requests:
                  example.com/simulated-gpu: "4"
EOF

wait_for "research workload admission" kubectl_lab get workload research-borrower -n team-research -o jsonpath='{.status.admission.clusterQueue}' | grep -qx research-cq
cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata:
  name: inference-blocked
  namespace: team-inference
spec:
  queueName: inference
  priority: 100
  podSets:
    - name: main
      count: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: work
              image: registry.k8s.io/pause:3.10
              resources:
                requests:
                  example.com/simulated-gpu: "3"
EOF

wait_for "inference workload pending" admission_is_empty
log "Quota exhaustion observed: inference workload is pending while research has borrowed simulated capacity"
kubectl_lab get workloads.kueue.x-k8s.io -A
kubectl_lab get clusterqueues research-cq inference-cq -o wide

log "Releasing borrowed quota and observing pending workload admission"
kubectl_lab delete workload research-borrower -n team-research --wait=true
wait_for "inference workload admission after release" inference_is_admitted
kubectl_lab get workloads.kueue.x-k8s.io -A
printf 'demo-kueue: borrowing, quota exhaustion, and admission-after-release executed using simulated accelerator quota\n'
