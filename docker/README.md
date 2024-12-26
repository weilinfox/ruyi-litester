# Docker 使用

## 安装 Docker

需要在 root 下执行。其中 $USER 为一个非 root 的用户。
```shell
export DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
wget -O- https://ghp.ci/raw.githubusercontent.com/docker/docker-install/master/install.sh | sh

groupadd docker
usermod -aG docker $USER
```
usermod 后可能需要重启。

## 使用 rit

```shell
docker/docker-test.sh --distro=Ubuntu --help
```

```shell
docker/docker-test.sh --distro=Debian ruyi
```

```shell
docker/docker-test.sh --distro=Arch ruyi > arch.log
```

在另一个终端查看运行状态: 
```shell
docker logs -f ruyi-test-docker
```