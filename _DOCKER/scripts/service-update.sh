#!/bin/bash
set -e

source ../.env

if [ -z "$1" ]; then
  exit 1
fi

docker service update --image ${DOCKER_USERNAME}/wordpress-$1:${IMAGE_TAG} ${STACK_NAME}_$1

docker service ps ${STACK_NAME}_$1

