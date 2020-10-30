---
layout: default
title: Presto安装部署
nav_order: 1
has_children: true
parent: Action(实战)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 基本配置环境

|依赖|版本|
|:---:|---|
|Presto|0.221|
|CentOS|7.x|
|Java|1.8.0_212+|

### 下载配置Presto

- 创建相关使用文件夹并授权(**根据自己实际服务器环境选择**)

```bash
sudo mkdir -p /hadoop/data/presto
sudo chown -R presto:presto /hadoop/data/presto
sudo - presto
```

- [Presto官网](https://prestodb.io/download.html)下载安装包

```bash
wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server/0.221/presto-server-0.221.tar.gz
```

- 解压并重命名文件夹

```bash
tar -xvzf presto-server-0.221.tar.gz && mv presto-server-0.221 server
```

- 创建`node.properties`配置

```bash
mkdir /hadoop/data/presto/server/etc
cd /hadoop/data/presto/server/etc
vim /hadoop/data/presto/server/etc/node.properties
```

在`node.properties`配置文件写入以下内容

```java
node.environment=presto_cluster
node.id=presto-coordinator
node.data-dir=/hadoop/data/presto/data
```

`node.environment`: 环境的名称.集群中的所有Presto节点必须具有相同的环境名称
`node.id`: Presto安装的唯一标识符.对于每个节点,这必须是唯一的.这个标识符应该在重新启动或升级Presto时保持一致.如果在一台机器上运行多个Presto安装(即在同一台机器上运行多个节点),则每个安装必须具有唯一标识符
`node.data-dir`: 数据目录的位置(文件系统路径).Presto将在这里存储日志和其他数据

- 创建`jvm.config`改配置文件用于JVM调优处理

```bash
vim /hadoop/data/presto/server/etc/jvm.config
```

在配置文件写入以下内容

```java
-server
-Xmx3G
-XX:+UseConcMarkSweepGC
-XX:+ExplicitGCInvokesConcurrent
-XX:+CMSClassUnloadingEnabled
-XX:+AggressiveOpts
-XX:+HeapDumpOnOutOfMemoryError
-XX:OnOutOfMemoryError=kill -9 %p
-XX:ReservedCodeCacheSize=150M
```

具体的jvm参数可参照JVM官网配置

- 创建`config.properties`改配置文件用于配置Presto服务

```bash
vim /hadoop/data/presto/server/etc/config.properties
```

在配置文件写入以下内容

```bash
coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=17979
discovery-server.enabled=true
discovery.uri=http://127.0.0.1:17979
```

`coordinator`: 允许该Presto实例充当协调器,以便接受来自客户端的查询并管理查询执行
`node-scheduler.include-coordinator`: 允许在协调器上调度工作.对于较大的集群,协调器上的处理工作可能会影响查询性能,因为机器的资源无法用于调度,管理和监视查询执行的关键任务
`http-server.http.port`: 指定HTTP服务器的端口.Presto使用HTTP进行所有内部和外部通信
`discovery-server.enabled`: Presto使用发现服务查找集群中的所有节点.每个Presto实例在启动时向发现服务注册自己.为了简化部署并避免运行附加服务,Presto协调器可以运行发现服务的嵌入式版本.它与Presto共享HTTP服务器,因此使用相同的端口
`discovery.uri`: 发现服务器的URI.因为我们已经在Presto协调器中启用了discovery,所以这应该是Presto协调器的URI.这个URI不能以斜线结束.

### Presto服务启动监测

- 启动服务

```bash
/hadoop/data/presto/server/bin/launcher start
```

- 查询相关log日志

```bash
tail -f /hadoop/data/presto/data/var/log/server.log
```

> 配置works很简单,只需要修改`config.properties`配置文件,将**coordinator=true**修改为false, **discovery-server.enabled=true**注释掉
> 修改`node.properties`将**node.id**配置为集群中唯一值即可