#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

ACTION="${1:-start}"
PORT="${GPU_SCHEDULER_DASHBOARD_PORT:-18081}"
STATE_DIR="$ROOT_DIR/.local"
PID_FILE="$STATE_DIR/dashboard.pid"
LOG_FILE="$STATE_DIR/dashboard.log"

dashboard_running() {
  test -f "$PID_FILE" && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

case "$ACTION" in
  start)
    need kubectl
    kubectl_lab get nodes >/dev/null || fail "kind cluster is unavailable; run make bootstrap-local"
    if dashboard_running; then
      log "Dashboard already running: http://127.0.0.1:${PORT}"
      exit 0
    fi
    mkdir -p "$STATE_DIR"
    rm -f "$PID_FILE"
    PYTHONPATH="$ROOT_DIR/scheduler-lab/src" nohup python3 -m gpulab.dashboard --port "$PORT" >"$LOG_FILE" 2>&1 &
    echo "$!" >"$PID_FILE"
    wait_for "dashboard health endpoint" curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null 2>&1
    log "Dashboard ready: http://127.0.0.1:${PORT}"
    ;;
  stop)
    if dashboard_running; then
      kill "$(cat "$PID_FILE")"
      log "Dashboard stopped"
    fi
    rm -f "$PID_FILE"
    ;;
  status)
    if dashboard_running; then
      curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null
      log "Dashboard healthy: http://127.0.0.1:${PORT}"
    else
      fail "dashboard is not running"
    fi
    ;;
  *) fail "usage: $0 {start|stop|status}" ;;
esac
