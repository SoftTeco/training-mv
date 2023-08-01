FROM wordpress:php7.1-apache

WORKDIR /var/www
#ADD all dependence files and folders ( plugins and cors enabled )
COPY addition_files/functions.php /var/www/html/wp-includes/
COPY plugins/any-hostname /var/www/html/wp-content/plugins/
COPY plugins/wp-graphql /var/www/html/wp-content/plugins/
COPY addition_files/.htaccess /var/www/html/
#multi command script to run entrypoint
COPY entrypoint-script.sh /var/www/
RUN chmod 777 /var/www/entrypoint-script.sh

ENTRYPOINT ["./entrypoint-script.sh"]
#-------------------------------------------
