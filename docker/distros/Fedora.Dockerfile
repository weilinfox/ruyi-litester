FROM docker.1panel.live/library/fedora:41 AS build
WORKDIR /ruyi-litester
# 使用镜像
RUN sed -e 's|^metalink=|#metalink=|g' -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' -i.bak /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora-updates.repo


RUN yum install -y python3-lit llvm18 coreutils util-linux grep procps bash sudo git wget make zstd openssl jq glibc-locale-source python3-pip
RUN pip install yq

FROM build
ARG UNAME=testuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME && groupadd sudo && usermod -aG sudo $UNAME

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME


ENTRYPOINT ["bash", "rit.bash"]