#!/bin/bash

apt-get update
apt-get install sudo
#sudo su
sudo chmod 666 /etc/apache2/apache2.conf
sudo echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
sudo service apache2 reload
