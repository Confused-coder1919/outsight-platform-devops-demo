#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-outsight-demo}"
AGENTS="${AGENTS:-2}"

if k3d cluster list | awk 'NR>1 {print $1}' | grep -q "^${CLUSTER_NAME}$"; then
  echo "k3d cluster '${CLUSTER_NAME}' already exists."
else
  echo "Creating k3d cluster '${CLUSTER_NAME}'..."
  k3d cluster create "${CLUSTER_NAME}" --servers 1 --agents "${AGENTS}" --port "8000:8000@loadbalancer"
fi

echo "k3d cluster is ready."
