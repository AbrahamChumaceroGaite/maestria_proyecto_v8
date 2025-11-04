#!/bin/bash
set -e

helm upgrade --install wordpress ../helm/wordpress \
  --create-namespace \
  --namespace wordpress \
  --wait \
  --timeout 10m

kubectl get all -n wordpress

