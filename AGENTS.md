# GPU Scheduler Lab — Agent Guide

Mission: demonstrate scheduler policy and actual local Kubernetes queue behavior without claiming physical GPU performance.

Stack: Python 3.12 simulator, kind, Kueue/Volcano and Kubernetes manifests.

Commands: `make test`, `make lint`, `make demo-borrow`; future commands must validate current Kueue/Volcano versions before use.

Rules: simulated extended resources are not GPUs; keep the simulator as a what-if tool, verify scheduler behavior with integration tests, no secrets/main pushes, and update status/backlog honestly.

Completion rule: do not mark **PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE** unless the gate in `DEFINITION_OF_DONE.md` has executed evidence. Simulator output, manifests, and unit tests do not establish real scheduler behavior. Kueue/Volcano experiments must run on local Kubernetes with simulated resources explicitly labeled; real GPU hardware remains a separate boundary.

## Clean-room reproducibility

Clean-room reproducibility is a mandatory completion criterion. Do not mark this repository
`PORTFOLIO COMPLETE — LOCAL-FIRST SCOPE` until a new engineer can reproduce the platform from a
clean project state using documented commands, execute the primary and required failure demos, run
validation, and safely tear down only this project's local resources. Do not infer reproducibility
from an existing developer environment; execute it after project-specific cleanup.
