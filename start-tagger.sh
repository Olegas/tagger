#!/bin/sh

./wait-for-it.sh db:3306 -t 30 
if [ $? -ne 0 ]; then
 exit 1
fi

./bin/console doctrine:query:sql "SELECT 1 FROM users LIMIT 1"
if [ $? -ne 0 ]; then
 ./bin/console doctrine:schema:create
 ./bin/console fos:user:create admin admin@example.com admin
 ./bin/console fos:user:promote admin ROLE_ADMIN
fi

apache2-foreground

