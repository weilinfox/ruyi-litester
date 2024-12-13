#!/bin/bash
set -e

distro=
proxy=

for i in "$@"
do
    case $i in
        --distro=*)
            distro="${i#*=}"
            shift
            ;;
        --proxy=*)
            proxy="${i#*=}"
            shift
            ;;
        *)
            # unknown option
            ;;
    esac
done
if [ -z "$distro" ]; then
    echo no distro specified, default to debian
    distro=debian
fi

# there is no need for checking if the distro is valid, since it's checked below

# build docker image and run

dockerfile="${distro}.Dockerfile"
docker_tag="${distro,,}_tag"


if [ -z "$dockerfile" ] ; then
    echo "Unknown distro: $distro"
    exit 1
fi

docker rm ruyi-test-docker || true

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t $docker_tag -f docker/$dockerfile . && \
docker run --name ruyi-test-docker -it $docker_tag "$@"   
#docker run -e RUYI_TELEMETRY_OPTOUT=1 --name ruyi-test-docker -it $docker_tag "$@"

# 复制 log 并删除 container 和 image
docker cp ruyi-test-docker:/ruyi-litester/mugen_log/ . && docker rm ruyi-test-docker
docker rmi $docker_tag


