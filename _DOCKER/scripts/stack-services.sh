#!/bin/bash

source ../.env

docker stack services ${STACK_NAME}

