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

## 让 Docker 支持 qemu

看起来需要每次开机都运行！
```shell
docker run --privileged --rm tonistiigi/binfmt --install arm64,riscv64
```

```shell
docker/docker-test.sh --distro=Ubuntu --arch=riscv64 ruyi > ubuntu.log
docker/docker-test.sh --distro=Ubuntu --arch=arm64 ruyi > ubuntu.log
```


## 支持矩阵

Docker in amd64:

|  | Arch | Debian | Ubuntu | Fedora | openEuler | Gentoo | openkylin | revyos |
| :- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| amd64 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ➖ |
| arm64 | ➖ | ⚠️ | ✅ | ✅ | ❔ | ❌ | ❌ | ➖ |
| riscv64 | ➖ | ⚠️ | ✅ | ➖| ⚠️ | ❔ | ✅ | ❔ |

❔: 暂未测试  
➖: 该发行版未提供  
❌: 未计划支持  
⚠️: 需要人工打包

<!--如何制作镜像：https://wiki.metacentrum.cz/wiki/Creating_Docker_Image_from_.iso_File -->