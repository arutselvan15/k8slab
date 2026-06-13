#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Creates the Kind cluster (if missing) and installs or upgrades Argo CD.
Safe to re-run: existing cluster and Helm release are updated, not recreated.

Available clusters: dev, stg, prod

Examples:
  $(basename "$0") dev
  $(basename "$0") stg
  $(basename "$0") prod

Teardown: ./kind/destroy.sh <cluster-name>
EOF
}

require_tools() {
  local tool
  for tool in kind kubectl helm; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "Required tool not found: $tool" >&2
      exit 1
    fi
  done
}

CLUSTER="${1:-}"
if [[ -z "$CLUSTER" ]]; then
  usage
  exit 1
fi

require_tools

KUBE_CONTEXT="kind-${CLUSTER}"

echo "==> Kind cluster: $CLUSTER"
"$SCRIPT_DIR/kind/setup.sh" "$CLUSTER"

if ! kubectl config get-contexts -o name 2>/dev/null | grep -qx "$KUBE_CONTEXT"; then
  echo "Context '$KUBE_CONTEXT' not found in kubeconfig after Kind setup." >&2
  exit 1
fi

kubectl config use-context "$KUBE_CONTEXT" >/dev/null

echo "==> Argo CD"
"$SCRIPT_DIR/argocd/install.sh" "$KUBE_CONTEXT"

echo ""
echo "Bootstrap complete for '$CLUSTER' (context $KUBE_CONTEXT)."
echo "  kubectl --context $KUBE_CONTEXT get pods -n argocd"
echo "  kubectl --context $KUBE_CONTEXT port-forward svc/argocd-server -n argocd 8888:80"
