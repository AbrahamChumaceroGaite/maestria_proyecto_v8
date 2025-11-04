#!/bin/bash
set -e

helm uninstall prometheus --namespace monitoring

kubectl delete namespace monitoring

