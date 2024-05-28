To address the issue where your WordPress site running on GitHub Codespaces is returning `localhost` instead of the forwarded URL, you need to handle the forwarded headers correctly. This can be done by configuring your NGINX to set the correct headers or by modifying WordPress to handle these headers properly.

### Solution 1: Configuring NGINX to Handle Forwarded Headers

You can configure NGINX to correctly pass the `Host` and `X-Forwarded-Proto` headers. This tells WordPress to use the forwarded host and protocol.

1. **Edit your NGINX configuration:**

    Add the following directives to your NGINX server block for the HTTPS server:

    ```nginx
    server {
        listen 443 ssl;
        server_name psychic-space-meme-7v76jrj4j9rqfqj7-443.app.github.dev;

        # SSL configuration
        ssl_certificate /etc/nginx/ssl/nginx.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx.key;

        root /var/www/html;

        index index.php index.html index.htm;

        # Set the Host and X-Forwarded-Proto headers
        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param HTTP_HOST $http_host;
            fastcgi_param HTTPS on;
        }

        location ~ /\.ht {
            deny all;
        }
    }
    ```

2. **Restart NGINX:**

    After updating the NGINX configuration, restart the NGINX service to apply the changes.

    ```sh
    sudo service nginx restart
    ```

### Solution 2: Configuring WordPress to Use Forwarded Headers

WordPress can be configured to respect the `X-Forwarded-Host` and `X-Forwarded-Proto` headers, which are commonly used in reverse proxy setups. You can achieve this by adding some custom PHP code to your `wp-config.php`.

1. **Edit `wp-config.php`:**

    Add the following code to the top of your `wp-config.php` file (before the `/* That's all, stop editing! Happy blogging. */` line):

    ```php
    if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
        $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
    }

    if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
        $_SERVER['HTTPS'] = 'on';
    }
    ```

### Explanation

- **NGINX Configuration:**
  - The `proxy_set_header` directives ensure that the `Host` and `X-Forwarded-Proto` headers are correctly set. This tells WordPress about the forwarded host and protocol.
  - The `fastcgi_param` directives ensure that the FastCGI PHP processor also gets these headers.

- **WordPress Configuration:**
  - The code in `wp-config.php` adjusts the `$_SERVER` variables to use the values provided by the forwarding headers, effectively telling WordPress to use the forwarded host and protocol instead of the local ones.

### Summary

By correctly configuring NGINX to pass the right headers and modifying WordPress to respect these headers, you should be able to resolve the issue where WordPress is returning `localhost` instead of the forwarded URL. This setup ensures that your site works correctly behind a reverse proxy like the one used in GitHub Codespaces.