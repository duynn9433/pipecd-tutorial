#!/bin/bash
VERSION=$(cat version.txt)
MODE=$1

if [ "$MODE" = "rollback" ]; then
  echo "[ROLLBACK] Pretend to restart previous JAR..."
else
  echo "[START] Pretend to start JAR version $VERSION ..."
fi