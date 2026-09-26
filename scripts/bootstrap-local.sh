#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

need docker; need kind; need kubectl; need curl
docker info >/dev/null || fail "Docker Desktop is not ready"

if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  log "Creating project-scoped kind cluster"
  kind create cluster --name "$CLUSTER_NAME" --config "$ROOT_DIR/config/kind/cluster.yaml" --wait 120s
fi

log "Waiting for Kubernetes nodes"
kubectl_lab wait --for=condition=Ready nodes --all --timeout=120s

log "Loading pinned controller images into project kind nodes"
load_kind_image "registry.k8s.io/kueue/kueue:${KUEUE_VERSION}"
load_kind_image "volcanosh/vc-scheduler:${VOLCANO_VERSION}"
load_kind_image "volcanosh/vc-controller-manager:${VOLCANO_VERSION}"
load_kind_image "volcanosh/vc-webhook-manager:${VOLCANO_VERSION}"

log "Installing Kueue ${KUEUE_VERSION}"
kubectl_lab apply --server-side -f "https://github.com/kubernetes-sigs/kueue/releases/download/${KUEUE_VERSION}/manifests.yaml"
kubectl_lab -n kueue-system rollout status deployment/kueue-controller-manager --timeout=180s
kubectl_lab apply -f "$ROOT_DIR/platform/kueue/manager-config.yaml"
kubectl_lab -n kueue-system rollout restart deployment/kueue-controller-manager
kubectl_lab -n kueue-system rollout status deployment/kueue-controller-manager --timeout=180s

log "Installing Volcano ${VOLCANO_VERSION}"
kubectl_lab apply -f "https://raw.githubusercontent.com/volcano-sh/volcano/${VOLCANO_VERSION}/installer/volcano-development.yaml"
wait_for "Volcano scheduler deployment" kubectl_lab -n volcano-system get deployment volcano-scheduler
kubectl_lab -n volcano-system rollout status deployment/volcano-scheduler --timeout=180s

log "Applying simulated accelerator queues"
kubectl_lab apply -f "$ROOT_DIR/platform/kueue/core.yaml"
kubectl_lab wait --for=jsonpath='{.status.conditions[?(@.type=="Active")].status}'=True clusterqueue/research-cq --timeout=120s
kubectl_lab wait --for=jsonpath='{.status.conditions[?(@.type=="Active")].status}'=True clusterqueue/inference-cq --timeout=120s

log "Bootstrap complete: all accelerator quantities are Kueue-only simulated resources"
