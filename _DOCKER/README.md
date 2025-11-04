WordPress con Swarm

Configuración inicial

Editar .env.example y guardar como .env:

DOCKER_USERNAME=tu_usuario_dockerhub
IMAGE_TAG=1.0.0
STACK_NAME=wordpress

Editar secrets.env.example y guardar como secrets.env:

MYSQL_ROOT_PASSWORD=tu_password
MYSQL_PASSWORD=tu_password
WORDPRESS_DB_PASSWORD=tu_password

Login DockerHub

docker login

Construcción de imágenes

cd scripts
chmod +x *.sh
./build-images.sh

Subir a DockerHub

./push-images.sh

Iniciar Swarm

./swarm-init.sh

Desplegar stack

./stack-deploy.sh

Setup automatizado

./complete-setup.sh

Verificar servicios

./stack-services.sh
./stack-ps.sh

Ver logs

./service-logs.sh wordpress
./service-logs.sh mysql

Escalar servicios

./service-scale.sh wordpress 5
./service-scale.sh phpmyadmin 3

Actualizar servicio

./service-update.sh wordpress

Backup

./backup-db.sh

Restore

./restore-db.sh ../backups/archivo.sql

Eliminar stack

./stack-remove.sh

Salir de Swarm

./swarm-leave.sh

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

Comandos Docker Swarm

docker stack services wordpress
docker stack ps wordpress
docker service logs wordpress_wordpress
docker service scale wordpress_wordpress=5
docker service update wordpress_wordpress
docker stack rm wordpress

Arquitectura

MySQL: 1 réplica en manager
WordPress: 3 réplicas con rolling updates
phpMyAdmin: 2 réplicas en manager
Uptime Kuma: 1 réplica en manager
MailHog: 1 réplica en manager

Recursos

MySQL: 512M-1G memoria, 0.5-1 CPU
WordPress: 256M-512M memoria, 0.25-0.5 CPU
phpMyAdmin: 256M memoria, 0.25 CPU
Uptime Kuma: 256M memoria, 0.25 CPU
MailHog: 128M memoria, 0.25 CPU

Redes

frontend: overlay para servicios públicos
backend: overlay para comunicación interna

Volúmenes

mysql-data: datos MySQL
wordpress-data: archivos WordPress
uptime-data: datos Uptime Kuma

Secrets

credentials: archivo secrets.env

Configs

nginx_config: configuración Nginx
php_config: configuración PHP

Despliegue en servidor remoto

En servidor instalar Docker
Iniciar Swarm: docker swarm init
Crear secrets.env
Exportar variables: export DOCKER_USERNAME=usuario IMAGE_TAG=1.0.0 STACK_NAME=wordpress
Desplegar: docker stack deploy -c docker-stack.yml wordpress
