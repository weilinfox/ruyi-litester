FROM archlinux/archlinux:latest AS builder
WORKDIR /ruyi-litester

# RUN echo "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
# RUN sed -i '/^NoExtract  = usr\/share\/locale\/\* usr\/share\/X11\/locale\/\* usr\/share\/i18n\/\*/d' /etc/pacman.conf
RUN pacman-key --init && pacman --noconfirm -Syyu && pacman --need --noconfirm -S llvm sudo file expect git make tar jq


FROM builder
ARG UNAME=ruyisdk_test
RUN useradd -mG wheel -s /bin/bash $UNAME
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /ruyi-litester
COPY . .
RUN chown -R $UNAME:$UNAME /ruyi-litester
USER $UNAME

ENTRYPOINT ["docker/test_run.sh"]
