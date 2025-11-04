#!/bin/bash
set -e

if [ -f /run/secrets/app.env ]; then
    export $(grep -v '^#' /run/secrets/app.env | xargs)
    export WORDPRESS_DB_PASSWORD="${MYSQL_PASSWORD}"
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', 'mysql:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF

    SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    sed -i "/DB_COLLATE/a\\${SALTS}" /var/www/html/wp-config.php
    
    chown www-data:www-data /var/www/html/wp-config.php
    chmod 640 /var/www/html/wp-config.php
fi

php-fpm -D && nginx -g 'daemon off;'
