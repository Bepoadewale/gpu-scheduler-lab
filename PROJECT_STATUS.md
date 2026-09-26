# Project Status

## Current Maturity

LOCAL END-TO-END VALIDATED

## Maturity Model

`FOUNDATION` → `PARTIALLY VALIDATED` → `LOCAL END-TO-END VALIDATED` → `PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE`.

## Executed and Verified

- Offline quota/borrowing/fair-share/gang/fragmentation simulator tests.
- Docker Desktop `29.0.1`, kind Kubernetes `v1.34.0`, Kueue `v0.19.6`, and Volcano `v1.12.0` installed in a disposable local cluster.
- Kueue ResourceFlavor, cohort-linked ClusterQueues, and LocalQueues using `example.com/simulated-gpu` quota accounting.
- Kueue quota exhaustion, borrowing, release/re-admission, weighted fair-share status, cohort reclaim preemption, and BestEffortFIFO starvation avoidance.
- Volcano PodGroup success/failure: feasible gang members scheduled; infeasible gang members remained pending.

## Implemented but Not End-to-End Validated

- Clean-room automation and CI integration workflow are implemented but require the final two-cycle execution/CI evidence before completion can be claimed.

## Simulated

- Accelerator capacity labels and quantities (`example.com/simulated-gpu`).
- Offline topology/fragmentation analysis; it is not evidence of real scheduler-visible topology placement.

## Architecture / Contracts Only

- Real GPU fleet, MIG, NVLink, RDMA, physical accelerator placement and performance.

## Known Failures

- None known locally. GitHub Actions evidence is pending the Week 8 PR run.

## Current P0 Objective

Obtain a green Week 8 `kind-integration` CI run and prepare the review-ready PR.

## Completion Blockers

- Required GitHub Actions checks have not yet run for the Week 8 branch.

## Explicitly Unexecuted Production Adapters

- Physical GPU fleet, MIG, NVLink, RDMA, real accelerator performance, and production scheduler benchmarks.

## Last Validation

- `make demo-kueue`: passed (real Kueue quota exhaustion/borrowing/re-admission).
- `make demo-fair-share`: passed (weighted shares: research `500`, inference `0`).
- `make demo-preemption`: passed (Kueue recorded `Preempted` cohort reclaim).
- `make demo-starvation`: passed (fitting later workload admitted while impossible earlier workload stayed pending).
- `make demo-gang`: passed (Volcano scheduled feasible gang and kept infeasible gang pending).

## Last Updated

2026-09-26, Week 8 working branch (uncommitted at this point).

## Clean-Room Reproducibility

**Status: VALIDATED**

Two explicit clean start → bootstrap → smoke → primary/failure demos → validation → project-scoped cleanup cycles passed, including a second clean bootstrap. Exact commands and post-cleanup evidence are recorded in `docs/VALIDATION.md`.
