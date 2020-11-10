---
layout: default
title: broker节点配置部署
nav_order: 5
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
vim conf/druid/broker/jvm.config
```

修改为以下内容

```java
-server
-Xms12g
-Xmx12g
-XX:MaxDirectMemorySize=2048m
-Duser.timezone=UTC
-Dfile.encoding=UTF-8
-Djava.io.tmpdir=/hadoop/dc/temp/
-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
```

- **-Xms**: 设置初始的(最小的)Heap的大小 此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存
- **-Xmx**: 设置最大Heap的大小
- **-XX:MaxDirectMemorySize**: 此参数的含义是当Direct ByteBuffer分配的堆外内存到达指定大小后，即触发Full GC。注意该值是有上限的，默认是64M，最大为sun.misc.VM.maxDirectMemory()，在程序中中可以获得-XX:MaxDirectMemorySize的设置的值,不要设置过大，合理即可。
- **-Duser.timezone**: 时区类型
- **-Dfile.encoding**: 文件编码
- **-Djava.io.tmpdir**: 系统缓冲临时目录
- **-Djava.util.logging.manager**: Log监控管理工具类

### runtime.properties配置文件

---

```java
vim conf/druid/broker/runtime.properties
```

修改为以下内容

```java
druid.service=druid/broker
druid.port=8082
 
# HTTP server threads
druid.broker.http.numConnections=5
druid.server.http.numThreads=12
 
# Processing threads and buffers
druid.processing.buffer.sizeBytes=236870912
druid.processing.numThreads=8
 
# Query cache
druid.broker.cache.useCache=true
druid.broker.cache.populateCache=true
druid.cache.type=local
druid.cache.sizeInBytes=20000000
```

- **druid.service**: 服务名称和_common中相关联
- **druid.port**: 当前服务端口
- **druid.broker.http.numConnections**: http服务的连接数
- **druid.server.http.numThreads**: http服务的最大链接线程
- **druid.processing.buffer.sizeBytes**: druid-io进程buffer的单线程大小，注意该数值*线程数大小不得超过jvm中的xmx配置数据
- **druid.processing.numThreads**: druid-io进程buffer的线程总数
- **druid.broker.cache.useCache**: 此次查询是否利用查询缓存，如手动指定，则会覆盖查询节点或历史节点配置的值
- **druid.broker.cache.populateCache**: 此次查询的结果是否缓存，如果手动指定，则会覆盖查询节点或历史节点配置的值
- **druid.cache.type**: druid-io的缓冲类型，默认为local，可配置为redis等
- **druid.cache.sizeInBytes**: druid-io的缓冲大小

### 服务启动命令脚本(进入druid-io安装文件的根目录)

---

- 基本启动方式

```java
java `cat conf/druid/broker/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/broker:lib/*" io.druid.cli.Main server broker
```

- 后台启动方式

```java
nohup java `cat conf/druid/broker/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/broker:lib/*" io.druid.cli.Main server broker > broker.log 2>&1 &
```