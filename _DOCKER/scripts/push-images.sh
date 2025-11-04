#!/bin/bash
set -e

source ../.env

docker push ${DOCKER_USERNAME}/wordpress-mysql:${IMAGE_TAG}
docker push ${DOCKER_USERNAME}/wordpress-app:${IMAGE_TAG}
docker push ${DOCKER_USERNAME}/wordpress-phpmyadmin:${IMAGE_TAG}
docker push ${DOCKER_USERNAME}/wordpress-uptime:${IMAGE_TAG}
docker push ${DOCKER_USERNAME}/wordpress-mailhog:${IMAGE_TAG}
docker push ${DOCKER_USERNAME}/wordpress-cli:${IMAGE_TAG}

