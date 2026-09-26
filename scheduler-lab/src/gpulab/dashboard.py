"""Read-only local dashboard for the real GPU Scheduler Lab kind cluster.

The dashboard deliberately reads Kubernetes API state on every refresh.  It is
not a simulator and does not report physical GPU utilisation: the Kueue
``example.com/simulated-gpu`` resource remains quota-accounting evidence only.
"""

from __future__ import annotations

import argparse
import json
import subprocess
from collections.abc import Callable
from datetime import UTC, datetime
from html import escape
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

KubectlRunner = Callable[[list[str]], dict[str, Any]]


def kubectl_json(arguments: list[str]) -> dict[str, Any]:
    """Return JSON from the project-scoped kind context or raise a useful error."""
    command = ["kubectl", "--context", "kind-gpu-scheduler-lab", *arguments, "-o", "json"]
    result = subprocess.run(command, text=True, capture_output=True, check=False, timeout=10)
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip() or "unknown kubectl error"
        raise RuntimeError(detail)
    return json.loads(result.stdout)


def _items(payload: dict[str, Any]) -> list[dict[str, Any]]:
    return list(payload.get("items", []))


def _condition(item: dict[str, Any], condition_type: str) -> str:
    for condition in item.get("status", {}).get("conditions", []):
        if condition.get("type") == condition_type:
            return str(condition.get("status", "Unknown"))
    return "Unknown"


def collect_snapshot(run: KubectlRunner = kubectl_json) -> dict[str, Any]:
    """Collect a compact, presentation-friendly view of actual cluster state."""
    nodes = _items(run(["get", "nodes"]))
    cluster_queues = _items(run(["get", "clusterqueues.kueue.x-k8s.io"]))
    local_queues = _items(run(["get", "localqueues.kueue.x-k8s.io", "-A"]))
    workloads = _items(run(["get", "workloads.kueue.x-k8s.io", "-A"]))
    pod_groups = _items(run(["get", "podgroups.scheduling.volcano.sh", "-A"]))
    pods = _items(run(["get", "pods", "-A"]))
    gang_pods = [
        {
            "name": item["metadata"]["name"],
            "phase": item.get("status", {}).get("phase", "Unknown"),
            "node": item.get("spec", {}).get("nodeName", "—"),
        }
        for item in pods
        if item["metadata"].get("namespace") == "volcano-lab"
        and item["metadata"]["name"].startswith(("successful-gang", "blocked-gang"))
    ]
    observed_gangs = []
    for item in pod_groups:
        namespace = item["metadata"].get("namespace", "default")
        name = item["metadata"]["name"]
        if namespace != "volcano-lab" or name not in {"successful-gang", "blocked-gang"}:
            continue
        members = [pod for pod in gang_pods if pod["name"].startswith(name)]
        minimum = item.get("spec", {}).get("minMember", 0)
        running = sum(pod["phase"] == "Running" for pod in members)
        observed_gangs.append(
            {
                "namespace": namespace,
                "name": name,
                "controller_phase": item.get("status", {}).get("phase", "Unknown"),
                "min_member": minimum,
                "observed_members": len(members),
                "observed_running": running,
                "outcome": "SATISFIED" if running >= minimum else "PENDING",
            }
        )

    return {
        "generated_at": datetime.now(UTC).isoformat(),
        "nodes": [
            {
                "name": item["metadata"]["name"],
                "ready": _condition(item, "Ready"),
                "roles": ", ".join(
                    key.removeprefix("node-role.kubernetes.io/")
                    for key in item.get("metadata", {}).get("labels", {})
                    if key.startswith("node-role.kubernetes.io/")
                )
                or "worker",
            }
            for item in nodes
        ],
        "cluster_queues": [
            {
                "name": item["metadata"]["name"],
                "cohort": item.get("spec", {}).get("cohort", "—"),
                "active": _condition(item, "Active"),
                "pending": item.get("status", {}).get("pendingWorkloads", 0),
                "admitted": item.get("status", {}).get("admittedWorkloads", 0),
            }
            for item in cluster_queues
        ],
        "local_queues": [
            {
                "namespace": item["metadata"].get("namespace", "default"),
                "name": item["metadata"]["name"],
                "cluster_queue": item.get("spec", {}).get("clusterQueue", "—"),
                "pending": item.get("status", {}).get("pendingWorkloads", 0),
                "admitted": item.get("status", {}).get("admittedWorkloads", 0),
            }
            for item in local_queues
        ],
        "workloads": [
            {
                "namespace": item["metadata"].get("namespace", "default"),
                "name": item["metadata"]["name"],
                "queue": item.get("spec", {}).get("queueName", "—"),
                "admitted": _condition(item, "Admitted"),
                "finished": _condition(item, "Finished"),
            }
            for item in workloads
        ],
        "pod_groups": observed_gangs,
        "gang_pods": gang_pods,
    }


def _table(headers: list[str], rows: list[list[object]]) -> str:
    header_html = "".join(f"<th>{escape(header)}</th>" for header in headers)
    row_html = "".join(
        "<tr>" + "".join(f"<td>{escape(str(value))}</td>" for value in row) + "</tr>"
        for row in rows
    ) or f"<tr><td colspan='{len(headers)}'>No current evidence. Run a demo to populate it.</td></tr>"
    return f"<table><thead><tr>{header_html}</tr></thead><tbody>{row_html}</tbody></table>"


