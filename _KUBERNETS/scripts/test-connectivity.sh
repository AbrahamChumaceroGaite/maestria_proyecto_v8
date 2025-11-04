#!/bin/bash

kubectl run test-pod --image=busybox:1.36 --restart=Never -n wordpress -- sleep 3600

kubectl wait --for=condition=ready pod/test-pod -n wordpress --timeout=60s

kubectl exec -n wordpress test-pod -- wget -O- http://wordpress-service

kubectl exec -n wordpress test-pod -- wget -O- http://mysql-service:3306

kubectl exec -n wordpress test-pod -- wget -O- http://phpmyadmin-service:8080

kubectl delete pod test-pod -n wordpress

