FROM phpmyadmin:5-apache

COPY phpmyadmin-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/phpmyadmin-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/phpmyadmin-entrypoint.sh"]
CMD ["apache2-foreground"]
