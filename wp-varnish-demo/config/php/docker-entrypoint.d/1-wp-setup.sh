#!/bin/sh

# check wp cli is installed
if ! wp --version; then
    echo "wp cli is not installed"
    exit 1
fi

cd /var/www/public

# check wp is installed
if ! wp core is-installed; then
    echo "==== wp is not installed ===="
    echo " Installing wordpress ...."
    wp core download
    # wp core config --dbname=wp_demo --dbuser=wp_demo --dbpass=wp_demo
    # wp core install --url=wp.localhost --title=WP_Demo --admin_user=admin --admin_password=admin --admin_email=admin@example.com
    # wp theme install twentytwentytwo --activate
    # wp plugin install --activate wp-varnish
    # wp plugin install --activate varnish-http-purge
fi


