#!/bin/bash

source .env

tag=local/apache-php-mod:latest
tag_xdebug=local/apache-php-mod-xdebug:latest

echo $tag_xdebug;

docker ps -a | awk '{ print $1,$2 }' | grep $tag | awk '{print $1 }' | xargs -I {} docker stop {}
docker ps -a | awk '{ print $1,$2 }' | grep $tag | awk '{print $1 }' | xargs -I {} docker rm {}

#docker build . \
#  --file Dockerfile \
#  --tag $tag

docker build . \
  --file Dockerfile \
  --build-arg ENABLE_XDEBUG=yes \
  --no-cache \
  --tag $tag_xdebug

#
#docker buildx create --use
#
#docker buildx build . \
#  --file Dockerfile \
#  --platform linux/arm64 \
#  --tag $tag
#
#docker buildx build . \
#  --file Dockerfile \
#  --build-arg ENABLE_XDEBUG=yes \
#  --platform linux/arm64 \
#  --tag $tag_xdebug
