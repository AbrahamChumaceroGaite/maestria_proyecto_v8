#!/bin/bash
set -e

if [ -f /run/secrets/mysql_password ]; then
    export WORDPRESS_DB_PASSWORD="$(cat /run/secrets/mysql_password)"
else
    WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-changeme}"
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    
    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

\$table_prefix = '${WORDPRESS_TABLE_PREFIX}';

define('WP_DEBUG', false);

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

    SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/ || echo "")
    if [ -n "$SALTS" ]; then
        sed -i "/DB_COLLATE/a\\${SALTS}" /var/www/html/wp-config.php
    fi
    
    chown www-data:www-data /var/www/html/wp-config.php
    chmod 640 /var/www/html/wp-config.php
    
    echo "wp-config.php created"
fi

php-fpm -D && nginx -g 'daemon off;'