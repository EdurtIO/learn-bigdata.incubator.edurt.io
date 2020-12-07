---
layout: default
title: 升级druid.io到apache版本
nav_order: 101
parent: Action(实战)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 我们只是试验性功能,不建议升级,可能会导致部分segment损坏,或者出现一些不必要的麻烦

### 升级准备

---

我们今天尝试升级Druid服务,首先我们使用的是druid-0.9.x版本服务,然后我们要升级到apache社区版的druid-0.16.0版本.由于druid的结构模式,致使我们可以很平滑的快速升级到新版本中.当然此升级模式适用于任意版druid(druid.io或apache).

- 首先下载升级包

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/apache/incubator/druid/0.16.0-incubating/apache-druid-0.16.0-incubating-bin.tar.gz
```

- 解压安装包

```bash
tar -xvzf apache-druid-0.16.0-incubating-bin.tar.gz -O druid-0.16.0
```

- 复制原有mysql链接驱动到新版本中

```bash
cp -r ../druid-0.15.1/extensions/mysql-metadata-storage/mysql-connector-java-5.1.38.jar extensions/mysql-metadata-storage
```

- 复制自定义sketches[可选]

> 如果原有的源码是通过io版本构建的,则需要重新使用apache进行源码构建

```bash
cp -r ../druid-0.9.1/extensions/data-sketches/ ./extensions/
```

- 复制原有配置到新版中

```bash
mv conf/ conf.bak && scp -r ../druid-0.9.1/conf ./
```

此时我们可以相继升级`historical`,`overlord`,`broker`,`coordinator`服务.
apache版本为我们提供了相关服务的启动脚本.

### 附属-升级过程(比如升级overlord节点,建议一台一台节点升级)

---

- 停止原有overlord服务

```bash
ps -ef|grep 'io.druid.cli.Main server overlord'|grep -v grep| awk '{print $2}' | xargs kill
```

kill后空格加`-9`不加该参数会平滑停止服务,可能会慢.加上会强制停止服务,建议平滑停止

- 启动新版overlord服务

```bash
cd /hadoop/data1/druid-0.16.0
./bin/overlord.sh start
```

启动日志位于`./log/overlord.log`,确保服务启动成功后,程序升级成功