#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Day 0 (Kind) + kubeconfig + Day 1 (Argo CD) for local learning.
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

echo "==> Day 0: Kind cluster"
"$REPO_ROOT/infra/kind/setup.sh" "$CLUSTER"

echo "==> Kubeconfig"
KUBECONFIG_FILE="${REPO_ROOT}/.kube/kind-${CLUSTER}.yaml"
# shellcheck source=scripts/kubeconfig-setup.sh
source "$REPO_ROOT/scripts/kubeconfig-setup.sh" "$KUBECONFIG_FILE"

echo "==> Day 1: bootstrap"
"$REPO_ROOT/bootstrap/bootstrap.sh" "$CLUSTER"

echo ""
echo "Kind platform up for '$CLUSTER'. See docs/platform-lifecycle.md."
