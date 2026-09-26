# Kueue vs Volcano

Kueue manages admission, quota, cohorts, fair sharing, and preemption for Kubernetes workloads. Kubernetes then assigns Pods to nodes. Volcano adds batch/HPC features such as PodGroup gang scheduling. They overlap in queues and priority but solve different layers; this lab uses each only where it provides a distinct experiment.

The executed local split is deliberate:

- Kueue uses `example.com/simulated-gpu` as a **synthetic quota resource**. It validates control-plane admission behavior but is not associated with node hardware.
- Volcano schedules real Pods with ordinary CPU requests. It validates all-or-none gang behavior but does not imply GPU placement.
