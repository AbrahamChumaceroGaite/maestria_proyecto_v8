FROM php:8.2-fpm-alpine

RUN apk add --no-cache nginx curl bash mysql-client && \
    docker-php-ext-install mysqli pdo pdo_mysql opcache

RUN mkdir -p /run/nginx /var/www/html

COPY php.ini /usr/local/etc/php/conf.d/custom.ini
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/html

RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

RUN mkdir -p /var/www/html/wp-content/uploads && \
    mkdir -p /var/www/html/wp-content/upgrade && \
    mkdir -p /var/www/html/wp-content/plugins && \
    mkdir -p /var/www/html/wp-content/themes && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 /var/www/html/wp-content

EXPOSE 80

CMD php-fpm -D && nginx -g 'daemon off;'
