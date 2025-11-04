#!/bin/bash

kubectl port-forward -n wordpress svc/wordpress-service 8000:80 &
kubectl port-forward -n wordpress svc/phpmyadmin-service 8080:8080 &
kubectl port-forward -n wordpress svc/uptime-service 3001:3001 &
kubectl port-forward -n wordpress svc/mailhog-service 8025:8025 &

wait

