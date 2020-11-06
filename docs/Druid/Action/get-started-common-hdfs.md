---
layout: default
title: common全局配置HDFS
nav_order: 4
parent: Action(实战)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 以下操作需要进入druid-io安装文件的根目录下操作，比如我的druid-io安装目录为：/hadoop/dc/druid-0.9.1.1 那么我们需要操作 cd /hadoop/dc/druid-0.9.1.1

### 修改Druid配置

---

修改`_common/common.runtime.properties`配置文件

```java
vim _common/common.runtime.properties
```

修改文件中`druid.storage`配置信息为以下内容

```java
druid.extensions.hadoopDependenciesDir=/hadoop/dc/druid/hadoop-dependencies/hadoop-client/2.7.3
druid.storage.type=hdfs
druid.storage.storageDirectory=hdfs://nameservice1/druid/segments
#注释掉原来的本地存储
#druid.indexer.logs.type=file
#druid.indexer.logs.directory=/hadoop/dc/indexing-logs
#druid.storage.type=local
#druid.storage.storageDirectory=/hadoop/dc/segments
```

`druid.extensions.hadoopDependenciesDir`: 用于配置Hadoop相关依赖的jar文件夹地址

`druid.storage.storageDirectory`: 配置数据存储的地址，对于ha的集群来说只需要填写ha的地址即可

### 配置hadoop依赖

---

我们在`druid.extensions.hadoopDependenciesDir`配置中指定了hadoop依赖的位置，就需要我们将依赖jar放置到该位置

拷贝hadoop集群相关的配置信息到_common文件夹中(改配置文件在集群中可下载CDH or HDP均可)

```java
mv core-site.xml /hadoop/dc/druid/conf/druid/_common/
mv hdfs-site.xml /hadoop/dc/druid/conf/druid/_common/
mv mapred-site.xml /hadoop/dc/druid/conf/druid/_common/
mv yarn-site.xml /hadoop/dc/druid/conf/druid/_common/
```

将hadoop相关的依赖jar拷贝到`druid.extensions.hadoopDependenciesDir`配置的目录中即可

> 拷贝修改后的配置文件发送到各个节点重启服务器即可