#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_BASE="${SCRIPT_DIR}/values/base.yaml"
OVERLAYS_DIR="${SCRIPT_DIR}/values/overlays"
# shellcheck source=versions.env
source "${SCRIPT_DIR}/versions.env"

usage() {
  cat <<EOF
Usage: $(basename "$0") <overlay>

Day 1 — installs or upgrades Argo CD with Helm (pinned chart version).
Safe to re-run.

Overlays: dev, stg, prod (files under values/overlays/)

Chart: argo/argo-cd ${ARGO_CD_CHART_VERSION}

Example:
  $(basename "$0") dev
EOF
}

OVERLAY="${1:-}"
if [[ "${OVERLAY:-}" == "-h" || "${OVERLAY:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "$OVERLAY" ]]; then
  usage >&2
  exit 1
fi

if [[ -n "${2:-}" ]]; then
  echo "Unexpected argument: $2" >&2
  usage >&2
  exit 1
fi

OVERLAY_FILE="${OVERLAYS_DIR}/${OVERLAY}.yaml"
if [[ ! -f "$OVERLAY_FILE" ]]; then
  echo "Unknown overlay '$OVERLAY' (expected ${OVERLAY_FILE})" >&2
  exit 1
fi

echo "Adding Argo CD Helm repo ..."
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update

echo "Creating namespace argocd ..."
kubectl create namespace argocd \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Installing or upgrading Argo CD (chart ${ARGO_CD_CHART_VERSION}, overlay ${OVERLAY}) ..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --version "${ARGO_CD_CHART_VERSION}" \
  --values "$VALUES_BASE" \
  --values "$OVERLAY_FILE" \
  --wait

echo "Argo CD ready (overlay: ${OVERLAY}, chart: ${ARGO_CD_CHART_VERSION})."
