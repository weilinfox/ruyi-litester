# Ruyi Lit Tester

用 LLVM Integrated tester 测试 Ruyi 包管理器

使用 LLVM Integrated tester 实现数据驱动的测试，使用 mugen 格式的结构化脚本实现复杂过程的测试。

关键字: ruyi, lit, schroot

## 依赖

+ LLVM Lit
+ bash
+ coreutils
+ schroot
+ yq

在测试用例配置中查看用例的依赖。

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

## TODO 列表

+ [ ] 完整的 Ruyi 测试用例
+ [x] 多维环境测试
+ [X] lit 测试
+ [ ] mugen 测试用例兼容
+ [ ] schroot 测试环境支持
+ [ ] qemu 测试环境支持
+ [ ] os-autoinst 测试环境支持

