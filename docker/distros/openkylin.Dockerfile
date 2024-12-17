FROM cyl18/openkylinindocker AS build
ARG ARCH
WORKDIR /ruyi-litester


RUN apt-get update && apt-get install -y llvm-17-tools coreutils util-linux yq grep procps bash sudo git python3.12-venv wget build-essential zstd locales && apt-get clean


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