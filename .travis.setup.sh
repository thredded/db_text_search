#!/usr/bin/env bash
if [ "$DB" = 'mysql2' ]; then
  mysql -u root -e "CREATE USER 'travis'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY ''"
  mysql -u root -e "GRANT ALL ON travis.* TO 'travis'@'%';"
fi
