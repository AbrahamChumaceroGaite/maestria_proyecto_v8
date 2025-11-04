#!/bin/bash
set -e

cd ../_DOCKER

docker build -t wordpress-mysql:1.0.0 ./services/mysql
docker build -t wordpress-app:1.0.0 ./services/wordpress
docker build -t wordpress-phpmyadmin:1.0.0 ./services/phpmyadmin
docker build -t wordpress-uptime:1.0.0 ./services/uptime-kuma
docker build -t wordpress-mailhog:1.0.0 ./services/mailhog
docker build -t wordpress-cli:1.0.0 ./services/wp-cli

docker tag wordpress-mysql:1.0.0 localhost:5000/wordpress-mysql:1.0.0
docker tag wordpress-app:1.0.0 localhost:5000/wordpress-app:1.0.0
docker tag wordpress-phpmyadmin:1.0.0 localhost:5000/wordpress-phpmyadmin:1.0.0
docker tag wordpress-uptime:1.0.0 localhost:5000/wordpress-uptime:1.0.0
docker tag wordpress-mailhog:1.0.0 localhost:5000/wordpress-mailhog:1.0.0
docker tag wordpress-cli:1.0.0 localhost:5000/wordpress-cli:1.0.0

docker push localhost:5000/wordpress-mysql:1.0.0
docker push localhost:5000/wordpress-app:1.0.0
docker push localhost:5000/wordpress-phpmyadmin:1.0.0
docker push localhost:5000/wordpress-uptime:1.0.0
docker push localhost:5000/wordpress-mailhog:1.0.0
docker push localhost:5000/wordpress-cli:1.0.0

