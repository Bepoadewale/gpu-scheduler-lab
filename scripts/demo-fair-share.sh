#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

research_is_admitted() {
  kubectl_lab get workload research-share -n team-research -o jsonpath='{.status.admission.clusterQueue}' | grep -qx research-cq
}
inference_is_admitted() {
  kubectl_lab get workload inference-share -n team-inference -o jsonpath='{.status.admission.clusterQueue}' | grep -qx inference-cq
}

research_has_share() {
  test -n "$(kubectl_lab get clusterqueue research-cq -o jsonpath='{.status.fairSharing.weightedShare}')"
}

inference_has_share() {
  test -n "$(kubectl_lab get clusterqueue inference-cq -o jsonpath='{.status.fairSharing.weightedShare}')"
}

kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-research --ignore-not-found
kubectl_lab delete workloads.kueue.x-k8s.io --all -n team-inference --ignore-not-found

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata: {name: research-share, namespace: team-research}
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
              resources: {requests: {example.com/simulated-gpu: "3"}}
EOF
wait_for "research fair-share workload admission" research_is_admitted

cat <<'EOF' | kubectl_lab apply -f -
apiVersion: kueue.x-k8s.io/v1beta2
kind: Workload
metadata: {name: inference-share, namespace: team-inference}
spec:
  queueName: inference
  podSets:
    - name: main
      count: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: work
              image: registry.k8s.io/pause:3.10
              resources: {requests: {example.com/simulated-gpu: "1"}}
EOF
wait_for "inference fair-share workload admission" inference_is_admitted

# The configured controller records the weighted shares for the borrowing cohort.
wait_for "research weighted-share status" research_has_share
wait_for "inference weighted-share status" inference_has_share
kubectl_lab get clusterqueue research-cq inference-cq -o jsonpath='{range .items[*]}{.metadata.name}{" weight="}{.spec.fairSharing.weight}{" weightedShare="}{.status.fairSharing.weightedShare}{"\n"}{end}'
printf 'demo-fair-share: Kueue fair-sharing configuration and weighted-share status executed for the cohort\n'
