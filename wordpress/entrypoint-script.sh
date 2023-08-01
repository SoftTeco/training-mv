#!/bin/bash

echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
service apache2 reload
