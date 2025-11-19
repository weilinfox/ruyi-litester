FROM ubuntu:jammy AS builder
WORKDIR /ruyi-litester

# RUN rm -rf /etc/apt/sources.list.d && mkdir /etc/apt/sources.list.d && printf "Types: deb\nURIs: http://mirrors.ustc.edu.cn/debian\nSuites: bookworm\nComponents: main contrib\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/apt.sources

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && apt-get install -y llvm-14-tools coreutils util-linux file expect sudo git make tar jq build-essential wget zstd python3-pip && apt-get clean
RUN pip install yq

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG sudo -s /bin/bash $UNAME
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
