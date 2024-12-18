FROM docker.1panel.live/openeuler/openeuler:24.03 AS build
WORKDIR /ruyi-litester
# 使用镜像
RUN rm -rf /etc/yum.repos.d/* 
RUN if [ "$ARCH" = "amd64" ]; then echo -e "[openeuler]\nname=openeuler\nbaseurl=https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/OS/x86_64\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/openeuler.repo ; else echo -e "[openeuler]\nname=openeuler\nbaseurl=https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/OS/aarch64\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/openeuler.repo ; fi


RUN yum install -y llvm coreutils util-linux grep procps bash sudo git wget make zstd openssl jq glibc-locale-source python3-pip xz
RUN pip install yq lit

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