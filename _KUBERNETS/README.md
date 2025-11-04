WordPress con Kubernetes K3D

Crear cluster

cd scripts
chmod +x *.sh
./create-cluster.sh

Construir imágenes

./build-images.sh

Desplegar

./deploy.sh

Setup automatizado

./complete-setup.sh

Verificar

./status.sh

Ver logs

./logs.sh wordpress
./logs.sh mysql

Escalar

./scale.sh wordpress 5

Backup

./backup.sh

Restore

./restore.sh archivo.sql

Eliminar despliegue

./undeploy.sh

Eliminar cluster

./delete-cluster.sh

Teardown completo

./complete-teardown.sh

Acceso

WordPress: http://localhost
phpMyAdmin: http://localhost:8080
Uptime Kuma: http://localhost:3001
MailHog: http://localhost:8025

Credenciales

WordPress: admin / admin123
MySQL: wpuser / changeme_user_password

Comandos útiles

kubectl get pods -n wordpress
kubectl get svc -n wordpress
kubectl get ingress -n wordpress
kubectl get hpa -n wordpress
kubectl logs -n wordpress -l app=wordpress
kubectl scale deployment/wordpress --replicas=5 -n wordpress
kubectl delete -f manifests/

Arquitectura

Cluster: 1 servidor, 3 agentes
MySQL: StatefulSet 1 réplica
WordPress: Deployment 3 réplicas con HPA 3-10
phpMyAdmin: Deployment 2 réplicas con HPA 2-5
Uptime Kuma: Deployment 1 réplica
MailHog: Deployment 1 réplica

Recursos

MySQL: 512Mi-1Gi memoria, 500m-1000m CPU
WordPress: 256Mi-512Mi memoria, 250m-500m CPU
phpMyAdmin: 128Mi-256Mi memoria, 100m-250m CPU
Uptime Kuma: 128Mi-256Mi memoria, 100m-250m CPU
MailHog: 64Mi-128Mi memoria, 50m-250m CPU

Almacenamiento

MySQL: 5Gi PVC ReadWriteOnce
WordPress: 10Gi PVC ReadWriteMany
Uptime Kuma: 1Gi PVC ReadWriteOnce

Autoescalado

WordPress: 70% CPU, 80% memoria
phpMyAdmin: 70% CPU

Ingress

wordpress.local: WordPress
phpmyadmin.local: phpMyAdmin
uptime.local: Uptime Kuma
mail.local: MailHog

Agregar al archivo hosts:

127.0.0.1 wordpress.local phpmyadmin.local uptime.local mail.local

Manifiestos

00-namespace.yaml: namespace wordpress
01-secrets.yaml: credenciales
02-configmaps.yaml: configs Nginx, PHP, MySQL
03-storage.yaml: StorageClass y PVCs
04-mysql.yaml: StatefulSet MySQL
05-wordpress.yaml: Deployment WordPress
06-phpmyadmin.yaml: Deployment phpMyAdmin
07-uptime-kuma.yaml: Deployment Uptime Kuma
08-mailhog.yaml: Deployment MailHog
09-wp-cli-job.yaml: Job inicialización
10-ingress.yaml: Ingress Nginx
11-hpa.yaml: HorizontalPodAutoscaler
12-networkpolicy.yaml: políticas de red
13-resourcequota.yaml: cuotas de recursos
14-poddisruptionbudget.yaml: disruption budgets
15-servicemonitor.yaml: métricas

Scripts adicionales

./check-health.sh: verificar salud
./exec-pod.sh wordpress: acceder a pod
./port-forward.sh: port forwarding
./restart-deployment.sh wordpress: reiniciar
./rollback.sh wordpress: rollback
./update-image.sh wordpress imagen: actualizar
./validate-manifests.sh: validar
./stress-test.sh: test de carga
./test-connectivity.sh: test conectividad
./wait-ready.sh: esperar servicios
./get-urls.sh: obtener URLs

Helm

./helm-install.sh: instalar con Helm
./helm-uninstall.sh: desinstalar

Monitoreo

./monitoring-install.sh: Prometheus/Grafana
./monitoring-uninstall.sh: eliminar monitoreo

Healthchecks

MySQL: mysqladmin ping cada 10s
WordPress: HTTP GET cada 10s
Otros: HTTP GET

Rolling updates

WordPress: maxSurge 1, maxUnavailable 0
phpMyAdmin: maxSurge 1, maxUnavailable 0

Network policies

MySQL: solo acepta desde WordPress, phpMyAdmin, wp-cli
WordPress: puede conectar a MySQL y MailHog
MailHog: acepta desde WordPress

Pod disruption budgets

WordPress: mínimo 2 disponibles
phpMyAdmin: mínimo 1 disponible