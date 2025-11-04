#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  exit 1
fi

kubectl scale deployment/$1 --replicas=$2 -n wordpress

kubectl get pods -n wordpress -l app=$1

