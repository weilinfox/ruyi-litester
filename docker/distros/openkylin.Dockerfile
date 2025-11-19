FROM openkylin/openkylin:2.0 AS builder
ARG ARCH
WORKDIR /ruyi-litester


RUN apt-get update && apt-get install -y llvm-17-tools coreutils util-linux yq grep procps bash sudo git python3.12-venv wget build-essential zstd locales && apt-get clean


FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG sudo -s /bin/bash $UNAME

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
