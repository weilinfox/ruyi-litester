FROM docker.1panel.live/gentoo/stage3 AS build
WORKDIR /ruyi-litester
# 使用镜像

RUN mkdir /etc/portage/repos.conf && printf "[gentoo]\nlocation = /var/db/repos/gentoo\nsync-type = rsync\nsync-uri = rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage\nauto-sync = yes" > /etc/portage/repos.conf/gentoo.conf && echo MAKEOPTS="-j6" >> /etc/portage/make.conf && echo "USE=-doc" >> /etc/portage/make.conf && sed -i 's/-O2/-O0/' /etc/portage/make.conf
RUN emerge --sync --quiet
# j6 8G 内存会被 oom kill
RUN emerge llvm-core/llvm
RUN emerge dev-python/lit coreutils util-linux grep procps bash sudo dev-vcs/git wget make app-arch/zstd openssl yq


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