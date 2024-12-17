#!/bin/bash
set -e

distro=
proxy=
arch=

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
        --arch=*)
            arch="${i#*=}"
            shift
            ;;
        *)
            # unknown option
            ;;
    esac
done
if [ -z "$distro" ]; then
    echo no distro specified, defaulting to debian
    distro=debian
fi

if [ -z "$arch" ]; then
    echo no arch specified, defaulting to amd64
    arch=amd64
fi


if [ "$arch" != "amd64" ] && [ "$arch" != "arm64" ] && [ "$arch" != "riscv64" ]; then
    echo "Invalid arch: $arch"
    exit 1
fi

arch_arg=linux/$arch

# there is no need for checking if the distro is valid, since it's checked below

# build docker image and run

dockerfile="${distro}.Dockerfile"
docker_tag="${distro,,}_${arch}"


if [ -z "$dockerfile" ] ; then
    echo "Unknown distro: $distro"
    exit 1
fi

function cleanup()
{
    # 复制容器内的 log
    docker cp $container_name:/ruyi-litester/mugen_log/ .
    rm -rf logs
    docker cp $container_name:/ruyi-litester/logs/ ./$docker_tag 

    # 删除 container 和 image
    docker rm ruyi-test-docker
    docker rmi $docker_tag
}
trap cleanup SIGINT SIGTERM

container_name=ruyi-test-docker-$distro-$arch

docker rm $container_name || true

docker build --platform $arch_arg --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg ARCH=$arch --network host -t $docker_tag -f docker/distros/$dockerfile . && \
docker run --platform $arch_arg -e DOCKER=true --network host --name $container_name -it $docker_tag "$@"   

cleanup



