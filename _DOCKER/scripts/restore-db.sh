#!/bin/bash
set -e

source ../.env

if [ -z "$1" ]; then
  exit 1
fi

BACKUP_FILE=$1

CONTAINER_ID=$(docker ps -q -f name=${STACK_NAME}_mysql)

docker exec -i $CONTAINER_ID mysql -u root -pchangeme_root_password wordpress < $BACKUP_FILE

