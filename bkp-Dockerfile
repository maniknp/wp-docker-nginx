FROM wordpress:php8.0-fpm-alpine

# Install necessary packages
RUN apk update && apk add --no-cache \
    bash \
    less \
    mariadb-client \
    nginx \
    su-exec

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Add nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Add entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
