# Validation

## Local integration evidence

Date: 2026-09-26
Working branch: `codex/week-08-gpu-scheduler-lab` (before final commit)
Environment: macOS on Docker Desktop `29.0.1`; kind Kubernetes node `v1.34.0`; kubectl client `v1.34.1`; Kueue `v0.19.6`; Volcano `v1.12.0`; Python `3.14`.

The local cluster was named `gpu-scheduler-lab`. Its `example.com/simulated-gpu` quantity was Kueue quota accounting only. No Kubernetes node advertised a GPU and no accelerator-performance result was collected.

Commands executed:

```bash
make install
make bootstrap-local
make smoke
make demo-kueue
make demo-fair-share
make demo-preemption
make demo-starvation
make demo-gang
make verify
make clean-local
```

Observed results:

- Kueue admitted a four-unit research borrower, left a three-unit inference request pending while quota was exhausted, then admitted it after the borrower was released.
- Kueue recorded fair-share weighted-status fields for cohort queues.
- Kueue produced a `Preempted` condition for a low-priority borrower and admitted the protected inference workload after reservation release.
- Kueue `BestEffortFIFO` admitted a later two-unit workload while an earlier impossible five-unit workload remained pending.
- Volcano scheduled both feasible PodGroup members. Both infeasible gang members remained `Pending`; scheduler events identified the gang as not ready/unschedulable.
- `make verify`: Ruff passed; pytest passed (`4 passed`).

## Clean-Room Validation

Status: **VALIDATED**

Two complete project-scoped cycles were executed on 2026-09-26 from no existing `gpu-scheduler-lab` kind cluster:

1. `make clean-local` → `make install` → `make bootstrap-local` → `make smoke` → all five real scheduler demos → `make verify` → `make clean-local`.
2. A second clean `make bootstrap-local` → `make smoke` → all five real scheduler demos → `make verify` → `make clean-local`.

For both cycles, post-cleanup verification confirmed:

```bash
kind get clusters                 # no gpu-scheduler-lab cluster
docker ps --format '{{.Names}}'  # no gpu-scheduler-lab-* containers
```

The bootstrap preloads the pinned controller images into only the project kind nodes. This avoids a Docker Desktop multi-platform image-import issue while preserving normal first-run `docker pull` behaviour. It does not depend on a pre-existing cluster, database, Kubernetes CRD, or manually created queue.

## CI validation

GitHub Actions runs [`36223123276`](https://github.com/Bepoadewale/gpu-scheduler-lab/actions/runs/36223123276) and [`36228218616`](https://github.com/Bepoadewale/gpu-scheduler-lab/actions/runs/36228218616) passed on 2026-09-26. The latter verifies the Kueue-webhook readiness retry used before applying Volcano.

- `validate` passed Ruff and pytest.
- `kind-integration` passed `make install`, `make bootstrap-local`, `make smoke`, all five real scheduler demos, `make verify`, and always-on `make clean-local`.
