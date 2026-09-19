# Project Status

## Current Maturity

FOUNDATION

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

## Last Validation

- `PYTHONPATH=scheduler-lab/src ../ai-platform-control-plane/.venv/bin/python -m pytest -q`: 4 passed.
- `../ai-platform-control-plane/.venv/bin/python -m ruff check scheduler-lab/src tests`: passed.

## Last Updated

2026-09-19, baseline `9dc250f`.
