#!/bin/bash

## Stop and remove existing containers, networks, and volumes
# docker compose down --volumes

## Stop and remove existing containers, networks
docker compose down 


# Build containers without caching 
docker compose build --no-cache

# Build and recreate containers
docker compose up --build -d


## `docker compose down --volumes && docker compose up --build`  ==> you can use this command 
