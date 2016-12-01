#!/usr/bin/env bash
if [ "$DB" = 'mysql2' ]; then
  mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('')"
fi
