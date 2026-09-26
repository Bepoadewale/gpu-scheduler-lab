# GPU Scheduler Lab — Agent Guide

Mission: demonstrate scheduler policy and actual local Kubernetes queue behavior without claiming physical GPU performance.

Stack: Python 3.12 simulator, kind, Kueue/Volcano and Kubernetes manifests.

Commands: `make install`, `make bootstrap-local`, `make smoke`, `make demo-kueue`,
`make demo-fair-share`, `make demo-preemption`, `make demo-starvation`, `make demo-gang`,
`make verify`, and `make clean-local`. The current pinned local integrations are Kueue `v0.19.6`
and Volcano `v1.12.0`; re-validate version compatibility before changing them.

Rules: simulated extended resources are not GPUs; keep the simulator as a what-if tool, verify scheduler behavior with integration tests, no secrets/main pushes, and update status/backlog honestly.

Completion rule: do not mark **PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE** unless the gate in `DEFINITION_OF_DONE.md` has executed evidence. Simulator output, manifests, and unit tests do not establish real scheduler behavior. Kueue/Volcano experiments must run on local Kubernetes with simulated resources explicitly labeled; real GPU hardware remains a separate boundary.

## Clean-room reproducibility

Clean-room reproducibility is a mandatory completion criterion. Do not mark this repository
`PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE` until a new engineer can reproduce the platform from a
clean project state using documented commands, execute the primary and required failure demos, run
validation, and safely tear down only this project's local resources. Do not infer reproducibility
from an existing developer environment; execute it after project-specific cleanup.
