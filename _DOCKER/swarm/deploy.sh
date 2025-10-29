#!/bin/bash
set -e

echo "=== Despliegue WordPress en Docker Swarm ==="
echo ""

# Verificar Docker
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker no está corriendo"
    exit 1
fi

# Paso 1: Inicializar Swarm
echo "Paso 1/4: Inicializando Docker Swarm..."
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || echo "inactive")

if [ "$SWARM_STATUS" = "active" ]; then
    echo "Swarm ya está activo"
    docker node ls
else
    echo "Inicializando Swarm..."
    docker swarm init 2>/dev/null || docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')
    echo "Swarm inicializado"
    docker node ls
fi

echo ""

# Paso 2: Crear secrets
echo "Paso 2/4: Creando secrets..."

# Leer del .env en raíz
if [ -f "../.env" ]; then
    source ../.env
    echo "Leyendo credenciales de ../.env"
else
    echo "Error: No se encuentra ../.env"
    exit 1
fi

# Eliminar secrets existentes
docker secret rm mysql_root_password 2>/dev/null || true
docker secret rm mysql_password 2>/dev/null || true
docker secret rm wp_admin_password 2>/dev/null || true

# Crear secrets nativos
echo "${MYSQL_ROOT_PASSWORD}" | docker secret create mysql_root_password -
echo "${MYSQL_PASSWORD}" | docker secret create mysql_password -
echo "${WORDPRESS_ADMIN_PASSWORD}" | docker secret create wp_admin_password -

echo "Secrets creados:"
docker secret ls

echo ""

# Paso 3: Verificar imágenes
echo "Paso 3/4: Verificando imágenes..."
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
    echo "Error: Faltan imágenes:"
    printf '%s\n' "${MISSING_IMAGES[@]}"
    echo "Ejecuta: cd ../ && docker-compose build"
    exit 1
fi

echo "Imágenes OK"

echo ""

# Paso 4: Desplegar
echo "Paso 4/4: Desplegando stack..."
docker stack deploy -c docker-compose.swarm.yml wordpress

echo ""
echo "Esperando servicios..."
sleep 15

echo ""
docker stack services wordpress
echo ""
docker stack ps wordpress --no-trunc | head -20

echo ""
echo "=== Completado ==="
echo ""
echo "Acceso:"
echo "  http://localhost          - WordPress"
echo "  http://localhost:8080     - phpMyAdmin"
echo "  http://localhost:3001     - Uptime Kuma"
echo "  http://localhost:8025     - MailHog"
echo ""
echo "Comandos:"
echo "  docker service logs wordpress_wordpress"
echo "  docker service scale wordpress_wordpress=5"
echo "  docker stack rm wordpress"
