#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

oversized_is_pending() {
  test -z "$(kubectl_lab get workload impossible-first -n team-research -o jsonpath='{.status.admission.clusterQueue}')"
}
small_is_admitted() {
  kubectl_lab get workload fitting-second -n team-research -o jsonpath='{.status.admission.clusterQueue}' | grep -qx research-cq
}

kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-research --ignore-not-found
kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-inference --ignore-not-found

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata: {name: impossible-first, namespace: team-research}
spec:
  queueName: research
  podSets:
    - name: main
      count: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: work
              image: registry.k8s.io/pause:3.10
              resources: {requests: {example.com/simulated-gpu: "5"}}
EOF
wait_for "oversized workload pending" oversized_is_pending

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata: {name: fitting-second, namespace: team-research}
spec:
  queueName: research
  podSets:
    - name: main
      count: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: work
              image: registry.k8s.io/pause:3.10
              resources: {requests: {example.com/simulated-gpu: "2"}}
EOF
wait_for "later fitting workload admission" small_is_admitted
kubectl_lab get workloads.kueue.x-k8s.io -n team-research -o wide
printf 'demo-starvation: BestEffortFIFO admitted a fitting later workload while an impossible earlier workload remained pending\n'
