#!/bin/bash
set -e

./validate-env.sh

./docker-login.sh

./build-images.sh

./push-images.sh

./swarm-init.sh

./stack-deploy.sh

./stack-services.sh

