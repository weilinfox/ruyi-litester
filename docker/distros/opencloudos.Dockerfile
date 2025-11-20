FROM opencloudos/opencloudos9-minimal:latest AS builder
WORKDIR /ruyi-litester

RUN dnf install -y python3-lit llvm coreutils util-linux grep procps bash sudo git wget make zstd openssl jq glibc-locale-source python3-pip
RUN pip install yq

FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG wheel -s /bin/bash $UNAME
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME


ENTRYPOINT ["docker/test_run.sh"]
