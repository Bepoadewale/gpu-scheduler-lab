# GPU Scheduler Lab — Agent Guide

Mission: demonstrate scheduler policy and actual local Kubernetes queue behavior without claiming physical GPU performance.

Stack: Python 3.12 simulator, kind, Kueue/Volcano and Kubernetes manifests.

Commands: `make test`, `make lint`, `make demo-borrow`; future commands must validate current Kueue/Volcano versions before use.

Rules: simulated extended resources are not GPUs; keep the simulator as a what-if tool, verify scheduler behavior with integration tests, no secrets/main pushes, and update status/backlog honestly.
