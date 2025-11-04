#!/bin/bash

source ../.env

if [ -z "$1" ]; then
  docker stack services ${STACK_NAME}
  exit 0
fi

docker service logs ${STACK_NAME}_$1 --tail 100 -f

