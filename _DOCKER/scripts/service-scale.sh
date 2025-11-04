#!/bin/bash
set -e

source ../.env

if [ -z "$1" ] || [ -z "$2" ]; then
  exit 1
fi

docker service scale ${STACK_NAME}_$1=$2

docker service ls

