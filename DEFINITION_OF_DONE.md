# Definition of Done

# Portfolio Complete — Local-First Scope Gate

- [ ] kind or equivalent local Kubernetes runs with simulated extended GPU resources explicitly labeled as simulated hardware.
- [ ] Current supported Kueue runs actual ResourceFlavor, ClusterQueue, LocalQueue, Workload, and relevant Cohort admission behavior.
- [ ] Reproducible quota admission/exhaustion, borrowing, fair sharing, priority, preemption/reclaim, and starvation experiments record Kubernetes state evidence.
- [ ] Volcano runs actual PodGroup/gang scheduling if it remains part of the repository claim; all-or-none behavior is observed.
- [ ] Heterogeneous simulated classes and topology/fragmentation consequences are scheduler-visible where claimed.
- [ ] Simulator remains a what-if/capacity companion and is not used as proof of Kubernetes scheduler behavior.
- [ ] Scheduler/admission experiment metrics or reports are captured where practical.
- [ ] Reproducible demo, unit/integration/E2E/failure tests, teardown, and CI are green.
- [ ] README/status clearly separate simulated resources from real GPU hardware and performance.

## Maturity Levels

- **FOUNDATION:** simulator/architecture exists.
- **PARTIALLY VALIDATED:** at least one real scheduler integration runs, but experiment set is incomplete.
- **LOCAL END-TO-END VALIDATED:** primary scheduling story runs with material experiment/recovery evidence remaining.
- **PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE:** every gate is executed locally; no real-GPU implication is made.

# Clean-Room Reproducibility Gate

`PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE` requires two executed clean-room cycles: clone → install → bootstrap kind, simulated GPU resources, Kueue, retained Volcano → smoke → quota/fair-share/preemption demo → gang or starvation scenario → validation → project-scoped cleanup → second clean bootstrap/demo. Planned commands: `make install`, `make bootstrap-local`, `make smoke`, `make demo-kueue`, `make demo-gang`, `make verify`, `make clean-local`.

- [ ] Clean clone/bootstrap has no hidden state; primary and failure demos pass.
- [ ] Cleanup removes only this project and unrelated resources survive.
- [ ] Post-cleanup absence and second bootstrap/demo are recorded in `docs/VALIDATION.md`.
