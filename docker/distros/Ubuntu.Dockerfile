FROM docker.1panel.live/library/ubuntu:24.04 AS build
ARG ARCH
WORKDIR /ruyi-litester
# 使用镜像
RUN rm -rf /etc/apt/sources.list.d && mkdir /etc/apt/sources.list.d
RUN if [ "$ARCH" = "amd64" ]; then echo "Types: deb\nURIs: http://mirrors.ustc.edu.cn/ubuntu\nSuites: noble noble-updates noble-backports\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n\nTypes: deb\nURIs: http://mirrors.ustc.edu.cn/ubuntu\nSuites: noble-security\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg" > /etc/apt/sources.list.d/apt.sources ; else echo "Types: deb\nURIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports\nSuites: noble noble-updates noble-backports\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n" > /etc/apt/sources.list.d/apt.sources ; fi


RUN apt-get update && apt-get install -y llvm-14-tools coreutils util-linux yq grep procps bash sudo git python3.12-venv wget build-essential libssl-dev zstd locales && apt-get clean


FROM build
ARG UNAME=testuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME && usermod -aG sudo $UNAME

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME


ENTRYPOINT ["bash", "rit.bash"]