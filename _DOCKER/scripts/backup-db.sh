#!/bin/bash
set -e

source ../.env

BACKUP_DIR="../backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

CONTAINER_ID=$(docker ps -q -f name=${STACK_NAME}_mysql)

docker exec $CONTAINER_ID mysqldump -u root -pchangeme_root_password wordpress > $BACKUP_DIR/wordpress_$TIMESTAMP.sql

ls -lh $BACKUP_DIR

