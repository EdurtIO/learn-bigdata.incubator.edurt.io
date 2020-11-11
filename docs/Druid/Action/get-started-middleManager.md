---
layout: default
title: middleManager节点配置部署
nav_order: 8
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
vim conf/druid/middleManager/jvm.config
```

修改文件内容如下

```java
-server
-Xms64m
-Xmx64m
-XX:+UseConcMarkSweepGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Duser.timezone=UTC
-Dfile.encoding=UTF-8
-Djava.io.tmpdir=/var/tmp
-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
```

- **-Xms**: 设置初始的(最小的)Heap的大小 此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存
- **-Xmx**: 设置最大Heap的大小
- **-XX:+UseConcMarkSweepGC**: 开启此参数使用ParNew & CMS（serial old为替补）搜集器
- **-XX:+PrintGCDetails**: 开启GC日志
- **-XX:+PrintGCTimeStamps**: PrintGC必须开启，只开启PrintGCDetails、PrintGCTimeStamps不会输出GC，必须PrintGC同时开启
- **-Duser.timezone**: 时区类型
- **-Dfile.encoding**: 文件编码
- **-Djava.io.tmpdir**: 系统缓冲临时目录
- **-Djava.util.logging.manager**: Log监控管理工具类

### runtime.properties配置文件

---

```java
vim conf/druid/middleManager/runtime.properties
```

修改为以下内容

```java
druid.service=druid/middleManager
druid.port=8091

# Number of tasks per middleManager
druid.worker.capacity=20

# Task launch parameters
druid.indexer.runner.javaOpts=-server -Xmx3g -XX:MaxDirectMemorySize=36g -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Duser.timezone=UTC -Dfile.encoding=UTF-8 -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
druid.indexer.task.baseTaskDir=var/druid/task
druid.indexer.task.restoreTasksOnRestart=true

# HTTP server threads
druid.server.http.numThreads=40

# Processing threads and buffers
druid.processing.buffer.sizeBytes=1036870912
druid.processing.numThreads=20

# Hadoop indexing
druid.indexer.task.hadoopWorkingPath=/druid/hadoop-tmp
druid.indexer.task.defaultHadoopCoordinates=["org.apache.hadoop:hadoop-client:2.7.3"]
```

- **druid.service**: 服务名称和_common中相关联
- **druid.port**: 当前服务端口
- **druid.worker.capacity**: 每台middleManager可运行的最大task数量.默认2,一般为可用处理器数量-1
- **druid.indexer.runner.javaOpts**: 每个task任务运行时,JVM相关配置
- **druid.indexer.task.baseTaskDir**: task的基本临时工作目录。默认`${druid.indexer.task.baseDir}/persistent/tasks`
- **druid.indexer.task.restoreTasksOnRestart**: 如果是true，MiddleManagers将尝试在关机时优雅地停止task，并在重启时恢复它们。默认false
- **druid.server.http.numThreads**: HTTP请求的线程数。max(10, (机器核心 * 17) / 16 + 2) + 30
- **druid.processing.buffer.sizeBytes**: 这指定了存储中间结果的缓冲区大小。Indexer进程中的计算引擎将使用这个大小的scratch缓冲区来执行堆外的所有中间计算。较大的值允许在一次数据传递中进行更多的聚合，而较小的值可能需要更多的传递，这取决于正在执行的查询。auto (max 1GB )
- **druid.processing.numThreads**: 可用于并行处理的处理线程数。我们的经验法则是num_core - 1，这意味着即使在很重的负载下，仍然有一个core可用来完成后台任务，比如与ZooKeeper交互和下载segments。如果只有一个内核可用，该属性默认值为1。一般为核心数量-1或者1.
- **druid.indexer.task.hadoopWorkingPath**: Hadoop task的临时工作目录。默认`/tmp/druid-indexing`

### 服务启动命令脚本(进入druid-io安装文件的根目录)

---

- 基本启动方式

```java
java `cat conf/druid/middleManager/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/middleManager:lib/*" io.druid.cli.Main server middleManager
```

- 后台启动方式

```java
nohup java `cat conf/druid/middleManager/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/middleManager:lib/*" io.druid.cli.Main server middleManager >middleManager 2>&1 &
```