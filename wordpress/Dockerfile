FROM wordpress:6.1.1

WORKDIR /var/www/html
#ADD all dependence files and folders ( plugins and cors enabled )
COPY addition_files/functions.php /var/www/html/wp-includes/
COPY plugins/any-hostname/ /var/www/html/wp-content/plugins/
COPY plugins/wp-graphql/ /var/www/html/wp-content/plugins/
COPY addition_files/.htaccess /var/www/html/

#-------------------------------------------
