#!/bin/bash
set -e

./create-cluster.sh

./build-images.sh

./deploy.sh

./status.sh

