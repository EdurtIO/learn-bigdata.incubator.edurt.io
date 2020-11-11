---
layout: default
title: overlord节点配置部署
nav_order: 9
parent: Action(实战)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 以下操作需要进入druid-io安装文件的根目录下操作，比如我的druid-io安装目录为：/hadoop/dc/druid-0.9.1.1 那么我们需要操作 cd /hadoop/dc/druid-0.9.1.1

### jvm.conf配置文件

---

```java
vim conf/druid/overlord/jvm.config
```

修改文件内容如下

```java
-server
-Xms3g
-Xmx3g
-Duser.timezone=UTC
-Dfile.encoding=UTF-8
-Djava.io.tmpdir=var/tmp
-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
```

- **-Xms**: 设置初始的(最小的)Heap的大小 此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存
- **-Xmx**: 设置最大Heap的大小
- **-Duser.timezone**: 时区类型
- **-Dfile.encoding**: 文件编码
- **-Djava.io.tmpdir**: 系统缓冲临时目录
- **-Djava.util.logging.manager**: Log监控管理工具类

### runtime.properties配置文件

---

```java
vim conf/druid/overlord/runtime.properties
```

修改为以下内容

```java
druid.service=druid/overlord
druid.port=8090
 
druid.indexer.queue.startDelay=PT30S
 
druid.indexer.runner.type=remote
druid.indexer.storage.type=metadata
```

- **druid.service**: 服务名称和_common中相关联
- **druid.port**: 当前服务端口
- **druid.indexer.queue.startDelay**: 索引数据载入，这种延迟是一种破解，让它有足够的时间相信它拥有所有数据。
- **druid.indexer.runner.type**: 索引器运行类型，默认local
- **druid.indexer.storage.type**: 索引器存储类型，默认local

### 服务启动命令脚本(进入druid-io安装文件的根目录)

---

- 基本启动方式

```java
java `cat conf/druid/overlord/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/overlord:lib/*" io.druid.cli.Main server overlord
```

- 后台启动方式

```java
nohup java `cat conf/druid/overlord/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/overlord:lib/*" io.druid.cli.Main server overlord > overlord.log 2>&1 &
```