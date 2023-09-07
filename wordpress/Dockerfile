FROM wordpress:php7.1-apache

WORKDIR /var/www/html
RUN apt-get update && \
    apt-get install sudo -y && \
    sudo apt-get install dialog apt-utils -y && \
    sudo apt install net-tools -y && \
    sudo apt install openrc -y && \
    sudo apt-get install mariadb-server -y

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-mysqldb && \
    apt-get install -y gnupg2 && \
    apt-get install -y dbus && \
    export RUNLEVEL=1
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d



#ADD all dependence files and folders ( plugins and cors enabled )
COPY addition_files/functions.php /var/www/html/wp-includes/
COPY plugins/any-hostname /var/www/html/wp-content/plugins/
COPY plugins/wp-graphql /var/www/html/wp-content/plugins/
COPY addition_files/.htaccess /var/www/html/
COPY 000-default.conf /etc/apache2/sites-available/
COPY wordpress.conf /etc/apache2/sites-available/
COPY entrypoint-script.sh /usr/local/bin/
RUN sudo chown www-data: /var/www/html

#apache commands execution
RUN sudo ln -s /etc/apache2/sites-available/wordpress.conf /etc/apache2/sites-enabled/wordpress.conf && \
    sudo a2ensite wordpress && \
    sudo a2enmod rewrite && \
    sudo a2dissite 000-default && \
    sudo chmod 666 /etc/apache2/apache2.conf

#RUN sudo service mysql start
#mysql sockets
# RUN sudo mkdir /var/run/mysqld && \
#     sudo touch /var/run/mysqld/mysqld.sock && \
#     sudo touch /var/run/mysqld/mysqld.pid && \
#     sudo chown -R mysql:mysql /var/run/mysqld/mysqld.sock && \
#     sudo chown -R mysql:mysql /var/run/mysqld/mysqld.pid && \
#     sudo chmod -R 777 /var/run/mysqld/mysqld.sock
#     #sudo mysql_secure_installation
    
#mysql reinstall    
# RUN sudo rm -rf /var/lib/mysql && sudo rm -r /etc/mysql && \
#     sudo apt purge mysql* -y && \
#     sudo apt purge mariadb* -y && \
#     #sudo apt-get remove --purge mariadb-server && \
#     #sudo apt-get --purge remove python-software-properties && \
#     #sudo apt-get clean && \
#     sudo apt autoremove -y && \
#     sudo apt autoclean -y && \
#     #sudo apt-get install python-software-properties -y && \
#     #sudo apt-get install software-properties-common -y && \
#     sudo apt install mariadb-server -y 
#     #sudo nc -lk /var/run/mysqld/mysqld.sock
#     #sudo service mysql restart

RUN sudo echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf && \
    sudo sed -i -e '6 s/^/Listen 8000\n/;' /etc/apache2/ports.conf

