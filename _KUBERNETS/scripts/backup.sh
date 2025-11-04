#!/bin/bash

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

kubectl exec -n wordpress mysql-0 -- mysqldump -u root -pchangeme_root_password wordpress > $BACKUP_DIR/wordpress_$TIMESTAMP.sql

tar -czf $BACKUP_DIR/wordpress_files_$TIMESTAMP.tar.gz -C /tmp/wordpress .

ls -lh $BACKUP_DIR

