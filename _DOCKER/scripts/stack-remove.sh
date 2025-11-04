#!/bin/bash
set -e

source ../.env

docker stack rm ${STACK_NAME}

