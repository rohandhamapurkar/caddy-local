#!/bin/bash
set -euo pipefail
if [[ "$(uname -s)" != Darwin || "$EUID" -eq 0 ]]; then
    printf '%s\n' 'Run on macOS without sudo; the hosts step requests administrator access.' >&2
    exit 1
fi
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker info >/dev/null
bash "$script_dir/initialize.sh"
sudo /bin/bash "$script_dir/set-local-host.sh"
docker compose -f "$script_dir/compose.yaml" up -d
bash "$script_dir/trust-local-ca.sh"
printf '%s\n' 'Shared proxy is ready. Start your SearXNG and Pi-hole containers separately.'
