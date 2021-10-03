@echo off
setlocal
setlocal enabledelayedexpansion

:: Execute case script

echo ^> Create case directory
set DOCKER_CERTS=%cd%\cache\certs
set DOCKER_LIBRARY=%cd%\cache\library

echo ^> Download docker-in-docker
docker pull docker:dind

echo ^> Build docker control
docker build --rm^
    -t docker-control:research-docker-in-docker^
    ./docker

::echo ^> Create docker network and volume

::echo ^> Remove legacy container

echo ^> Run docker-in-docker
docker run -ti --rm -v "//var/run/docker.sock:/var/run/docker.sock" docker-control:research-docker-in-docker sh -c "docker version"

echo ^> Show directory in docker-in-docker call container
docker run -ti --rm ^
    -v "//var/run/docker.sock:/var/run/docker.sock" ^
    -v %cd%:/repo ^
    docker-control:research-docker-in-docker sh -c "docker run --rm -v /repo:/repo bash -l -c 'ls /repo -al'"

echo ^> Show directory in docker-in-docker container
docker run -ti --rm ^
    -v "//var/run/docker.sock:/var/run/docker.sock" ^
    -v %cd%:/repo ^
    docker-control:research-docker-in-docker sh -c "ls /repo -al"
