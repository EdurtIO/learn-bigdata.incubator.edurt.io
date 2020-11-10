---
layout: default
title: historical节点配置部署
nav_order: 7
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
vim conf/druid/historical/jvm.config
```

修改为以下内容

```java
-server
-Xms8g
-Xmx8g
-XX:MaxDirectMemorySize=4096m
-Duser.timezone=UTC
-Dfile.encoding=UTF-8
-Djava.io.tmpdir=var/tmp
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
vim conf/druid/historical/runtime.properties
```

修改为以下内容

```java
druid.service=druid/historical
druid.port=8083
 
# HTTP server threads
druid.server.http.numThreads=25
 
# Processing threads and buffers
druid.processing.buffer.sizeBytes=536870912
druid.processing.numThreads=7
 
# Segment storage
druid.segmentCache.locations=[{"path":"var/druid/segment-cache","maxSize"\:130000000000}]
druid.server.maxSize=130000000000
```

- **druid.service**: 服务名称和_common中相关联
- **druid.port**: 当前服务端口
- **druid.server.http.numThreads**: http服务的最大链接线程
- **druid.processing.buffer.sizeBytes**: druid-io进程buffer的单线程大小，注意该数值*线程数大小不得超过jvm中的xmx配置数据
- **druid.processing.numThreads**: druid-io进程buffer的线程总数
- **druid.segmentCache.locations**: segment缓冲路径地址，最大加载大小字节
- **druid.server.maxSize**: 服务器的最大加载字节

### 服务启动命令脚本(进入druid-io安装文件的根目录)

---

- 基本启动方式

```java
java `cat conf/druid/historical/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/historical:lib/*" io.druid.cli.Main server historical
```

- 后台启动方式

```java
nohup java `cat conf/druid/historical/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/historical:lib/*" io.druid.cli.Main server historical >historical.log 2>&1 &
```