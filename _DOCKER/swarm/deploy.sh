#!/bin/bash
set -e

echo "=== WordPress Swarm Deployment ==="
echo ""

if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker not running"
    exit 1
fi

echo "Step 1/4: Initializing Docker Swarm..."
SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || echo "inactive")

if [ "$SWARM_STATUS" = "active" ]; then
    echo "Swarm already active"
    docker node ls
else
    echo "Initializing Swarm..."
    docker swarm init 2>/dev/null || docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')
    echo "Swarm initialized"
    docker node ls
fi

echo ""
echo "Step 2/4: Creating secrets..."

if [ -f "../.env" ]; then
    source ../.env
    echo "Reading credentials from ../.env"
else
    echo "Error: ../.env not found"
    exit 1
fi

docker secret rm mysql_root_password 2>/dev/null || true
docker secret rm mysql_password 2>/dev/null || true
docker secret rm wp_admin_password 2>/dev/null || true

echo "${MYSQL_ROOT_PASSWORD}" | docker secret create mysql_root_password -
echo "${MYSQL_PASSWORD}" | docker secret create mysql_password -
echo "${WORDPRESS_ADMIN_PASSWORD}" | docker secret create wp_admin_password -

echo "Secrets created:"
docker secret ls

echo ""
echo "Step 3/4: Verifying images..."
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
    echo "Error: Missing images:"
    printf '%s\n' "${MISSING_IMAGES[@]}"
    echo "Run: cd ../ && docker-compose build"
    exit 1
fi

echo "Images OK"

echo ""
echo "Step 4/4: Deploying stack..."
docker stack deploy -c docker-compose.swarm.yml wordpress

echo ""
echo "Waiting for services..."
sleep 15

echo ""
docker stack services wordpress
echo ""
docker stack ps wordpress --no-trunc | head -20

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Access:"
echo "  http://localhost          - WordPress"
echo "  http://localhost:8080     - phpMyAdmin"
echo "  http://localhost:3001     - Uptime Kuma"
echo "  http://localhost:8025     - MailHog"
echo ""
echo "Commands:"
echo "  docker service logs wordpress_wordpress"
echo "  docker service scale wordpress_wordpress=5"
echo "  docker stack rm wordpress"