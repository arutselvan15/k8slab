#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") <cluster-name>

Day 1 — installs or upgrades Argo CD on an existing cluster.
Safe to re-run.

Expects kubectl context kind-<cluster-name> (from Kind Day 0 or cloud kubeconfig).

Profiles: dev, stg, prod

Examples:
  $(basename "$0") dev

Argo CD only (manual):
  ./argocd/install.sh kind-dev
EOF
}

require_tools() {
  local tool
  for tool in kubectl helm; do
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

if ! kubectl config get-contexts -o name 2>/dev/null | grep -qx "$KUBE_CONTEXT"; then
  echo "Context '$KUBE_CONTEXT' not found. Complete Day 0 first (infra/kind/setup.sh or Terraform)." >&2
  exit 1
fi

kubectl config use-context "$KUBE_CONTEXT" >/dev/null

echo "==> Day 1: Argo CD on $KUBE_CONTEXT"
"$SCRIPT_DIR/argocd/install.sh" "$KUBE_CONTEXT"

echo ""
echo "Day 1 complete for profile '$CLUSTER'."
echo "  kubectl --context $KUBE_CONTEXT get pods -n argocd"
echo "  kubectl --context $KUBE_CONTEXT port-forward svc/argocd-server -n argocd 8888:80"
echo "Day 2: add manifests under gitops/ when ready."
