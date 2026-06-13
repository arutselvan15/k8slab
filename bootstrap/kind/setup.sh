#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Creates a Kind cluster using <cluster-name>-cluster.yaml in this directory.
Safe to re-run: skips creation if the cluster already exists.

kubectl context will be kind-<cluster-name> (Kind adds the kind- prefix automatically).

Available clusters:
  dev   (context kind-dev;   ingress host ports 8080, 8443)
  stg   (context kind-stg;   ingress host ports 9080, 9443)
  prod  (context kind-prod; ingress host ports 80, 443)

Examples:
  $(basename "$0") dev
  $(basename "$0") stg
  $(basename "$0") prod

Delete: ./destroy.sh <cluster-name>
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
