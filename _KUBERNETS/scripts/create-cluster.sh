#!/bin/bash
set -e

k3d cluster create --config ../k3d-config.yaml

kubectl cluster-info

kubectl wait --for=condition=Ready nodes --all --timeout=300s

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

kubectl get nodes

