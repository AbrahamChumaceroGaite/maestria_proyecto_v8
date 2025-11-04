#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  exit 1
fi

DEPLOYMENT=$1
IMAGE=$2

kubectl set image deployment/$DEPLOYMENT -n wordpress $DEPLOYMENT=$IMAGE

kubectl rollout status deployment/$DEPLOYMENT -n wordpress

kubectl rollout history deployment/$DEPLOYMENT -n wordpress

