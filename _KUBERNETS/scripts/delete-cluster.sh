#!/bin/bash
set -e

k3d cluster delete wordpress-cluster

k3d registry delete registry.localhost || true

