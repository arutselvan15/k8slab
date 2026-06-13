#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0")

Day 1 — installs or upgrades Argo CD on the cluster from the current shell.
Safe to re-run.

Run after kubeconfig is loaded, e.g.:
  source ../scripts/kubeconfig-setup.sh /path/to/kubeconfig.yaml
  $(basename "$0")

Argo CD Helm only:
  ./argocd/install.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -n "${1:-}" ]]; then
  echo "Unexpected argument: $1 (bootstrap does not take a profile or cluster name)" >&2
  usage >&2
  exit 1
fi

require_tools() {
  local tool
  for tool in kubectl helm; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "Required tool not found: $tool" >&2
      exit 1
    fi
  done
}

require_tools

echo "==> Day 1: Argo CD"
"$SCRIPT_DIR/argocd/install.sh"

echo ""
echo "Day 1 complete."
echo "  kubectl get pods -n argocd"
echo "  kubectl port-forward svc/argocd-server -n argocd 8888:80"
echo "Day 2: add manifests under gitops/ when ready."
