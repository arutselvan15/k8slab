#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") [overlay]

Day 1 — installs or upgrades Argo CD on the cluster from the current shell.
Safe to re-run.

Overlay selects Helm values (dev, stg, prod). Default: dev or \$ARGOCD_OVERLAY.

Run after kubeconfig is loaded, e.g.:
  source ../scripts/kubeconfig-setup.sh /path/to/kubeconfig.yaml
  $(basename "$0") dev

Argo CD Helm only:
  ./argocd/install.sh dev
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

OVERLAY="${ARGOCD_OVERLAY:-${1:-dev}}"

if [[ -n "${2:-}" ]]; then
  echo "Unexpected argument: $2" >&2
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

echo "==> Day 1: Argo CD (overlay: $OVERLAY)"
"$SCRIPT_DIR/argocd/install.sh" "$OVERLAY"

echo ""
echo "Day 1 complete."
echo "  kubectl get pods -n argocd"
echo "  kubectl port-forward svc/argocd-server -n argocd 8888:80"
echo "Day 2: add manifests under gitops/ when ready."
