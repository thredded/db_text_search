#!/usr/bin/env bash
if [ "$DB" = 'mysql2' ]; then
  # work around https://github.com/travis-ci/travis-ci/issues/6961
  mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('')"
fi
