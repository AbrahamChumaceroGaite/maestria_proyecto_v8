#!/bin/bash
set -e

# Leer secret nativo de Docker
if [ -f /run/secrets/mysql_password ]; then
    export PMA_PASSWORD="$(cat /run/secrets/mysql_password)"
else
    # Modo Docker Compose
    PMA_PASSWORD="${PMA_PASSWORD:-changeme}"
fi

# Ejecutar entrypoint original de phpMyAdmin
exec /docker-entrypoint.sh "$@"
