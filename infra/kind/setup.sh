#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Day 0 — creates a Kind cluster from <cluster-name>-cluster.yaml.
Safe to re-run: skips creation if the cluster already exists.

kubectl context: kind-<cluster-name>

Profiles: dev, stg, prod

Examples:
  $(basename "$0") dev

Teardown: ./destroy.sh <cluster-name>
EOF
}

CLUSTER="${1:-}"
if [[ -z "$CLUSTER" ]]; then
  usage
  exit 1
fi

CONFIG="${SCRIPT_DIR}/${CLUSTER}-cluster.yaml"
if [[ ! -f "$CONFIG" ]]; then
  echo "Unknown cluster '$CLUSTER': missing $CONFIG" >&2
  exit 1
fi

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' already exists; skipping create."
else
  kind create cluster --config "$CONFIG" --name "$CLUSTER"
  echo "Created Kind cluster '$CLUSTER'."
fi

echo "kubectl context: kind-${CLUSTER}"
