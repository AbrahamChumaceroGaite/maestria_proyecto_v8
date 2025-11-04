#!/bin/bash
set -e

if [ -f /run/secrets/app.env ]; then
    export $(grep -v '^#' /run/secrets/app.env | xargs)
    export PMA_PASSWORD="${MYSQL_PASSWORD}"
fi

exec /docker-entrypoint.sh "$@"
