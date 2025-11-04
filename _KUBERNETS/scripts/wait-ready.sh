#!/bin/bash
set -e

kubectl wait --for=condition=ready pod -l app=mysql -n wordpress --timeout=300s

kubectl wait --for=condition=ready pod -l app=wordpress -n wordpress --timeout=300s

kubectl wait --for=condition=ready pod -l app=phpmyadmin -n wordpress --timeout=300s

kubectl wait --for=condition=ready pod -l app=uptime-kuma -n wordpress --timeout=300s

kubectl wait --for=condition=ready pod -l app=mailhog -n wordpress --timeout=300s

