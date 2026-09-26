#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

pod_is_scheduled() {
  test -n "$(kubectl_lab get pod "$1" -n volcano-lab -o jsonpath='{.spec.nodeName}')"
}

kubectl_lab delete pod,podgroup --all -n volcano-lab --ignore-not-found --wait=true || true
kubectl_lab apply -f "$ROOT_DIR/platform/volcano/podgroups.yaml"
wait_for "successful gang pod A scheduled" pod_is_scheduled successful-gang-a
wait_for "successful gang pod B scheduled" pod_is_scheduled successful-gang-b

if kubectl_lab get pod blocked-gang-a -n volcano-lab -o jsonpath='{.spec.nodeName}' | grep -q .; then
  fail "blocked gang pod A unexpectedly scheduled"
fi
if kubectl_lab get pod blocked-gang-b -n volcano-lab -o jsonpath='{.spec.nodeName}' | grep -q .; then
  fail "blocked gang pod B unexpectedly scheduled"
fi
kubectl_lab get podgroup,pods -n volcano-lab
printf 'demo-gang: Volcano scheduled the satisfiable gang and kept the unsatisfiable gang pending\n'
