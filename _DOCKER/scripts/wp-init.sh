#!/bin/bash
set -e

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

echo "Waiting for MySQL..."
sleep 30

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --dbprefix="${WORDPRESS_TABLE_PREFIX}" \
        --allow-root
    
    echo "wp-config.php created"
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    
    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    
    echo "Creating test posts..."
    wp post create \
        --post_title="Welcome to Cluster" \
        --post_content="Test post created automatically." \
        --post_status=publish \
        --allow-root || true
    
    wp post create \
        --post_title="System Architecture" \
        --post_content="WordPress + MySQL + phpMyAdmin + Uptime Kuma + MailHog" \
        --post_status=publish \
        --allow-root || true
    
    echo "Creating test users..."
    wp user create editor editor@example.com \
        --role=editor \
        --user_pass=editor123 \
        --allow-root || true
    
    wp user create author author@example.com \
        --role=author \
        --user_pass=author123 \
        --allow-root || true
    
    echo "Initialization completed"
else
    echo "WordPress already installed"
fi