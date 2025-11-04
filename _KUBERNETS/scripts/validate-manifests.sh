#!/bin/bash
set -e

for file in ../manifests/*.yaml; do
  kubectl apply --dry-run=client -f "$file"
done

