#!/bin/bash
set -e

kubectl apply -f ../manifests/00-namespace.yaml

sleep 2

kubectl apply -f ../manifests/01-secrets.yaml
kubectl apply -f ../manifests/02-configmaps.yaml
kubectl apply -f ../manifests/03-storage.yaml

sleep 5

kubectl apply -f ../manifests/04-mysql.yaml

kubectl wait --namespace wordpress \
  --for=condition=ready pod \
  --selector=app=mysql \
  --timeout=300s

kubectl apply -f ../manifests/05-wordpress.yaml
kubectl apply -f ../manifests/06-phpmyadmin.yaml
kubectl apply -f ../manifests/07-uptime-kuma.yaml
kubectl apply -f ../manifests/08-mailhog.yaml

kubectl wait --namespace wordpress \
  --for=condition=ready pod \
  --selector=app=wordpress \
  --timeout=300s

kubectl apply -f ../manifests/09-wp-cli-job.yaml

kubectl apply -f ../manifests/10-ingress.yaml
kubectl apply -f ../manifests/11-hpa.yaml
kubectl apply -f ../manifests/12-networkpolicy.yaml
kubectl apply -f ../manifests/13-resourcequota.yaml
kubectl apply -f ../manifests/14-poddisruptionbudget.yaml
kubectl apply -f ../manifests/15-servicemonitor.yaml

kubectl get pods -n wordpress
kubectl get svc -n wordpress
kubectl get ingress -n wordpress
kubectl get hpa -n wordpress

