#!/bin/bash
set -e

if [ -f /run/secrets/mysql_password ]; then
    export PMA_PASSWORD="$(cat /run/secrets/mysql_password)"
else
    PMA_PASSWORD="${PMA_PASSWORD:-changeme}"
fi

exec /docker-entrypoint.sh "$@"