#!/bin/sh

# Create directories if they do not exist
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
mkdir -p /etc/nginx/ssl

# Start NGINX
nginx -g "daemon off;"
