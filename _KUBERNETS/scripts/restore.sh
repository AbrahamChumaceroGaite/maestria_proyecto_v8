#!/bin/bash

if [ -z "$1" ]; then
  exit 1
fi

BACKUP_FILE=$1

kubectl exec -i -n wordpress mysql-0 -- mysql -u root -pchangeme_root_password wordpress < $BACKUP_FILE

