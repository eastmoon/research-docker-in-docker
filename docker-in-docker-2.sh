#!/bin/bash
set -e

# Execute case script

echo "> Create case directory"
DOCKER_CERTS=${PWD}\cache\certs

echo "Download docker-in-docker"
docker pull docker:dind

echo "> Build docker control"
docker build --rm \
    -t docker-control:research-docker-in-docker \
    ./docker

echo "> Create docker network and volume"
[ $(docker network ls | grep docker-test-network | wc -l) -eq 0 ] && docker network create docker-test-network
[ $(docker volume ls | grep docker-library | wc -l) -eq 0 ] && docker volume create docker-library

echo "> Remove legacy container"
docker rm -f docker-in-docker-daemon
docker rm -f docker-in-docker-control

echo "> Run docker-in-docker"
docker run \
    --privileged \
    --detach \
    --name docker-in-docker-daemon \
    --network docker-test-network \
    --network-alias docker \
    -e DOCKER_TLS_CERTDIR=/certs \
    -v ${DOCKER_CERTS}:/certs \
    -v ${PWD}:/repo \
    -v docker-library:/var/lib/docker \
    docker:dind

docker run \
    --detach \
    --name docker-in-docker-control \
    --network docker-test-network \
    -e DOCKER_HOST=tcp://docker:2376 \
    -e DOCKER_CERT_PATH=/certs/client \
    -e DOCKER_TLS_VERIFY=1 \
    -v ${DOCKER_CERTS}:/certs \
    -v ${PWD}:/repo \
    docker-control:research-docker-in-docker sh -c "tail -f > /dev/null"

echo "> Call hello world in docker-in-docker"
docker exec -ti docker-in-docker-control sh -c "docker version"

echo "> Show directory in docker-in-docker call container"
docker exec -ti docker-in-docker-control sh -c "docker run --rm -v /repo:/repo bash -l -c 'ls /repo -al'"

echo "> Show directory in docker-in-docker container"
docker exec -ti docker-in-docker-control sh -c "ls /repo -al"
