#!/bin/bash
set -e

./stack-remove.sh

sleep 10

./swarm-leave.sh

