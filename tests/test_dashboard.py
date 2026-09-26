from gpulab.dashboard import collect_snapshot, render_dashboard


def test_collect_snapshot_uses_real_resource_shapes() -> None:
    payloads = {
        "get nodes": {"items": [{"metadata": {"name": "worker", "labels": {}}, "status": {"conditions": [{"type": "Ready", "status": "True"}]}}]},
        "get clusterqueues.kueue.x-k8s.io": {"items": [{"metadata": {"name": "research-cq"}, "spec": {"cohort": "shared"}, "status": {"pendingWorkloads": 2, "admittedWorkloads": 1, "conditions": [{"type": "Active", "status": "True"}]}}]},
        "get localqueues.kueue.x-k8s.io -A": {"items": []},
        "get workloads.kueue.x-k8s.io -A": {"items": [{"metadata": {"namespace": "team-a", "name": "pending-work"}, "spec": {"queueName": "research"}, "status": {"conditions": [{"type": "Admitted", "status": "False"}]}}]},
        "get podgroups.scheduling.volcano.sh -A": {"items": [{"metadata": {"namespace": "volcano-lab", "name": "successful-gang"}, "spec": {"minMember": 2}, "status": {"phase": "Running", "running": 2}}]},
        "get pods -A": {"items": [{"metadata": {"namespace": "volcano-lab", "name": "successful-gang-a"}, "spec": {"nodeName": "worker"}, "status": {"phase": "Running"}}]},
    }

    def run(arguments: list[str]) -> dict:
        return payloads[" ".join(arguments)]

    snapshot = collect_snapshot(run)
    assert snapshot["cluster_queues"] == [{"name": "research-cq", "cohort": "shared", "active": "True", "pending": 2, "admitted": 1}]
    assert snapshot["pod_groups"][0]["running"] == 2
    assert snapshot["gang_pods"][0]["phase"] == "Running"


def test_dashboard_marks_simulated_hardware_and_real_state() -> None:
    page = render_dashboard({"generated_at": "2026-09-26T00:00:00+00:00", "nodes": [], "cluster_queues": [], "local_queues": [], "workloads": [], "pod_groups": [], "gang_pods": []})
    assert "SIMULATED HARDWARE" in page
    assert "real kind, Kueue and Volcano state" in page
