#!/bin/bash

# Stop and remove existing containers, networks, and volumes
docker compose down --volumes

docker volume prune -f

# Build and recreate containers
docker compose up --build -d


## `docker compose down --volumes && docker compose up --build`  ==> you can use this command 
