#!/bin/bash
# Source from bootstrap scripts (not executed directly).
# Loads defaults.env, then optional bootstrap.env.

_BOOTSTRAP_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -a
# shellcheck source=defaults.env
source "${_BOOTSTRAP_ENV_DIR}/defaults.env"

if [[ -f "${_BOOTSTRAP_ENV_DIR}/bootstrap.env" ]]; then
  # shellcheck source=bootstrap.env
  source "${_BOOTSTRAP_ENV_DIR}/bootstrap.env"
fi
set +a

unset _BOOTSTRAP_ENV_DIR
