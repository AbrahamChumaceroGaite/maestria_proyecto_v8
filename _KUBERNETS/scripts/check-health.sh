#!/bin/bash

kubectl get pods -n wordpress -o custom-columns=NAME:.metadata.name,READY:.status.conditions[?\(@.type==\"Ready\"\)].status,STATUS:.status.phase

kubectl top nodes 2>/dev/null || true

kubectl top pods -n wordpress 2>/dev/null || true

