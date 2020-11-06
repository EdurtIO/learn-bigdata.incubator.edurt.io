---
layout: default
title: common全局配置
nav_order: 2
parent: Action(实战)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 以下操作需要进入druid-io安装文件的根目录下操作，比如我的druid-io安装目录为：/hadoop/dc/druid-0.9.1.1 那么我们需要操作 cd /hadoop/dc/druid-0.9.1.1

### common.runtime.properties配置文件

---

```java
vim conf/druid/_common/common.runtime.properties
```

修改文件内容如下:

```java
druid.extensions.loadList=["druid-kafka-eight", "druid-s3-extensions", "druid-histogram", "druid-datasketches", "druid-lookups-cached-global"]

druid.startup.logging.logProperties=true
 
#
# Zookeeper
#
 
druid.zk.service.host=zk.host.ip
druid.zk.paths.base=/druid
 
#
# Metadata storage
#
 
# For Derby server on your Druid Coordinator (only viable in a cluster with a single Coordinator, no fail-over):
druid.metadata.storage.type=derby
druid.metadata.storage.connector.connectURI=jdbc:derby://metadata.store.ip:1527/var/druid/metadata.db;create=true
druid.metadata.storage.connector.host=metadata.store.ip
druid.metadata.storage.connector.port=1527

#
# Deep storage
#
 
# For local disk (only viable in a cluster if this is a network mount):
druid.storage.type=local
druid.storage.storageDirectory=var/druid/segments

#
# Service discovery
#
 
druid.selectors.indexing.serviceName=druid/overlord
druid.selectors.coordinator.serviceName=druid/coordinator
 
#
# Monitoring
#
 
druid.monitoring.monitors=["com.metamx.metrics.JvmMonitor"]
druid.emitter=logging
druid.emitter.logging.logLevel=info
```

- **druid.extensions.loadList**: 该列表加载的依赖需要放置到<druid-io根目录>/extensions/下面加载的依赖名为文件夹名称

- **druid.zk.service.host && druid.zk.paths.base**: 对于zookeeper的集群主机配置&&在zookeeper中的根路径配置
- **druid.metadata.storage.***: 对于druid-io的存储介质配置默认为内置的derby数据库,对于配置mysql存储介质的话需要提前将mysql链接jar放置到<druid-io根目录>/lib/目录下
- **druid.storage.type && druid.storage.storageDirectory**: 对于druid-io生成的segments保存位置默认为local && segments保存的文件夹路径(可以为local，hdfs，s3)
- **druid.indexer.logs.***: 对于druid-io的索引日志配置默认为local(可以为local，hdfs，s3)
- **druid.selectors.indexing.serviceName**: 对于druid-io的索引服务名称
- **druid.selectors.coordinator.serviceName**: 对于druid-io的coordinator服务名称
- **druid.monitoring.monitors**: 对于druid-io的监控指标配置，配置为列表
- **druid.emitter**: 对于druid-io的插件发射器配置比如log日志配置为：

```java
druid.emitter=logging
druid.emitter.logging.logLevel=info
```

### log4j2.xml配置文件

---

```java
vim conf/druid/_common/log4j2.xml
```

修改文件内容如下:

```java
<?xml version="1.0" encoding="UTF-8" ?>
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{ISO8601} %p [%t] %c - %m%n"/>
        </Console>
    </Appenders>
    <Loggers>
        <Root level="info">
            <AppenderRef ref="Console"/>
        </Root>
    </Loggers>
</Configuration>
```

> 该文件详细配置可参考log4j官网进行