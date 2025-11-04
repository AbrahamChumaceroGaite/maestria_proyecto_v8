#!/bin/bash
set -e

kubectl delete -f ../manifests/15-servicemonitor.yaml --ignore-not-found
kubectl delete -f ../manifests/14-poddisruptionbudget.yaml --ignore-not-found
kubectl delete -f ../manifests/13-resourcequota.yaml --ignore-not-found
kubectl delete -f ../manifests/12-networkpolicy.yaml --ignore-not-found
kubectl delete -f ../manifests/11-hpa.yaml --ignore-not-found
kubectl delete -f ../manifests/10-ingress.yaml --ignore-not-found
kubectl delete -f ../manifests/09-wp-cli-job.yaml --ignore-not-found
kubectl delete -f ../manifests/08-mailhog.yaml --ignore-not-found
kubectl delete -f ../manifests/07-uptime-kuma.yaml --ignore-not-found
kubectl delete -f ../manifests/06-phpmyadmin.yaml --ignore-not-found
kubectl delete -f ../manifests/05-wordpress.yaml --ignore-not-found
kubectl delete -f ../manifests/04-mysql.yaml --ignore-not-found

sleep 5

kubectl delete -f ../manifests/03-storage.yaml --ignore-not-found
kubectl delete -f ../manifests/02-configmaps.yaml --ignore-not-found
kubectl delete -f ../manifests/01-secrets.yaml --ignore-not-found
kubectl delete -f ../manifests/00-namespace.yaml --ignore-not-found

