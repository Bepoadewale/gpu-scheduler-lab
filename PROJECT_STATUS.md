# Project Status

## Current Maturity

FOUNDATION

## Maturity Model

`FOUNDATION` → `PARTIALLY VALIDATED` → `LOCAL END-TO-END VALIDATED` → `PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE`.

## Executed and Verified

- Offline quota/borrowing/fair-share/gang/fragmentation simulator tests.

## Implemented but Not End-to-End Validated

- Kueue queue manifest placeholder.

## Simulated

- All accelerator capacity and scheduling behavior.

## Architecture / Contracts Only

- kind, Kueue, Volcano, preemption and topology experiments.

## Known Failures

- GitHub CI rerun pending after changing the initialization workflow to install test tooling without packaging metadata directories.

## Current P0 Objective

Install current Kueue in kind and prove one LocalQueue/ClusterQueue admission experiment.

## Completion Blockers

- No kind/Kueue/Volcano runtime or actual Workload admission experiment has executed.
- Quota, borrowing, fair-share, priority/preemption, starvation, gang, and scheduler evidence are simulated only.

## Explicitly Unexecuted Production Adapters

- Physical GPU fleet, MIG, NVLink, RDMA, real accelerator performance, and production scheduler benchmarks.

## Last Validation

- `PYTHONPATH=scheduler-lab/src ../ai-platform-control-plane/.venv/bin/python -m pytest -q`: 4 passed.
- `../ai-platform-control-plane/.venv/bin/python -m ruff check scheduler-lab/src tests`: passed.

## Last Updated

2026-09-19, baseline `9dc250f`.

## Clean-Room Reproducibility

**Status: NOT YET VALIDATED**

Completion requires two executed clean-room cycles: clean start → bootstrap → smoke → primary demo
→ failure/security demo → validation → project-scoped cleanup, followed by a second clean bootstrap
and demo. Existing developer state is not evidence. This status must be `VALIDATED` before
`PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE` is allowed.
