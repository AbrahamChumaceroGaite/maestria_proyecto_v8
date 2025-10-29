#!/bin/bash
set -e

echo "=== Despliegue WordPress en Docker Swarm ==="
echo ""

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker no está corriendo"
    exit 1
fi

# Paso 1: Inicializar Swarm
echo "Paso 1/5: Inicializando Docker Swarm..."
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}')

if [ "$SWARM_STATUS" = "active" ]; then
    echo "Swarm ya está activo"
    docker node ls
else
    echo "Inicializando nuevo Swarm..."
    docker swarm init
    echo "Swarm inicializado correctamente"
    docker node ls
fi

echo ""

# Paso 2: Crear secrets
echo "Paso 2/5: Creando secrets..."
echo "Ingrese password para MySQL root:"
read -s MYSQL_ROOT_PASSWORD
echo "Ingrese password para usuario wpuser:"
read -s MYSQL_PASSWORD
echo "Ingrese password para admin de WordPress:"
read -s WP_ADMIN_PASSWORD

# Eliminar secrets existentes si existen
docker secret rm mysql_root_password 2>/dev/null || true
docker secret rm mysql_password 2>/dev/null || true
docker secret rm wp_admin_password 2>/dev/null || true

# Crear nuevos secrets
echo "$MYSQL_ROOT_PASSWORD" | docker secret create mysql_root_password -
echo "$MYSQL_PASSWORD" | docker secret create mysql_password -
echo "$WP_ADMIN_PASSWORD" | docker secret create wp_admin_password -

echo "Secrets creados correctamente"
docker secret ls

echo ""

# Paso 3: Verificar imágenes
echo "Paso 3/5: Verificando imágenes Docker..."
REQUIRED_IMAGES=(
    "wordpress-app:1.0.0"
    "wordpress-mysql:1.0.0"
    "wordpress-phpmyadmin:1.0.0"
    "wordpress-uptime:1.0.0"
    "wordpress-mailhog:1.0.0"
    "wordpress-cli:1.0.0"
)

MISSING_IMAGES=()
for IMAGE in "${REQUIRED_IMAGES[@]}"; do
    if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$IMAGE$"; then
        MISSING_IMAGES+=("$IMAGE")
    fi
done

if [ ${#MISSING_IMAGES[@]} -ne 0 ]; then
    echo "Error: Faltan las siguientes imágenes:"
    printf '%s\n' "${MISSING_IMAGES[@]}"
    echo ""
    echo "Construya las imágenes primero con:"
    echo "  docker-compose build"
    exit 1
fi

echo "Todas las imágenes están disponibles"

echo ""

# Paso 4: Desplegar stack
echo "Paso 4/5: Desplegando stack en Swarm..."
docker stack deploy -c docker-compose.swarm.yml wordpress

echo ""
echo "Esperando a que los servicios inicien..."
sleep 15

echo ""

# Paso 5: Verificar despliegue
echo "Paso 5/5: Verificando despliegue..."
docker stack services wordpress
echo ""
docker stack ps wordpress --no-trunc

echo ""
echo "=== Despliegue completado ==="
echo ""
echo "Acceder a:"
echo "  WordPress:   http://localhost"
echo "  phpMyAdmin:  http://localhost:8080"
echo "  Uptime Kuma: http://localhost:3001"
echo "  MailHog:     http://localhost:8025"
echo ""
echo "Comandos útiles:"
echo "  docker stack services wordpress    - Ver servicios"
echo "  docker stack ps wordpress          - Ver tareas"
echo "  docker service logs wordpress_wordpress  - Ver logs"
echo "  docker stack rm wordpress          - Eliminar stack"
