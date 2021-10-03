#!/bin/bash
set -e

# Execute case script

echo "> Create case directory"
DOCKER_CERTS=${PWD}\cache\certs

echo "Download docker-in-docker"
docker pull docker:dind
docker pull docker:latest

echo "> Create docker network and volume"
[ $(docker network ls | grep docker-test-network | wc -l) -eq 0 ] && docker network create docker-test-network
[ $(docker volume ls | grep docker-library | wc -l) -eq 0 ] && docker volume create docker-library

echo "> Remove legacy container"
docker rm -f docker-in-docker-daemon

echo "> Run docker-in-docker"
docker run \
    --privileged \
    --detach \
    --name docker-in-docker-daemon \
    --network docker-test-network \
    --network-alias docker \
    -e DOCKER_TLS_CERTDIR=/certs \
    -v ${DOCKER_CERTS}:/certs \
    -v docker-library:/var/lib/docker \
    docker:dind

echo "> Call hello world in docker-in-docker"
docker run -ti --rm \
  --network docker-test-network \
  -e DOCKER_TLS_CERTDIR=/certs \
  -v ${DOCKER_CERTS}:/certs:ro \
  docker:latest sh -c "docker version"

echo "> Show directory in docker-in-docker call container"
docker run -ti --rm \
  --network docker-test-network \
  -e DOCKER_TLS_CERTDIR=/certs \
  -v ${DOCKER_CERTS}:/certs:ro \
  -v ${PWD}:/repo \
  docker:latest sh -c "docker pull bash && docker run -ti --rm -v /repo:/repo bash -l -c 'ls /repo -al'"

echo "> Show directory in docker-in-docker container"
docker run -ti --rm \
  --network docker-test-network \
  -e DOCKER_TLS_CERTDIR=/certs \
  -v ${DOCKER_CERTS}:/certs:ro \
  -v ${PWD}:/repo \
  docker:latest sh -c "ls /repo -al"
