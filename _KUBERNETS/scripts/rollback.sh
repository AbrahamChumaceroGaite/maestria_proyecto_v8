#!/bin/bash

if [ -z "$1" ]; then
  exit 1
fi

DEPLOYMENT=$1

kubectl rollout undo deployment/$DEPLOYMENT -n wordpress

kubectl rollout status deployment/$DEPLOYMENT -n wordpress

