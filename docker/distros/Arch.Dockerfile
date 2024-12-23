FROM docker.1panel.live/library/archlinux AS build
WORKDIR /ruyi-litester
# 使用镜像
RUN echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
RUN sed -i '/^NoExtract  = usr\/share\/locale\/\* usr\/share\/X11\/locale\/\* usr\/share\/i18n\/\*/d' /etc/pacman.conf
RUN pacman-key --init && pacman -Syyu --noconfirm && pacman -S --noconfirm glibc llvm coreutils util-linux yq grep procps bash sudo git wget openssl-1.1 zstd make glibc-locales


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