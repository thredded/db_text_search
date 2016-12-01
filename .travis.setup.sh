#!/usr/bin/env bash
if [ "$DB" = 'mysql2' ]; then
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''"
fi
