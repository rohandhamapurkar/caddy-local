#!/bin/bash
set -euo pipefail
if ! docker network inspect local-apps >/dev/null 2>&1; then
    docker network create local-apps >/dev/null
fi
printf '%s\n' 'Shared local-apps network is ready.'
