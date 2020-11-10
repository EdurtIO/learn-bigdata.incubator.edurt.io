---
layout: default
title: coordinator节点配置部署
nav_order: 6
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
vim conf/druid/coordinator/jvm.config
```

修改为以下内容

```java
-server
-Xms3g
-Xmx3g
-Duser.timezone=UTC
-Dfile.encoding=UTF-8
-Djava.io.tmpdir=var/tmp
-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager
-Dderby.stream.error.file=var/druid/derby.log
```

- **-Xms**: 设置初始的(最小的)Heap的大小 此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存
- **-Xmx**: 设置最大Heap的大小
- **-Duser.timezone**: 时区类型
- **-Dfile.encoding**: 文件编码
- **-Djava.io.tmpdir**: 系统缓冲临时目录
- **-Djava.util.logging.manager**: Log监控管理工具类
- **-Dderby.stream.error.file**: 内置数据库出现错误写入的文件

### runtime.properties配置文件

---

```java
vim conf/druid/coordinator/runtime.properties
```

修改为以下内容

```java
druid.service=druid/coordinator
druid.port=8081
 
druid.coordinator.startDelay=PT30S
druid.coordinator.period=PT30S
```

- **druid.service**: 服务名称和_common中相关联
- **druid.port**: 当前服务端口
- **druid.coordinator.startDelay**: 延迟协调数据载入，这种延迟是一种破解，让它有足够的时间相信它拥有所有数据。
- **druid.coordinator.period**: 协调器的运行期。协调器通过在存储器中维护当前状态并定期查看可用的段集和服务的段来进行操作，以决定是否需要对数据拓扑进行任何更改。此属性设置每次运行之间的延迟。

### 服务启动命令脚本(进入druid-io安装文件的根目录)

---

- 基本启动方式

```java
java `cat conf/druid/coordinator/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/coordinator:lib/*" io.druid.cli.Main server coordinator
```

- 后台启动方式

```java
nohup java `cat conf/druid/coordinator/jvm.config | xargs` -cp "conf/druid/_common:conf/druid/coordinator:lib/*" io.druid.cli.Main server coordinator >coordinator.log 2>&1 &
```