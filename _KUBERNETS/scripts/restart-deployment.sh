#!/bin/bash

if [ -z "$1" ]; then
  exit 1
fi

kubectl rollout restart deployment/$1 -n wordpress

kubectl rollout status deployment/$1 -n wordpress

