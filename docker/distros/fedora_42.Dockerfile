FROM fedora:42 AS builder
WORKDIR /ruyi-litester

# RUN sed -e 's|^metalink=|#metalink=|g' -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' -i.bak /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora-updates.repo


RUN dnf install -y python3-lit llvm18 coreutils util-linux grep procps bash sudo git wget make zstd openssl jq glibc-locale-source python3-pip
RUN pip install yq
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG wheel -s /bin/bash $UNAME
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME


ENTRYPOINT ["docker/test_run.sh"]
