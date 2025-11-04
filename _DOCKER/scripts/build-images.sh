#!/bin/bash
set -e

source ../.env

cd ..

docker build -t ${DOCKER_USERNAME}/wordpress-mysql:${IMAGE_TAG} ./services/mysql
docker build -t ${DOCKER_USERNAME}/wordpress-app:${IMAGE_TAG} ./services/wordpress
docker build -t ${DOCKER_USERNAME}/wordpress-phpmyadmin:${IMAGE_TAG} ./services/phpmyadmin
docker build -t ${DOCKER_USERNAME}/wordpress-uptime:${IMAGE_TAG} ./services/uptime-kuma
docker build -t ${DOCKER_USERNAME}/wordpress-mailhog:${IMAGE_TAG} ./services/mailhog
docker build -t ${DOCKER_USERNAME}/wordpress-cli:${IMAGE_TAG} ./services/wp-cli

docker images | grep ${DOCKER_USERNAME}

