#!/bin/bash

# import
<%= import 'helpers.sh' %>

echo "Europe/Berlin" | tee /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

echo "---------------------------------------------------------------"
echo "---------------- SYSTEM UPDATE/UPGRADE ------------------------"
echo "---------------------------------------------------------------"
system_update

echo "---------------------------------------------------------------"
echo "----------------- INSTALL SYSTEM TOOLS ------------------------"
echo "---------------------------------------------------------------"
apt-get -qy install curl git zip

echo "--------------------------------------------------------------"
echo "---------------------- APACHE2 INSTALL -----------------------"
echo "--------------------------------------------------------------"

apt-get -qy install apache2
a2enmod rewrite

adduser vagrant www-data && adduser www-data vagrant

APACHEUSR=`grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars`
APACHEGRP=`grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars`
if [ APACHEUSR ]; then
    sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
fi
if [ APACHEGRP ]; then
    sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
fi
chown -R vagrant:www-data /var/lock/apache2
chown -R vagrant:www-data /var/www

echo "--------------------------------------------------------------"
echo "------------- Starting installation of symfonybox ------------"
echo "--------------------------------------------------------------"

# php 7.0
apt-get -qy install php-common php7.0-common php7.0 libapache2-mod-php7.0 php7.0-cli php7.0-mysql php7.0-mcrypt php7.0-intl php-imagick php-gd php7.0-curl php7.0-mbstring php7.0-dom php7.0-zip php7.0-soap php-xdebug 2> /dev/null

# node package manager
apt-get -qy install npm --assume-yes 2> /dev/null

# nodejs
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get -qy install nodejs 2> /dev/null

# node version manager
npm install n -g 2> /dev/null

# ruby
apt-get -qy install ruby 2> /dev/null

# mysql client
apt-get -qy install mysql-client-core-5.7

# Tune PHP-settings
php-settings-update 'max_input_vars' '1500'
php-settings-update 'always_populate_raw_post_data' '-1'
php-settings-update 'max_execution_time' '240'

/etc/init.d/apache2 restart

# install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install sass (scss) via ruby gem
gem install sass -v 3.4.19

echo "--------------------------------------------------------------"
echo "------------------- INSTALL BOWER/GRUNT ----------------------"
echo "--------------------------------------------------------------"

/usr/bin/npm install -g bower
/usr/bin/npm install -g grunt-cli

echo "--------------------------------------------------------------"
echo "---------------------- CLONE GIT REPO ------------------------"
echo "--------------------------------------------------------------"

ssh-keyscan github.com >> ~/.ssh/known_hosts

mkdir /var/www/checkout/ && cd /var/www/checkout/
git clone -q git@github.com:ewildcard/symfonybox.git

echo "--------------------------------------------------------------"
echo "---------------------- RSYNC CHECKOUT ------------------------"
echo "--------------------------------------------------------------"

/usr/bin/rsync -avz /var/www/checkout/symfonybox/. /var/www/symfonybox/

echo "--------------------------------------------------------------"
echo "----------------------- COMPOSER UPDATE ----------------------"
echo "--------------------------------------------------------------"

cd /var/www/symfonybox/Source
composer update

echo "--------------------------------------------------------------"
echo "----------------------- BOWER INSTALL ------------------------"
echo "--------------------------------------------------------------"

cd /var/www/symfonybox/Source
bower install --allow-root

echo "--------------------------------------------------------------"
echo "------------------------- NPM INSTALL ------------------------"
echo "--------------------------------------------------------------"

cd /var/www/symfonybox/Source
npm install

echo "--------------------------------------------------------------"
echo "----------------------- SET PERMISSIONS ----------------------"
echo "--------------------------------------------------------------"

cd /var/www/symfonybox/ && find -type d -print0 | xargs -0 chmod 2775 && find -type f -print0 | xargs -0 chmod 0664

chown -R vagrant:www-data /var/www/symfonybox

echo "--------------------------------------------------------------"
echo "---------------------- INSTALL VHOST -------------------------"
echo "--------------------------------------------------------------"

cp /vagrant/files/apache/symfony.conf /etc/apache2/sites-available/symfony.conf

echo -e "\n--- Disable default site ---"
a2dissite 00*
echo -e "\n--- Enable Camper site ---"
a2ensite symfony.conf
/etc/init.d/apache2 restart