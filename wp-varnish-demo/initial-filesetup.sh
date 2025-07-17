#!/bin/bash

# Check if user 'www-data' exists
if id "www-data" &>/dev/null; then
    echo "User 'www-data' already exists."
else
    echo "User 'www-data' does not exist. Creating..."
    sudo useradd --system --no-create-home --shell /usr/sbin/nologin www-data
    echo "User 'www-data' created successfully."
fi


### Making shell script executable 
sudo chmod +x ./../inotify-brotli-compose/watch_and_compress.sh
sudo chmod +x ./../wp-varnish-demo/config/php/docker-entrypoint.d/1-wp-setup.sh
sudo chmod +x ./../wp-varnish-demo/config/php/docker-entrypoint.d/2-wp-setup.sh
sudo chmod +x ./../wp-varnish-demo/config/php/docker-php-entrypoint.sh


# Get the current user
CURRENT_USER=$(whoami)

# Add current user to www-data group
echo "Adding user '$CURRENT_USER' to 'www-data' group..."
sudo usermod -aG www-data "$CURRENT_USER"

echo "✅ User '$CURRENT_USER' has been added to 'www-data' group."


##  wordpress installation folder ownership change 
sudo chown -R "$CURRENT_USER":www-data ./../wp-varnish-demo/wp
sudo chmod -R g+w  ./../wp-varnish-demo/wp

