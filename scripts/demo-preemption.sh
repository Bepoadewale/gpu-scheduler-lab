#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

low_is_admitted() {
  kubectl_lab get workload low-priority-borrower -n team-research -o jsonpath='{.status.admission.clusterQueue}' | grep -qx research-cq
}
low_is_preempted() {
  kubectl_lab get workload low-priority-borrower -n team-research -o jsonpath='{.status.conditions[?(@.type=="Preempted")].status}' | grep -qx True
}
high_is_admitted() {
  kubectl_lab get workload production-reclaim -n team-inference -o jsonpath='{.status.admission.clusterQueue}' | grep -qx inference-cq
}

kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-research --ignore-not-found
kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-inference --ignore-not-found

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata: {name: low-priority-borrower, namespace: team-research}
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
              resources: {requests: {example.com/simulated-gpu: "4"}}
EOF
wait_for "low-priority borrowed workload admission" low_is_admitted

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata: {name: production-reclaim, namespace: team-inference}
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
              resources: {requests: {example.com/simulated-gpu: "2"}}
EOF
wait_for "Kueue reclaim preemption" low_is_preempted
kubectl_lab get workload low-priority-borrower -n team-research -o jsonpath='{.status.conditions[?(@.type=="Preempted")].message}'
printf '\n'

# Direct Workload fixtures have no controller to remove evicted Pods, so cleanup
# releases their synthetic reservation before verifying the high-priority admission.
kubectl_lab delete workload low-priority-borrower -n team-research --wait=true
wait_for "production workload admission after reclaim" high_is_admitted
kubectl_lab get workloads.kueue.x-k8s.io -A -o wide
printf 'demo-preemption: Kueue recorded cohort reclaim preemption and admitted the protected workload\n'
