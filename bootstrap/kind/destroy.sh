#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Deletes a Kind cluster created from <cluster-name>-cluster.yaml in this directory.

Available clusters:
  dev
  stg
  prod

Examples:
  $(basename "$0") dev
  $(basename "$0") stg
  $(basename "$0") prod
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

if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' is not running." >&2
  exit 0
fi

kind delete cluster --name "$CLUSTER"

echo "Cluster '$CLUSTER' deleted."
