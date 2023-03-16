FROM wordpress:6.1.1

LABEL maintainer="Max-test1"

WORKDIR /var/www/html
#ADD all dependence files and folders ( plugins and cors enabled )
COPY wordpress_Dockerfile_folder/functions.php /var/www/html/wp-includes/
COPY wordpress_Dockerfile_folder/any-hostname/ /var/www/html/wp-content/plugins/
COPY wordpress_Dockerfile_folder/wp-graphql/ /var/www/html/wp-content/plugins/
COPY wordpress_Dockerfile_folder/.htaccess /var/www/html/

#-------------------------------------------
