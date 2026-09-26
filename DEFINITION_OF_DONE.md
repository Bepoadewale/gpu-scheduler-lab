# Definition of Done

# Portfolio Complete — Local-First Scope Gate

- [x] kind runs locally with simulated extended GPU quota explicitly labeled as simulated hardware.
- [x] Current Kueue runs actual ResourceFlavor, ClusterQueue, LocalQueue, Workload, and cohort-linked admission behavior.
- [x] Quota admission/exhaustion, borrowing, fair sharing, priority/reclaim preemption, and starvation experiments record Kubernetes state evidence.
- [x] Volcano runs real PodGroup/gang scheduling; feasible members schedule and an impossible gang remains pending.
- [x] Topology/fragmentation is explicitly limited to the simulator; no scheduler-visible topology placement is claimed.
- [x] Simulator remains a what-if/capacity companion and is not used as proof of Kubernetes scheduler behavior.
- [x] Scheduler/admission command reports capture Kubernetes object state and preemption condition evidence.
- [ ] Reproducible demo, unit/integration/E2E/failure tests, teardown, and CI are green (local suite and two clean-room cycles passed; Week 8 GitHub Actions is pending).
- [x] README/status clearly separate simulated resources from real GPU hardware and performance.

## Maturity Levels

- **FOUNDATION:** simulator/architecture exists.
- **PARTIALLY VALIDATED:** at least one real scheduler integration runs, but experiment set is incomplete.
- **LOCAL END-TO-END VALIDATED:** primary scheduling story runs with material experiment/recovery evidence remaining.
- **PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE:** every gate is executed locally; no real-GPU implication is made.

# Clean-Room Reproducibility Gate

`PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE` requires two executed clean-room cycles: clone → install → bootstrap kind, simulated GPU resources, Kueue, retained Volcano → smoke → quota/fair-share/preemption demo → gang or starvation scenario → validation → project-scoped cleanup → second clean bootstrap/demo. Planned commands: `make install`, `make bootstrap-local`, `make smoke`, `make demo-kueue`, `make demo-gang`, `make verify`, `make clean-local`.

- [x] Clean bootstrap has no hidden project state; primary and failure demos passed twice.
- [x] Cleanup removes only this project’s named kind cluster; it does not issue Docker/Kubernetes-wide deletion commands.
- [x] Post-cleanup absence and second bootstrap/demo are recorded in `docs/VALIDATION.md`.
