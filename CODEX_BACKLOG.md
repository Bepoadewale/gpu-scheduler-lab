# Completion Target

PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE

# Current Completion Blockers

- Pass the full two-cycle clean-room reproducibility gate and record the exact evidence.
- Obtain a green `kind-integration` GitHub Actions result for the pinned local stack.

# P0 — Required for Portfolio Claim

P0 blocks PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE; do not select P1/P2 work first.

- Execute and record two clean-room cycles using `make cleanroom-validate`.
- Fix any Week 8 `kind-integration` CI failure without weakening validation.

# P1 — Production Hardening

- Add richer scheduler metric scraping/report artefacts beyond the command-level Kubernetes evidence.
- Explore scheduler-visible topology-aware placement only with a clear local capability and test design.

# P2 — Enhancements

- Comparative experiment reports and additional queueing-policy scenarios.

# P3 — Future / Cloud / Hardware

- Real GPU fleet, MIG, NVLink, RDMA and production scheduler benchmarks.
# Clean-Room Completion Blocker

- [ ] Pass the full clean-room reproducibility gate: deterministic bootstrap, smoke, Kueue and gang-scheduling demos, safe cleanup, a second clean bootstrap, and recorded evidence. Break this into focused P0 work only during the scheduled week.
