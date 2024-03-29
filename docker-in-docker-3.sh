#!/bin/bash
set -e

# Execute case script

echo "Download docker-in-docker"
docker pull bash

echo "> Build docker control"
docker build --rm \
    -t docker-control:research-docker-in-docker \
    ./docker

echo "> Remove legacy container"
docker rm -f docker-in-docker-control

echo "> Run docker-in-docker"
docker run \
    --detach \
    --name docker-in-docker-control \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v ${PWD}:/repo \
    docker-control:research-docker-in-docker sh -c "tail -f > /dev/null"

echo "> Call hello world in docker-in-docker"
docker exec -ti docker-in-docker-control sh -c "docker version"

echo "> Show directory in docker-in-docker call container"
docker exec -ti docker-in-docker-control sh -c "docker run --rm -v ${PWD}:/repo bash -l -c 'ls /repo -al'"

echo "> Show directory in docker-in-docker container"
docker exec -ti docker-in-docker-control sh -c "ls /repo -al"
