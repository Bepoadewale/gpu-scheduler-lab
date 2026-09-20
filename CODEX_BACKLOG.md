# Completion Target

PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE

# Current Completion Blockers

- Run Kueue queue/admission experiments in kind with explicitly simulated extended GPU resources.
- Execute borrowing/fair-share, priority/preemption/starvation, and Volcano gang scheduling evidence.

# P0 — Required for Portfolio Claim

P0 blocks PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE; do not select P1/P2 work first.

- Verify current Kueue compatibility and bootstrap kind.
- Create ResourceFlavor, ClusterQueue, LocalQueue and simulated GPU resource admission test.
- Add cohort borrowing/fair-share experiment with observed Kubernetes states.
- Add preemption experiment and validate expected statuses.
- Add Volcano gang experiment; retain simulator as companion.

# P1 — Production Hardening

- Repeatable teardown, metrics and topology/fragmentation test harness.

# P2 — Enhancements

- Comparative experiment reports.

# P3 — Future / Cloud / Hardware

- Real GPU fleet, MIG, NVLink, RDMA and production scheduler benchmarks.
# Clean-Room Completion Blocker

- [ ] Pass the full clean-room reproducibility gate: deterministic bootstrap, smoke, Kueue and gang-scheduling demos, safe cleanup, a second clean bootstrap, and recorded evidence. Break this into focused P0 work only during the scheduled week.
