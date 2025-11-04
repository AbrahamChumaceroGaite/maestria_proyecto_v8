#!/bin/bash

WORDPRESS_PORT=$(kubectl get svc -n wordpress wordpress-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "80")
PHPMYADMIN_PORT=$(kubectl get svc -n wordpress phpmyadmin-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "8080")
UPTIME_PORT=$(kubectl get svc -n wordpress uptime-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "3001")
MAILHOG_PORT=$(kubectl get svc -n wordpress mailhog-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "8025")

echo "WordPress: http://localhost:$WORDPRESS_PORT"
echo "phpMyAdmin: http://localhost:$PHPMYADMIN_PORT"
echo "Uptime Kuma: http://localhost:$UPTIME_PORT"
echo "MailHog: http://localhost:$MAILHOG_PORT"

