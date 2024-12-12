#!/bin/sh
set -e

debian_dockerfile=Debian.Dockerfile
debian_tag=ruyi-debian
ubuntu_dockerfile=Ubuntu.Dockerfile
ubuntu_tag=ruyi-ubuntu
arch_docerfile=Arch.Dockerfile
arch_tag=ruyi-arch

# default to debian 
distro=debian
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
docker_tag=

if [ "$distro" = "debian" ]; then
    docker_tag=$debian_tag
    dockerfile=$debian_dockerfile
elif [ "$distro" = "ubuntu" ]; then
    docker_tag=$ubuntu_tag
    dockerfile=$ubuntu_dockerfile
elif [ "$distro" = "arch" ]; then
    docker_tag=$arch_tag
    dockerfile=$arch_docerfile
else
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


