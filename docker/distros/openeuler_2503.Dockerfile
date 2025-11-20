FROM openeuler/openeuler:25.03 AS builder
WORKDIR /ruyi-litester

# RUN rm -rf /etc/yum.repos.d/* 
# RUN if [ "$ARCH" = "amd64" ]; then echo -e "[openeuler]\nname=openeuler\nbaseurl=https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/OS/x86_64\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/openeuler.repo ; else echo -e "[openeuler]\nname=openeuler\nbaseurl=https://mirrors.ustc.edu.cn/openeuler/openEuler-24.03-LTS/OS/aarch64\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/openeuler.repo ; fi

RUN dnf upgrade -y && dnf install -y llvm coreutils util-linux grep procps bash sudo git wget make zstd jq python3-pip xz
RUN pip install yq lit
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
