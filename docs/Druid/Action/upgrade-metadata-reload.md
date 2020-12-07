---
layout: default
title: Metadata损坏救治方案
nav_order: 102
parent: Action(实战)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

近期基于Druid的线上数据分析服务，由于底层的MySQL存储介质服务器导致数据大量元数据错乱（无法进行有效的数据展示），当我们dump数据库后，将dump的数据转移到新的MySQL服务器上后，将Druid的配置修改为新的MySQL存储介质后，启动服务，发现一个严重的问题，那就是我们的`Historical`数据查询节点无法进行Segment的数据Load，导致大量的数据无法使用，即使是配置Rule也无法进行有效的数据Load。后经过分析已经源码级别的回滚，发现一个问题那就是我们的Druid元数据有损坏，导致元数据版本无法正常加载到有效的Segment，从而导致我们无法对这部分的数据进行一个有效的查询操作，其实我们最后的解决方案就是将我们的元数据进行修复即可，后想起在开发代码的时候，有一个tools的工具，那么该工具就是我们针对元数据（元数据存储介质｜集群迁移）损坏后的一个回滚｜修复操作，这个工具是**insert-segment-to-db**！不过该工具我们已经在**0.15**的版本以后已经弃掉（元数据存储在`druid_segments`表和`descriptor.json`），原因是：

- 如果集群操作员手动删除或重新启用了任何Segment，则此信息不会反映在底层存储中。从底层存储还原元数据将撤消任何此类丢弃或重新启用的Segment。

- 分配Segment的摄取方法（例如本机Kafka或Kinesis流摄取，或“追加”模式下的本机批次摄取）可以将Segment写入底层存储，而Druid群集实际上并不打算使用这些Segment。没有办法，而纯粹的看着底层存储，以区分使它成为了元数据存储（因此Segment应该从没有在细分中使用）（因此不应该使用该工具）。

- 除`insert-segment-to-db`工具外，Druid中的所有内容都无法读取descriptor.json文件。

进行源码整改后，Druid停止将descriptor.json文件写入底层存储，现在仅将Segment元数据写入元数据存储。这意味着`insert-segment-to-db`工具不再提供使用，因此在Druid `0.15`中已将其删除。

> 我们强烈建议您定期备份元数据存储，因为没有它很难正确恢复Druid集群。

### 0.15版本以前的数据恢复方式

---

首先我们只需要执行以下命令即可进行底层元数据的恢复（修复）：

```bash
java 
-Ddruid.metadata.storage.type=mysql 
-Ddruid.metadata.storage.connector.connectURI='jdbc:mysql://localhost:3306/druid?useUnicode=true&characterEncoding=UTF-8' 
-Ddruid.metadata.storage.connector.user=druid 
-Ddruid.metadata.storage.connector.password='123456'  
-Ddruid.extensions.loadList=[\"mysql-metadata-storage\",\"druid-hdfs-storage\"] 
-Ddruid.storage.type=hdfs -cp <DruidHostConfigAndHome> io.druid.cli.Main tools insert-segment-to-db 
--workingDir <HdfsPath> 
--updateDescriptor true
```

`druid.metadata.storage`：配置的是相关修复后的元数据存储介质位置

`DruidHostConfigAndHome`：配置Druid相关的信息，例如：`conf/druid/_common:/hadoop/data/druid/lib/*`

`HdfsPath`：配置HDFS的数据目录（推荐按照DataSource进行元数据修复）

`--updateDescriptor`：这里一定要进行同步修复，否则会出现修复无法使用问题（原因是不同步：该工具永远是基于最新的Segement的状态来重建你的元数据，所以如果想保持与之前的元数据一致的话,最好是通过迁移元数据的方式来做DataSource数据迁移.）

> 需要注意的是：该工具运行后只要有Segment出现错误，那么该工具就会停止运行，建议删除错误的Segment后进行重复操作
> 建议是在安全模式下运行，最起码是恢复的DataSource不再进行任何写入操作，建议将整个集群进行临时关闭，不过该操作要视实际情况而定

> 如果是apache版本的话需要将`io.druid.cli.Main`修改为`org.apache.druid.cli.Main`