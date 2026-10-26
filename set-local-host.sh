#!/bin/bash
set -euo pipefail
if [[ "$(uname -s)" != Darwin || "$EUID" -ne 0 ]]; then
    printf '%s\n' 'Run on macOS with sudo to update /etc/hosts.' >&2
    exit 1
fi
missing=()
for hostname in searxng.test pihole.test; do
    state="$(awk -v hostname="$hostname" '
        { sub(/#.*/, "") }
        { for (i=2; i<=NF; i++) if (tolower($i)==hostname) {
            found=1; if ($1!="127.0.0.1") conflict=1
        } }
        END { if(conflict) print "conflict"; else if(found) print "present"; else print "absent" }
    ' /etc/hosts)"
    if [[ "$state" == conflict ]]; then
        printf 'Conflicting hosts entry for %s; no changes made.\n' "$hostname" >&2
        exit 1
    fi
    if [[ "$state" == absent ]]; then missing+=("$hostname"); fi
done
if [[ "${#missing[@]}" -gt 0 ]]; then
    backup_path="$(mktemp /etc/hosts.caddy-backup.XXXXXX)"
    cp -p /etc/hosts "$backup_path"
    for hostname in "${missing[@]}"; do
        printf '\n127.0.0.1 %s # Caddy local services\n' "$hostname" >> /etc/hosts
    done
    printf 'Saved hosts backup: %s\n' "$backup_path"
fi
/usr/bin/dscacheutil -flushcache
/usr/bin/killall -HUP mDNSResponder
