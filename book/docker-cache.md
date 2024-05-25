Docker can indeed cache layers and configurations, which might cause delays in reflecting changes. To ensure your Nginx configuration changes are applied immediately, you can follow these steps to clear any potential caching issues and force Docker to reload the configurations properly.

### Steps to Ensure Docker Reflects Configuration Changes

1. **Ensure Configuration File is Correct**:
    - Double-check the content of your `nginx.conf` file in the `nginx-conf` directory.

2. **Stop and Remove Containers**:
    - Stop and remove the running containers to clear any old configurations.

    ```bash
    docker-compose down
    ```

3. **Rebuild the Docker Image**:
    - Rebuild the Docker image to ensure that any cached layers are refreshed.

    ```bash
    docker-compose build --no-cache
    ```

4. **Restart the Docker Containers**:
    - Start the Docker containers again.

    ```bash
    docker-compose up -d
    ```

5. **Clear Browser Cache**:
    - Sometimes, browsers cache the responses. To ensure you're seeing the latest response, clear your browser cache or open an incognito/private window.

### Example Steps

Here's a complete step-by-step process:

1. **Stop and Remove Containers**:

    ```bash
    docker-compose down
    ```

2. **Rebuild the Docker Image**:

    ```bash
    docker-compose build --no-cache
    ```

3. **Restart the Docker Containers**:

    ```bash
    docker-compose up -d
    ```

4. **Clear Browser Cache**:
    - Use the following shortcuts to clear cache:
        - **Chrome**: `Ctrl+Shift+R` or `Cmd+Shift+R` (Mac)
        - **Firefox**: `Ctrl+Shift+R` or `Cmd+Shift+R` (Mac)
        - **Edge**: `Ctrl+Shift+R`
        - **Safari**: `Cmd+Option+E`

### Docker Compose File Example

Ensure your `docker-compose.yml` file is correctly set up:

```yaml
version: '3'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-conf/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - wordpress
    networks:
      - wpsite

  wordpress:
    image: wordpress:latest
    ports:
      - "8000:80"
    networks:
      - wpsite

networks:
  wpsite:
    driver: bridge
```

### Nginx Configuration File Example

Ensure your `nginx.conf` in the `nginx-conf` directory is correctly set up:

```nginx
events {}

http {
    server {
        listen 80;
        server_name test.localhost;

        location / {
            return 200 'This is the test text for test.localhost';
            add_header Content-Type text/plain;
        }
    }
}
```

### Final Verification

1. **Navigate to the Subdomain**:
    - Open a web browser and navigate to `http://test.localhost`.

2. **Check the Response**:
    - You should see the text "This is the test text for test.localhost".

By following these steps, you should be able to ensure that Docker does not cache old configurations and your changes are reflected immediately.