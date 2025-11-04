#!/bin/bash
set -e

if [ -f /run/secrets/app.env ]; then
    export $(grep -v '^#' /run/secrets/app.env | xargs)
    export WORDPRESS_DB_PASSWORD="${MYSQL_PASSWORD}"
    export WORDPRESS_ADMIN_PASSWORD="${WORDPRESS_ADMIN_PASSWORD}"
fi

echo "Esperando a que MySQL esté disponible..."
sleep 30

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Creando wp-config.php..."
    
    wp config create \
        --dbname="wordpress" \
        --dbuser="wpuser" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="mysql:3306" \
        --dbprefix="wp_" \
        --allow-root
    
    echo "wp-config.php creado exitosamente"
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Instalando WordPress..."
    
    wp core install \
        --url="http://localhost" \
        --title="WordPress Cluster Demo" \
        --admin_user="admin" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="admin@example.com" \
        --skip-email \
        --allow-root
    
    echo "Creando posts de prueba..."
    wp post create \
        --post_title="Bienvenido al Cluster" \
        --post_content="Este es un post de prueba creado automáticamente." \
        --post_status=publish \
        --allow-root
    
    wp post create \
        --post_title="Arquitectura del Sistema" \
        --post_content="WordPress + MySQL + phpMyAdmin + Uptime Kuma + MailHog" \
        --post_status=publish \
        --allow-root
    
    echo "Creando usuarios de prueba..."
    wp user create editor editor@example.com \
        --role=editor \
        --user_pass=editor123 \
        --allow-root
    
    wp user create author author@example.com \
        --role=author \
        --user_pass=author123 \
        --allow-root
    
    echo "Seeds completados exitosamente"
else
    echo "WordPress ya está instalado"
fi
