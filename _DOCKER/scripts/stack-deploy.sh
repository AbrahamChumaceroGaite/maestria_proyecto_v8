#!/bin/bash
set -e

source ../.env

docker stack deploy -c ../docker-stack.yml ${STACK_NAME}

sleep 5

docker stack services ${STACK_NAME}

