#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="gpu-scheduler-lab"
KUEUE_VERSION="v0.19.6"
VOLCANO_VERSION="v1.12.0"

log() { printf '\n==> %s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"; }
wait_for() {
  local description="$1"; shift
  local attempts=0
  until "$@"; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 60 ]; then
      fail "timed out waiting for ${description}"
    fi
    sleep 2
  done
}

retry() {
  local description="$1"; shift
  local attempts=0
  until "$@"; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 8 ]; then
      fail "failed after retries: ${description}"
    fi
    sleep 2
  done
}

kubectl_lab() { kubectl --context "kind-${CLUSTER_NAME}" "$@"; }

load_kind_image() {
  local image="$1"
  docker pull "$image" >/dev/null
  local node
  while IFS= read -r node; do
    # Docker Desktop can expose a multi-platform OCI index that `kind load`
    # tries to import in full. Importing the selected local image into each
    # project node avoids that metadata issue while retaining a normal pull
    # fallback for a first-time engineer.
    docker save "$image" | docker exec -i "$node" ctr --namespace=k8s.io images import --digests --snapshotter=overlayfs - >/dev/null
  done < <(kind get nodes --name "$CLUSTER_NAME")
}
