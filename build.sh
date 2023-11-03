#!/bin/bash

source .env

tag=local:8.2.9-apache-arm64

docker ps -a | awk '{ print $1,$2 }' | grep $tag | awk '{print $1 }' | xargs -I {} docker stop {}
docker ps -a | awk '{ print $1,$2 }' | grep $tag | awk '{print $1 }' | xargs -I {} docker rm {}

docker build . \
  --file Dockerfile \
  --build-arg ARCH=arm64 \
  --tag $tag

docker run \
  -it \
  -d \
  -p 8080:80 \
  -v $(pwd)/app:/var/www/html \
  $tag
