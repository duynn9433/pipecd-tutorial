#!/usr/bin/env bash
set -euo pipefail

MODE="${MODE:-jar}"          # jar | docker
PID_FILE="app.pid"
CONTAINER_NAME="demo-app-running"

echo "[STOP] Attempting to stop existing application (mode=$MODE)"

if [[ "$MODE" == "jar" ]]; then
	if [[ -f "$PID_FILE" ]]; then
		PID=$(cat "$PID_FILE")
		if ps -p "$PID" >/dev/null 2>&1; then
			echo "[STOP] Killing process $PID"
			kill "$PID" || true
			sleep 1
			if ps -p "$PID" >/dev/null 2>&1; then
				echo "[STOP] Force killing process $PID"
				kill -9 "$PID" || true
			fi
		else
			echo "[STOP] Stale PID file (no process)"
		fi
		rm -f "$PID_FILE"
	else
		echo "[STOP] No PID file found"
	fi
elif [[ "$MODE" == "docker" ]]; then
	if command -v docker >/dev/null 2>&1; then
		if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
			echo "[STOP] Stopping container $CONTAINER_NAME"
			docker stop "$CONTAINER_NAME" >/dev/null || true
			docker rm "$CONTAINER_NAME" >/dev/null || true
		else
			echo "[STOP] No running container named $CONTAINER_NAME"
		fi
	else
		echo "[STOP] Docker not installed; skipping container stop"
	fi
else
	echo "[ERROR] Unknown MODE=$MODE" >&2
	exit 1
fi

echo "[STOP] Done"