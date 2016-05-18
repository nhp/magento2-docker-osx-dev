#!/bin/bash

# Show what we execute
set -ex

DB_NAME="magento"

# MySQL authentication
MYSQLAUTH="--user=$MYSQL_USER --password=$MYSQL_PASSWORD"

# Wait for MySQL to come up.
echo " "
printf 'Waiting for MySQL to become available'
until mysql $MYSQLAUTH -e ""; do
    sleep 1
done
echo " "

# Check if db exists, if not run install script
RESULT=`mysql $MYSQLAUTH -e "SHOW DATABASES" | grep -Fo $DB_NAME`
if [ "$RESULT" != "$DB_NAME" ]; then
   echo "Database does not exist."
   echo "Creating DB and running magento setup:install"
   mysql $MYSQLAUTH -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"

   cd /var/www/magento2/htdocs
   bin/magento setup:install \
   --db-host=mysql \
   --db-name="$DB_NAME" \
   --db-user="$MYSQL_USER" \
   --db-password="$MYSQL_PASSWORD" \
   --backend-frontname=admin \
   --base-url=http://$PUBLIC_HOST/ \
   --admin-lastname=Smith \
   --admin-firstname=John \
   --admin-email=john.smith@example.com \
   --admin-user=admin \
   --admin-password=magento2 
fi

# Check permissions again
find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
chown www-data:www-data -R /var/www/magento2

# Switch to developer mode
cd ../bin && php magento deploy:mode:set developer && cd ../htdocs

# In production mode we pre-compute various files
php -f dev/tools/Magento/Tools/View/deploy.php
php -f dev/tools/Magento/Tools/Di/compiler.php

# Run the web server
exec /usr/sbin/apache2 -D FOREGROUND
