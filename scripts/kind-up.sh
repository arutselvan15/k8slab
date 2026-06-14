#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Day 0 (Kind) + kubeconfig + Day 1 (Argo CD) + Day 2 seed (core-apps) when present.
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

echo "==> Validate tools"
"$REPO_ROOT/scripts/require-tools.sh" kubectl helm envsubst

echo "==> Day 0: Kind cluster"
"$REPO_ROOT/infra/kind/setup.sh" "$CLUSTER"

echo "==> Kubeconfig"
KUBECONFIG_FILE="${REPO_ROOT}/.kube/kind-${CLUSTER}.yaml"
# shellcheck source=scripts/kubeconfig-setup.sh
source "$REPO_ROOT/scripts/kubeconfig-setup.sh" "$KUBECONFIG_FILE"

echo "==> Day 1: Bootstrap the cluster"
"$REPO_ROOT/bootstrap/bootstrap.sh" "$CLUSTER"

CORE_APP="${REPO_ROOT}/gitops/clusters/${CLUSTER}/core.application.yaml"
if [[ -f "$CORE_APP" ]]; then
  echo "==> Day 2: Apply GitOps (core-apps)"
  kubectl apply -f "$CORE_APP"
else
  echo "==> Day 2: skip (no ${CORE_APP})" >&2
fi

echo ""
echo "Platform up for '$CLUSTER'. See gitops/README.md (push Git if Applications stay OutOfSync)."
