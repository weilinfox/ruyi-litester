FROM linuxdeepin/deepin:crimson-arm64 AS builder
WORKDIR /ruyi-litester

# RUN rm -rf /etc/apt/sources.list.d && mkdir /etc/apt/sources.list.d && printf "Types: deb\nURIs: http://mirrors.ustc.edu.cn/debian\nSuites: bookworm\nComponents: main contrib\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg" > /etc/apt/sources.list.d/apt.sources

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && apt-get install -y llvm-19-tools coreutils util-linux yq file expect git make tar jq build-essential zstd && apt-get clean
RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG sudo -s /bin/bash $UNAME
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