def render_dashboard(snapshot: dict[str, Any] | None, error: str | None = None) -> str:
    """Render state server-side so screenshots retain useful evidence."""
    if error:
        content = f"<section class='error'><h2>Cluster unavailable</h2><pre>{escape(error)}</pre></section>"
    else:
        assert snapshot is not None
        queues = snapshot["cluster_queues"]
        content = "".join(
            [
                (
                    "<div class='cards'>"
                    f"<article><b>{len(snapshot['nodes'])}</b><span>kind nodes</span></article>"
                    f"<article><b>{sum(q['admitted'] for q in queues)}</b><span>admitted workloads</span></article>"
                    f"<article><b>{sum(q['pending'] for q in queues)}</b><span>pending workloads</span></article>"
                    f"<article><b>{len(snapshot['pod_groups'])}</b><span>gangs observed</span></article>"
                    "</div>"
                ),
                "<section><h2>Kueue cluster queues</h2>"
                + _table(
                    ["Queue", "Cohort", "Active", "Pending", "Admitted"],
                    [[q["name"], q["cohort"], q["active"], q["pending"], q["admitted"]] for q in queues],
                )
                + "</section>",
                "<section><h2>Local queues</h2>"
                + _table(
                    ["Namespace", "Queue", "ClusterQueue", "Pending", "Admitted"],
                    [
                        [q["namespace"], q["name"], q["cluster_queue"], q["pending"], q["admitted"]]
                        for q in snapshot["local_queues"]
                    ],
                )
                + "</section>",
                "<section><h2>Kueue workloads</h2>"
                + _table(
                    ["Namespace", "Workload", "Queue", "Admitted", "Finished"],
                    [[w["namespace"], w["name"], w["queue"], w["admitted"], w["finished"]] for w in snapshot["workloads"]],
                )
                + "</section>",
                "<section><h2>kind nodes</h2>"
                + _table(
                    ["Node", "Ready", "Role"],
                    [[node["name"], node["ready"], node["roles"]] for node in snapshot["nodes"]],
                )
                + "</section>",
                "<section><h2>Volcano gang scheduling</h2>"
                + _table(
                    [
                        "PodGroup",
                        "Outcome (derived from Pods)",
                        "Running / minimum",
                        "Controller phase",
                    ],
                    [
                        [
                            g["name"],
                            g["outcome"],
                            f"{g['observed_running']} / {g['min_member']}",
                            g["controller_phase"],
                        ]
                        for g in snapshot["pod_groups"]
                    ],
                )
                + "</section>",
                "<section><h2>Gang member pods</h2>"
                + _table(
                    ["Pod", "Phase", "Node"],
                    [[p["name"], p["phase"], p["node"]] for p in snapshot["gang_pods"]],
                )
                + "</section>",
            ]
        )
    refreshed = snapshot["generated_at"] if snapshot else "not available"
    return f"""<!doctype html>
<html lang='en'><head><meta charset='utf-8'><meta http-equiv='refresh' content='5'>
<meta name='viewport' content='width=device-width,initial-scale=1'>
<title>GPU Scheduler Lab — Live Kubernetes Evidence</title>
<style>
body{{margin:0;background:#0b1020;color:#e5edf9;font:16px ui-sans-serif,system-ui;padding:32px;}}
main{{max-width:1200px;margin:auto}} h1{{margin:0 0 8px;font-size:32px}} h2{{font-size:19px;margin:0 0 14px}}
.subtitle{{color:#9fb0c7;margin:0 0 22px}} .notice{{border-left:4px solid #f7b955;background:#17213a;padding:14px;margin:0 0 22px;color:#f9e5b5}}
.cards{{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:20px}} article,section{{background:#111a2e;border:1px solid #253557;border-radius:10px;padding:18px}} article b{{font-size:30px;display:block;color:#70e0b5}} article span{{color:#a9b7cc}} section{{margin-bottom:18px}} table{{width:100%;border-collapse:collapse}} th,td{{padding:10px;text-align:left;border-bottom:1px solid #263657}} th{{color:#8eb4ff;font-weight:650}} td{{color:#d6e0ef}} .error{{border-color:#ef7777}} pre{{white-space:pre-wrap}} footer{{color:#7e91ae;font-size:13px;margin-top:16px}} @media(max-width:760px){{.cards{{grid-template-columns:repeat(2,1fr)}}body{{padding:16px}}}}
</style></head><body><main>
<h1>GPU Scheduler Lab</h1><p class='subtitle'>Live Kubernetes scheduler evidence · auto-refreshes every 5 seconds</p>
<p class='notice'><strong>SIMULATED HARDWARE:</strong> <code>example.com/simulated-gpu</code> is Kueue quota accounting only. This page shows real kind, Kueue and Volcano state; it does not claim physical GPU scheduling or performance.</p>
{content}<footer>Project-scoped kind cluster: <code>gpu-scheduler-lab</code> · Last refresh: {escape(refreshed)}</footer>
</main></body></html>"""


class DashboardHandler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path not in {"/", "/healthz"}:
            self.send_error(HTTPStatus.NOT_FOUND, "Not found")
            return
        if self.path == "/healthz":
            self.send_response(HTTPStatus.OK)
            self.end_headers()
            self.wfile.write(b"ok\n")
            return
        try:
            body = render_dashboard(collect_snapshot()).encode()
        except (RuntimeError, subprocess.TimeoutExpired, json.JSONDecodeError) as exc:
            body = render_dashboard(None, str(exc)).encode()
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, _format: str, *_args: object) -> None:
        return


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve GPU Scheduler Lab Kubernetes evidence.")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=18081)
    args = parser.parse_args()
    server = ThreadingHTTPServer((args.host, args.port), DashboardHandler)
    print(f"GPU Scheduler Lab dashboard: http://{args.host}:{args.port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
