#!/bin/sh

#hostname=`hostname -I | awk '{print $1}'`
/etc/init.d/apache2 start
#sudo service apache2 restart
#sudo su
sudo chmod 666 /etc/apache2/apache2.conf
sudo echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
sudo sed -i -e '6 s/^/Listen 8000\n/;' /etc/apache2/ports.conf
sudo ln -s /etc/apache2/sites-available/wordpress.conf /etc/apache2/sites-enabled/wordpress.conf
#sudo echo "ServerName $hostname" >> /etc/apache2/apache2.conf
#sudo service apache2 restart
sudo /etc/init.d/apache2 reload
