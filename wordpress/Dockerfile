FROM wordpress:php7.1-apache
#FROM wordpress:6.2.2-apache

WORKDIR /var/www/html
RUN apt-get update && \
    apt-get install sudo -y && \
    sudo apt-get install dialog apt-utils -y && \
    sudo apt install net-tools -y && \
    sudo apt-get install default-mysql-server -y 
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
#ADD all dependence files and folders ( plugins and cors enabled )
COPY addition_files/functions.php /var/www/html/wp-includes/
COPY plugins/any-hostname /var/www/html/wp-content/plugins/
COPY plugins/wp-graphql /var/www/html/wp-content/plugins/
COPY addition_files/.htaccess /var/www/html/
COPY 000-default.conf /etc/apache2/sites-available/
COPY wordpress.conf /etc/apache2/sites-available/
#multi command script to run entrypoint
COPY entrypoint-script.sh /usr/local/bin
RUN chmod 777 /usr/local/bin/entrypoint-script.sh
RUN /usr/local/bin/entrypoint-script.sh
#-------------------------------------------
