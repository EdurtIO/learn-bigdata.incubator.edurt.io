---
layout: default
title: ClickHouse整合Kafka(写数据)
nav_order: 102
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

本文章主要讲解如何将ClickHouse中的消息写回到Kafka。
ClickHouse读取Kafka数据详见[ClickHouse整合Kafka(读数据)]({{ site.baseurl }}{% link docs/ClickHouse/Action/engine-kafka-reader.md %})

### Kafka相关操作

---

- 在Kafka中创建`kafka_writers`Topic用于接收ClickHouse写入的数据

```
kafka-topics \
--zookeeper localhost:2181 \
--topic kafka_writers \
--create --partitions 2 \
--replication-factor 2
```

执行命令后返回如下响应

```
Created topic "kafka_writers".
```

这标志着topic已经创建成功。

### ClickHouse相关操作

---

- 创建`kafka_writers_reader`表，用于标记读取kafka数据[**此处也不可以操作**]

```
CREATE TABLE kafka_writers_reader \
( \
    `id` Int, \
    `platForm` String, \
    `appname` String, \
    `time` DateTime \
) \
ENGINE = Kafka \
SETTINGS kafka_broker_list = 'localhost:9092', kafka_topic_list = 'kafka_writers_reader', kafka_group_name = 'kafka_writers_reader_group', kafka_format = 'CSV';
```

- 我们需要使用Kafka表引擎定义一个表，该表指向我们的`kafka_writers`主题。该表可以读取和写入Kafka消息(我们在此只做写入操作)。

```
CREATE TABLE kafka_writers_queue ( \
    id Int, \
    platForm String, \
    appname String, \
    time DateTime \
) \
ENGINE = Kafka \
SETTINGS kafka_broker_list = 'localhost:9092', \
       kafka_topic_list = 'kafka_writers', \
       kafka_group_name = 'kafka_writers_group', \
       kafka_format = 'CSV', \
       kafka_max_block_size = 1048576;
```

> 此处我们为了方便使用了CSV格式化数据格式，具体的数据格式根据数据而定。

- 创建`kafka_writers_view`物化视图用于将ID大于5的数据输入到`kafka_writers`Topic中

```
CREATE MATERIALIZED VIEW kafka_writers_view TO \
kafka_writers_queue AS \
SELECT id, platForm, appname FROM kafka_writers_reader \
WHERE id >= 20;
```

### 验证Kafka数据的写入

---

- 登录到Kafka集群中消费`kafka_writers`数据

```
kafka-console-consumer --bootstrap-server localhost:9092 --topic kafka_writers
```

- 新开另一个窗口对`kafka_writers_reader`Kafka主题做生产数据操作

```
kafka-console-producer --broker-list kafka:9092 --topic kafka_writers_reader <<END
4,"Data","Test","2020-12-23 14:45:31"
5,"Plan","Test1","2020-12-23 14:47:32"
22,"Plan","Test2","2020-12-23 14:52:15"
7,"Data","Test3","2020-12-23 14:54:39"
END
```

> 如果我们没有创建`kafka_writers_reader`主题的话，我们可以忽略此步骤使用下一步方式

- 插入ClickHouse数据到``表中

```
INSERT INTO kafka_writers_reader (id, platForm, appname, time) \
VALUES (4,'Data','Test','2020-12-23 14:45:31'), \
(5,'Plan','Test1','2020-12-23 14:47:32'), \
(22,'Plan','Test2','2020-12-23 14:52:15'), \
(7,'Data','Test3','2020-12-23 14:54:39');
```

经过短暂的时候后，我们会在消费`kafka_writers`窗口下看到以下信息的输出

```
"22","Plan","Test2","1970-01-01 08:00:00"
```

这标志着我们的数据已经成功写入Kakfa中。