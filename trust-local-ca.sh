#!/bin/bash
set -euo pipefail
if [[ "$(uname -s)" != Darwin ]]; then
    printf '%s\n' 'This certificate trust script is for macOS only.' >&2
    exit 1
fi
if [[ "$EUID" -eq 0 ]]; then
    printf '%s\n' 'Run without sudo to use your own login Keychain.' >&2
    exit 1
fi
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
certificate_path="$script_dir/caddy-local-root.crt"
ready=false
for ((attempt = 1; attempt <= 15; attempt++)); do
    if docker compose -f "$script_dir/compose.yaml" cp \
        caddy:/data/caddy/pki/authorities/local/root.crt "$certificate_path"; then
        ready=true
        break
    fi
    if ((attempt < 15)); then sleep 2; fi
done
if [[ "$ready" != true ]]; then
    printf '%s\n' 'Could not export the CA. Check docker compose logs caddy and retry.' >&2
    exit 1
fi
printf '%s\n' 'Trusting this CA for SSL in your login Keychain. macOS may request authorization.'
/usr/bin/security add-trusted-cert -r trustRoot -p ssl \
    -k "$HOME/Library/Keychains/login.keychain-db" "$certificate_path"
printf '%s\n' 'CA installed. Restart browsers if needed, then open your configured local HTTPS sites.'
