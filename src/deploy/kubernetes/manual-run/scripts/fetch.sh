#!/usr/bin/env bash
set -euo pipefail

MODE="${MODE:-jar}"          # jar | docker
ARTIFACT_DIR="artifacts"
VERSION_FILE="version.txt"
NEW_VERSION=$(cat "$VERSION_FILE")
CURRENT_VERSION_FILE="current_version.txt"
PREVIOUS_VERSION_FILE="previous_version.txt"
JAR_NAME="app-${NEW_VERSION}.jar"
IMAGE_REPO="${IMAGE_REPO:-myrepo/demo-app}" # used when MODE=docker

mkdir -p "$ARTIFACT_DIR"

echo "[FETCH] Mode=$MODE targetVersion=$NEW_VERSION"

if [[ -f "$CURRENT_VERSION_FILE" ]]; then
	CUR=$(cat "$CURRENT_VERSION_FILE")
	echo "$CUR" > "$PREVIOUS_VERSION_FILE"
	echo "[FETCH] Previous version recorded: $CUR"
fi

if [[ "$MODE" == "jar" ]]; then
	# Simulate downloading jar (could be replaced with curl/wget)
	TARGET_PATH="$ARTIFACT_DIR/$JAR_NAME"
	if [[ ! -f "$TARGET_PATH" ]]; then
		echo "Creating dummy JAR file $TARGET_PATH"
		echo "echo 'Hello version $NEW_VERSION'" > "$TARGET_PATH"
	fi
	echo "$NEW_VERSION" > "$CURRENT_VERSION_FILE.pending"
	echo "[FETCH] Prepared JAR artifact $TARGET_PATH"
elif [[ "$MODE" == "docker" ]]; then
	IMAGE_TAG="${IMAGE_REPO}:${NEW_VERSION}"
	echo "[FETCH] Pulling docker image $IMAGE_TAG"
	if command -v docker >/dev/null 2>&1; then
		docker pull "$IMAGE_TAG" || echo "[WARN] docker pull failed (image may be dummy in tutorial)"
	else
		echo "[WARN] Docker not installed; skipping pull"
	fi
	echo "$NEW_VERSION" > "$CURRENT_VERSION_FILE.pending"
else
	echo "[ERROR] Unknown MODE=$MODE" >&2
	exit 1
fi