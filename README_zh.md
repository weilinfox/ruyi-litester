# Ruyi Lit Tester

用 LLVM Integrated tester 测试 Ruyi 包管理器

使用 LLVM Integrated tester 实现数据驱动的测试，使用 mugen 格式的结构化脚本实现复杂过程的测试。

关键字: ruyi, lit, mugen, schroot

## 依赖

框架本身：

+ bash
+ coreutils
+ schroot
+ util-linux
+ yq (依赖 jq)

运行 Lit 测试：

+ LLVM Lit

运行 Mugen 测试：

+ grep
+ procps-ng
+ 发行版自身包管理器

在测试用例配置中查看用例的依赖。

### LLVM Lit

上游页面： [llvm-project](https://github.com/llvm/llvm-project/tree/main/llvm/utils/lit) 或者 [pypi](https://pypi.org/project/lit/)。

lit 运行测试时还依赖 LLVM FileCheck，发行版打包 LLVM 时都会一并打包 FileCheck，但是不一定打包 lit。

| 发行版 | 包名 | 备注 |
| :--: | :--: | :-- |
| Arch Linux | [extra/llvm](https://archlinux.org/packages/extra/x86_64/llvm/) | lit 和 FileCheck 均在该包提供 |
| Gentoo  | [dev-python/lit](https://packages.gentoo.org/packages/dev-python/lit) |  |
| Debian | llvm-\*-tools | 如 [llvm-14-tools](https://packages.debian.org/bookworm/llvm-14-tools) \* |
| Ubuntu | llvm-\*-tools | 如 [llvm-14-tools](https://packages.debian.org/bookworm/llvm-14-tools) \* |
| Fedora | [python3-lit](https://packages.fedoraproject.org/pkgs/python-lit/python3-lit/) | 39， 40 |
| Fedora | [python3-lit](https://packages.fedoraproject.org/pkgs/llvm/python3-lit/) | 41 及以上 |
| openEuler | [python-lit](https://gitee.com/src-openeuler/python-lit) |  |

\* Debian/Ubuntu 通常直接安装 ``llvm`` 包即可引入默认版本的 llvm-tools，当然也可以手动安装指定版本。要注意它提供的 FileCheck 命令名称包含大版本号，如 llvm-14-tools 提供 ``/usr/bin/FileCheck-14``，并且没有像其他发行版一样给出 ``/usr/bin/lit``，而是 ``/usr/lib/llvm-14/build/utils/lit/lit.py``。 Rit 在运行测试之前会在 ``$RIT_TMP_PATH/bin`` 下建立所需的软链接。

### yq

| 发行版 | 包名 | 备注 |
| :--: | :--: | :-- |
| Arch Linux | [extra/yq](https://archlinux.org/packages/extra/any/yq/) |  |
| Gentoo | [app-misc/yq](https://packages.gentoo.org/packages/app-misc/yq) |  |
| Debian  | [yq](https://packages.debian.org/bookworm/yq) | Bookworm 以上及 bullseye-backports |
| Ubuntu | [yq](https://packages.ubuntu.com/noble/yq) | Noble 及以上 |
| Fedora | [yq](https://packages.fedoraproject.org/pkgs/yq/yq/) | 39 及以上 |
| openEuler |  | 未打包 |

Ubuntu Jammy x86\_64 有 backport 的 yq，而 riscv64 可以临时使用 [这个的包](http://archive.ubuntu.com/ubuntu/pool/universe/y/yq/yq_3.1.0-3_all.deb)。

openEuler 可以使用 yq [GitHub Release](https://github.com/mikefarah/yq/releases/) 中的二进制。

## 使用方法

参考 ``rit.bash --help``。

测试日志存放在当前目录 ``.`` 下。

## 测试套配置

测试套默认配置在 [suites](./suites) 目录下，使用 yaml 文件编写。

一个典型的测试套配置如下：

```yaml
# example.yaml
example:
  cases:
    # 测试用例列表
    # 这个列表中的用例会按顺序运行
    - example-install-and-remove
    - example-help-message
  pre:
    # 这是一个多维测试环境配置脚本矩阵
    # 这个列表在用例运行前运行
    # "_" 代表了一个不需要运行的空脚本
    - ["install-from-src", "install-from-bin", "install-from-pkg"]
    - ["setup-en-locale", "setup-zh-locale", "setup-ja-locale"]
  post:
    # 这个列表在用例运行后运行
    # 每一个 pre 脚本都应当有一个 post 脚本对应
    - ["remove-from-src", "remove-from-bin", "remove-from-pkg"]
    - ["_", "setup-en-locale", "setup-en-locale"]

# 其他测试配置
example_profile0:
  cases:
    - example-run
  pre:
    - ["install-from-src"]
  post:
    - ["remove-from-src"]

example_profile1:
  cases:
    - example-smoke
  pre:
    - ["install-from-src"]
    - ["setup-en-locale"]
    - ["setup-default-mirror", "setup-backup-mirror"]
  post:
    - ["remove-from-src"]
    - ["_"]
    - ["clear-settings", "clear-settings"]
```

这是一个名为 ``example`` 的测试套，其配置文件为 ``example.yaml``。一个测试套可以多个测试配置，默认采用和测试套同名的配置，而其他配置可以通过 ``-p, --profile`` 参数指定。

``cases`` 字段定义了该配置会运行的测试用例列表，这个列表中的用例会顺序运行。

``pre`` 和 ``post`` 字段定义了测试环境的配置脚本和恢复脚本，这在结构上是一个矩阵，在逻辑上定义了一套多维度的测试环境。脚本应当是可执行的，设计上允许各种脚本语言，但当前暂只支持 bash 脚本。

### 多维测试环境

以 ``example.yaml`` 中的 ``example`` 配置为例，它定义了下面一个二维的测试环境。

|  | install-from-src | install-from-bin | install-from-pkg |
| :--: | :--: | :--: | :--: |
| setup-en-locale | x | x | x |
| setup-zh-locale | x | x | x |
| setup-ja-locale | x | x | x |

example-install-and-remove 和 example-help-message 这两个测试用例将会分别在这 9 种测试环境中运行并输出分别的测试报告。

脚本运行顺序类似于栈，如第一种测试环境的脚本运行顺序为 ``install-from-src`` -> ``setup-en-locale`` -> ``_`` -> ``remove-from-src``，当然 ``_`` 代表空会被忽略。

而 ``example.yaml`` 中的 ``example_profile1`` 配置则定义了一个三维共 2 种测试环境。

## 测试用例配置

测试用例默认维护在 [testcases](./testcases) 目录下，配置文件为每个用例目录下的 ``rit.yaml``。

这个配置主要配置了用例类型和该类型对应的一些参数。当前仅支持 lit 一种测试用例。

### lit 用例配置

```yaml
# lit 用例
type: lit
# {lexical,random,smart} 顺序/乱序执行
# lit --order
# 默认 random
order: random
# 测试用例中的小用例是否允许并行
# 默认 true
concurrent: true
# {none,fail,all} 用例日志级别
# 只记录结果/记录详细的失败用例信息/记录所有详细信息
# fail 对应 lit --verbose
# all 对应 lit --show-all
# 默认 fail
# 具体能够记录到的信息还要看用例具体编写
logging: all
```

## 内部变量

内部变量在框架全局可用，外部工具则可以由环境变量获取。

对于测试用例， mugen 由于使用 bash 编写，可以直接从环境变量获取； lit 则需要由 lit.cfg.py 从环境变量获取，按需配置。

| 变量名称 | 含义 | 备注 |
| :--: | :-- | :-- |
| RIT\_CASE\_ENV\_PATH | 用例环境变量配置 |  绝对路径 |
| RIT\_CASE\_FEATURES | 测试环境可用特性 |  |
| RIT\_CASE\_PATH | 框架 testcase 根目录 | 绝对路径 |
| RIT\_DRIVER\_PATH | 框架 driver 目录 | 绝对路径 |
| RIT\_RUN\_PATH | 运行目录 | 绝对路径 |
| RIT\_SCRIPT\_PATH | 框架 script 目录 | 绝对路径 |
| RIT\_SELF\_PATH | 框架根目录 | 绝对路径 |
| RIT\_SUDO | 允许测试套调用 ``sudo`` 提权 | 小写 ``x`` 为真 |
| RIT\_SUITE\_PATH | 框架 suite 目录 | 绝对路径 |
| RIT\_TMP\_PATH | 框架临时文件目录 | 绝对路径 |
| RIT\_VERSION | 框架版本 |  |

### RIT\_CASE\_FEATURES

测试环境可用特性

| 可能值 | 备注 |
| :--: | :-- |
| aarch64 |  |
| riscv64 |  |
| x86\_64 |  |
| archlinux |  |
| debian |  |
| fedora |  |
| linux | 系统为 Linux，但是没有成功获取到具体发行版信息 |
| openkylin |  |
| openeuler |  |
| revyos | 当前系统为 RevyOS，通常同时存在 debian 特性字段 |
| ubuntu | 有时会是 debian 而不出现 ubuntu |

## Mugen 兼容

Rit 的只是在测试用例和测试套配置上一定程度兼容了 mugen 格式的测试用例。

关于 mugen 测试框架的详细信息可用参考 openEuler [上游](https://gitee.com/openeuler/mugen/)。

### 测试套 json 配置

在 mugen 框架中，测试套的 json 配置文件被放置在 suite2cases 目录下，但是 Rit 的 mugen 测试套将该文件存放在测试套根目录下，且只有 ``cases`` 字段。

### 框架函数导入

在 mugen 框架中，测试用例为了使用框架定义的函数，需要 ``source`` 相应的 sh 脚本：

```shell
source "${OET_PATH}"/libs/locallibs/common_lib.sh
```

而在 Rit 的 mugen 测试用例中，则 ``source`` 如下脚本：

```bash
source "${RIT_DRIVER_PATH}"/driver/utils/mugen_libs.bash
```

### 软件包安装

在 mugen 框架中，测试用例使用 ``DNF_INSTALL`` 和 ``DNF_REMOVE`` 函数在测试机上安装软件包，只支持 openEuler。

而在 Rit 的 mugen 测试用例中，测试用例将使用 ``PKG_INSTALL`` 和 ``PKG_REMOVE`` 函数执行类似的操作，支持多种发行版。

样例 1，在 Debian 安装 package1，而在 Archlinux 安装 package2，其他发行版则什么也不做：

```shell
PKG_INSTALL --debian package1 --archlinux package2
```

样例 2，在 Debian、 Ubuntu 和 RevyOS 安装 package1 和 package2，而在 Fedora 和 openEuler 安装 package3，其他发行版则什么也不做：

```shell
PKG_INSTALL --debian --ubuntu --revyos package1 package2 --fedora --openeuler package3
```

由于当前 RevyOS 基于 Debian sid，在 ``RIT_CASE_FEATURES`` 变量中 ``debian`` 和 ``revyos`` 字段会同时出现，故不要使用 ``--revyos`` 参数。

Rit 的 Linux 发行版识别支持范围请参考 ``RIT_CASE_FEATURES`` 环境变量。

``PKG_REMOVE`` 则不需要任何参数， ``PKG_INSTALL`` 会自动记录安装的软件包列表。

### sudo

openEuler 上游的 mugen 需要用 root 用户运行测试，而 Rit 不允许使用 root 用户运行。

在 Rit 的 mugen 兼容库和 mugen 测试用例中，任何需要 root 权限进行的操作都需要 ``sudo`` 提权，故测试用户需要配置 sudo 免密码。

Rit 认为非必要不要做必须提权的操作，默认情况下框架中所有会调用 ``sudo`` 提权的内置函数都将被跳过，测试人员必须清楚认识到这一点；而测试开发者也应当在需要调用 ``sudo`` 的代码中做好检查工作。

如果测试人员确实需要应用 ``sudo`` 提权的特性，可以使用 ``-s`` 或 ``--sudo`` 参数打开。

会调用 ``sudo`` 提权的函数罗列如下：

+ PKG\_INSTALL
+ PKG\_REMOVE

## 选择性运行测试

通常 profile 会提供一个最大化的测试用例列表， Rit 提供了 ``--match`` 参数允许只运行符合表达式的测试。表达式允许使用 ``and``、 ``or``、 ``not`` 运算符，默认情况下它们的优先级从高到低依次为 ``not``、 ``and``、 ``or``，允许使用括号改变运算符的优先级。表达式的操作数均为字符串，使用子字串的方式匹配。

不建议给 ``--match`` 传入不符合语法的表达式。

而对于测试用例列表中的某个测试， Rit 提供了 ``--lit`` 和 ``--mugen`` 直接向 driver 传参。 Lit 可以参考 ``--filter-out`` 参数， Mugen 则提供了和 Rit 用法相同的 ``--match`` 参数。

## TODO 列表

+ [ ] 完整的 Ruyi 测试用例
+ [x] 多维环境测试
+ [x] lit 测试
+ [ ] mugen 测试用例兼容
+ [ ] schroot 测试环境支持
+ [ ] qemu 测试环境支持
+ [ ] os-autoinst 测试环境支持

