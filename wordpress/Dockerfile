FROM wordpress:php7.1-apache
#FROM wordpress:6.2.2-apache

WORKDIR /var/www/html
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d
#ADD all dependence files and folders ( plugins and cors enabled )
COPY addition_files/functions.php /var/www/html/wp-includes/
COPY plugins/any-hostname /var/www/html/wp-content/plugins/
COPY plugins/wp-graphql /var/www/html/wp-content/plugins/
COPY addition_files/.htaccess /var/www/html/
RUN apt-get update && \
    install dialog apt-utils -y && \
    install sudo -y
#multi command script to run entrypoint
COPY entrypoint-script.sh /usr/local/bin
RUN chmod 777 /usr/local/bin/entrypoint-script.sh
RUN /usr/local/bin/entrypoint-script.sh
#RUN ln -s /usr/local/bin/entrypoint-script.sh /var/www/html

#CMD ["/bin/bash", "-c", "/usr/local/bin/entrypoint-script.sh"]
#ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/entrypoint-script.sh"]
#ENTRYPOINT [ "echo", "123" ]
#-------------------------------------------
