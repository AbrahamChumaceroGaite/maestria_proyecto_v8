#!/bin/bash
set -e

helm uninstall wordpress --namespace wordpress

kubectl delete namespace wordpress

