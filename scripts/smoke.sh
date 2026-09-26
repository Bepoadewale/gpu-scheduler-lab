#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

kubectl_lab get nodes >/dev/null
kubectl_lab -n kueue-system rollout status deployment/kueue-controller-manager --timeout=30s
kubectl_lab -n volcano-system rollout status deployment/volcano-scheduler --timeout=30s
kubectl_lab get clusterqueues research-cq inference-cq
kubectl_lab get localqueues -A
printf 'smoke: kind, Kueue, Volcano, and simulated accelerator queues are ready\n'
