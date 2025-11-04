#!/bin/bash
set -e

kubectl run load-generator --image=busybox:1.36 --restart=Never -n wordpress -- /bin/sh -c "while true; do wget -q -O- http://wordpress-service; done"

sleep 60

kubectl get hpa -n wordpress

kubectl delete pod load-generator -n wordpress

