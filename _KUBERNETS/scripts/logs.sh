#!/bin/bash

if [ -z "$1" ]; then
  kubectl get pods -n wordpress
  exit 0
fi

kubectl logs -n wordpress -l app=$1 --tail=100 -f

