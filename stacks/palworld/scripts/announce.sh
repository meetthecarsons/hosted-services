#!/usr/bin/env bash
# Broadcast a message to everyone on the deployed Palworld server, via its
# REST API (/v1/api/announce) rather than RCON's Broadcast command, which
# mangles spaces. Run this on the host the stack is deployed to (it reads
# ADMIN_PASSWORD from the sibling .env, and hits the API on localhost).
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="$script_dir/../.env"

if [ $# -ne 1 ]; then
  echo "usage: $0 <message>" >&2
  exit 1
fi

if [ ! -f "$env_file" ]; then
  echo "missing $env_file — deploy the stack first (make deploy SERVICE=palworld)" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$env_file"

curl -sf -u "admin:${ADMIN_PASSWORD}" \
  -X POST -H 'Content-Type: application/json' \
  -d "$(jq -n --arg message "$1" '{message: $message}')" \
  "http://localhost:${REST_API_PORT:-8212}/v1/api/announce" \
  && echo "Broadcast sent."
