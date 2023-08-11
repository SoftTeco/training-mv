#!/bin/sh

/etc/init.d/apache2 start
sudo chmod 666 /etc/apache2/apache2.conf
sudo echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
sudo sed -i -e '6 s/^/Listen 8000\n/;' /etc/apache2/ports.conf
#sudo sed -i -e '6 s/^/Listen 81\n/;' /etc/apache2/ports.conf
sudo ln -s /etc/apache2/sites-available/wordpress.conf /etc/apache2/sites-enabled/wordpress.conf
sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default

#sudo echo "define( 'WP_HOME', 'http://localhost:8000' );" >> wp-config.php
#sudo echo "define( 'WP_SITEURL', 'http://localhost:8000' );" >> wp-config.php

sudo /etc/init.d/apache2 reload
sudo /etc/init.d/apache2 restart

sudo service mysql start

/bin/bash
