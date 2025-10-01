#!/usr/bin/env bash
set -euo pipefail

ACTION=${1:-start}           # start | rollback
MODE="${MODE:-jar}"          # jar | docker
ARTIFACT_DIR="artifacts"
CURRENT_VERSION_FILE="current_version.txt"
PENDING_VERSION_FILE="current_version.txt.pending"
PREVIOUS_VERSION_FILE="previous_version.txt"
PID_FILE="app.pid"
CONTAINER_NAME="demo-app-running"
IMAGE_REPO="${IMAGE_REPO:-myrepo/demo-app}"

pick_version() {
  if [[ "$ACTION" == "rollback" ]]; then
    if [[ -f "$PREVIOUS_VERSION_FILE" ]]; then
      cat "$PREVIOUS_VERSION_FILE"
    else
      echo "[ROLLBACK] No previous version file found" >&2
      return 1
    fi
  else
    if [[ -f "$PENDING_VERSION_FILE" ]]; then
      mv "$PENDING_VERSION_FILE" "$CURRENT_VERSION_FILE"
    fi
    cat "$CURRENT_VERSION_FILE"
  fi
}

VERSION=$(pick_version)
echo "[START] ACTION=$ACTION MODE=$MODE VERSION=$VERSION"

if [[ "$MODE" == "jar" ]]; then
  JAR_PATH="$ARTIFACT_DIR/app-${VERSION}.jar"
  if [[ ! -f "$JAR_PATH" ]]; then
    echo "[ERROR] JAR not found: $JAR_PATH" >&2
    exit 1
  fi
  echo "[START] Launching jar $JAR_PATH"
  bash "$JAR_PATH" &
  NEW_PID=$!
  echo $NEW_PID > "$PID_FILE"
  echo "[START] Started PID $NEW_PID"
elif [[ "$MODE" == "docker" ]]; then
  IMAGE_TAG="${IMAGE_REPO}:${VERSION}"
  if command -v docker >/dev/null 2>&1; then
    echo "[START] Running container $CONTAINER_NAME from $IMAGE_TAG"
    docker run -d --rm --name "$CONTAINER_NAME" -p 18080:8080 "$IMAGE_TAG" || echo "[WARN] Could not start container (image may not exist in tutorial)"
  else
    echo "[WARN] Docker not installed; cannot actually start container"
  fi
else
  echo "[ERROR] Unknown MODE=$MODE" >&2
  exit 1
fi

echo "[START] Done"