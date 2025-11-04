#!/bin/bash

source ../.env

if [ -z "$DOCKER_USERNAME" ] || [ "$DOCKER_USERNAME" == "yourusername" ]; then
  exit 1
fi

if [ ! -f "../secrets.env" ]; then
  exit 1
fi

