#!/bin/sh

# See also http://alankent.wordpress.com/2014/08/02/magento-2-progress-towards-installation-via-composer/

cd /var/www/magento2 

rm -rf htdocs
curl -sS https://getcomposer.org/installer | php
export COMPOSER_HOME=.
php composer.phar create-project --repository-url=https://repo.magento.com/ magento/project-community-edition htdocs
rm -rf auth.json

# Swap to developer mode for better error diagnostics
#echo "SetEnv MAGE_MODE production" >> .htaccess
echo "SetEnv MAGE_MODE developer" >> htdocs/.htaccess

chown www-data:www-data -R /var/www/magento2
cd htdocs
find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
