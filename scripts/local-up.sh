#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Runs Day 0 (Kind) then Day 1 (Argo CD) for local learning.
Safe to re-run.

Profiles: dev, stg, prod

Example:
  $(basename "$0") dev

Teardown: $REPO_ROOT/infra/kind/destroy.sh <cluster-name>
EOF
}

CLUSTER="${1:-}"
if [[ -z "$CLUSTER" ]]; then
  usage
  exit 1
fi

echo "==> Day 0: cluster"
"$REPO_ROOT/infra/kind/setup.sh" "$CLUSTER"

echo "==> Day 1: bootstrap"
"$REPO_ROOT/bootstrap/bootstrap.sh" "$CLUSTER"

echo ""
echo "Local platform up for '$CLUSTER'. See docs/platform-lifecycle.md."
