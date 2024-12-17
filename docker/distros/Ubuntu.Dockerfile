FROM docker.1panel.live/library/ubuntu:22.04 AS build
ARG ARCH
WORKDIR /ruyi-litester
# 使用镜像
RUN rm -rf /etc/apt/sources.list.d && mkdir /etc/apt/sources.list.d
RUN if [ "$ARCH" = "amd64" ]; then echo "Types: deb\nURIs: http://mirrors.ustc.edu.cn/ubuntu\nSuites: jammy jammy-updates jammy-backports\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n\nTypes: deb\nURIs: http://mirrors.ustc.edu.cn/ubuntu\nSuites: jammy-security\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg" > /etc/apt/sources.list.d/apt.sources ; else echo "Types: deb\nURIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports\nSuites: jammy jammy-updates jammy-backports\nComponents: main restricted universe multiverse\nSigned-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg\n" > /etc/apt/sources.list.d/apt.sources ; fi


RUN apt-get update && apt-get install -y llvm-14-tools coreutils util-linux grep procps bash sudo git python3.10-venv python3.10-dev libffi-dev wget build-essential libssl-dev zstd locales curl python3-pip jq openssl libgit2-dev python3-cryptography python3-pygit2 python3-dulwich python3-msgpack && apt-get clean 
RUN pip install yq


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