#!/bin/bash
set -e

# Leer secrets nativos de Docker
if [ -f /run/secrets/mysql_password ]; then
    export WORDPRESS_DB_PASSWORD="$(cat /run/secrets/mysql_password)"
else
    WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-changeme}"
fi

if [ -f /run/secrets/wp_admin_password ]; then
    export WORDPRESS_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
else
    WORDPRESS_ADMIN_PASSWORD="${WORDPRESS_ADMIN_PASSWORD:-admin123}"
fi

echo "Esperando a que MySQL esté disponible..."
sleep 30

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Creando wp-config.php..."
    
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --dbprefix="${WORDPRESS_TABLE_PREFIX}" \
        --allow-root
    
    echo "wp-config.php creado"
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Instalando WordPress..."
    
    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    
    echo "Creando posts de prueba..."
    wp post create \
        --post_title="Bienvenido al Cluster" \
        --post_content="Este es un post de prueba creado automáticamente." \
        --post_status=publish \
        --allow-root || true
    
    wp post create \
        --post_title="Arquitectura del Sistema" \
        --post_content="WordPress + MySQL + phpMyAdmin + Uptime Kuma + MailHog" \
        --post_status=publish \
        --allow-root || true
    
    echo "Creando usuarios de prueba..."
    wp user create editor editor@example.com \
        --role=editor \
        --user_pass=editor123 \
        --allow-root || true
    
    wp user create author author@example.com \
        --role=author \
        --user_pass=author123 \
        --allow-root || true
    
    echo "Inicialización completada"
else
    echo "WordPress ya está instalado"
fi
