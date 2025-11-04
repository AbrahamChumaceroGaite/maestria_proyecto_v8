#!/bin/bash

if [ -z "$1" ]; then
  kubectl get pods -n wordpress
  exit 0
fi

POD_NAME=$(kubectl get pods -n wordpress -l app=$1 -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it -n wordpress $POD_NAME -- /bin/bash

