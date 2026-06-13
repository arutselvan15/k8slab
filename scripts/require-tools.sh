#!/bin/bash
# Standalone CLI: verify commands exist on PATH.
#
#   ./scripts/require-tools.sh kubectl helm envsubst
#
# Other scripts invoke this with their required tool list; it is not sourced.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [command ...]

Exit 0 if every command is on PATH; otherwise print missing names and exit 1.

Example:
  $(basename "$0") kubectl helm envsubst
EOF
}

tool_hint() {
  case "$1" in
    envsubst)
      echo "Install gettext (e.g. brew install gettext && brew link --force gettext)" >&2
      ;;
  esac
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 1
fi

missing=0
tool=""
for tool in "$@"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required tool not found: $tool" >&2
    tool_hint "$tool"
    missing=1
  fi
done

exit "$missing"
