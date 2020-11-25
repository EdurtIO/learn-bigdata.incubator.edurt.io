---
layout: default
title: ClickHouse整合Kafka(元数据)
nav_order: 101
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 重读Kafka数据

---

默认从Kafka Topic的开始位置开始，并在到达消息时对其进行读取。这是正常的方式，但是有时重新读取消息很有用。例如，您可能想在修复架构中的错误或重新加载备份后重新读取消息。幸运的是，这很容易做到。我们只是在消费者组中重置偏移量。

- 假设我们丢失了读数表中的所有消息，并希望从Kafka重新加载它们。首先，让我们使用TRUNCATE命令重载数据。

```sql
TRUNCATE TABLE kafka_readings;
```

- 在重置分区上的偏移之前，我们需要关闭消息使用。通过在ClickHouse中分离`kafka_readings_queue`表来执行此操作，如下所示。 

```sql
DETACH TABLE kafka_readings_queue;
```

- 接下来，使用以下Kafka命令在用于kafka_readings_queue表的使用者组中重置分区偏移量。

> 注意：改命令需要在Kafka中进行操作。

```bash
kafka-consumer-groups --bootstrap-server kafka-cluster-001:9092,kafka-cluster-002:9092 \
 --topic test --group readings_consumer_group1 \
 --reset-offsets --to-earliest --execute
```

- 登录到`ClickHouse`，重新连接`kafka_readings_queue`表

```sql
ATTACH TABLE kafka_readings_queue;
```

等待几秒钟，丢失的记录将被恢复。此时可以使用`SELECT`进行查询。 

### 添加数据列

---

显示原始Kafka信息作为行通常很有用，Kafka表引擎也定义了虚拟列，以下更改数据表以显示Topic分区和偏移量的方法。

- 分离Kafka表来禁用消息使用。不影响数据的生产

```sql
DETACH TABLE kafka_readings_queue;
``` 

- 依次执行以下SQL命令来更改目标表和实例化视图

> 注意：我们只是重新创建实例化视图，而我们更改了目标表，该表保留了现有数据。

```sql
ALTER TABLE kafka_readings
  ADD COLUMN name String;
```

- 删除并重新构建视图表

```sql
DROP TABLE kafka_readings_view;

CREATE MATERIALIZED VIEW kafka_readings_distributed_view TO kafka_readings_distributed AS
SELECT id, platForm, appname, time, name
FROM kafka_readings_queue;
```

- 重新连接`kafka_readings_queue`表来再次启用消息使用

```sql
ATTACH TABLE readings_queue
```

- 查询数据表信息

```sql
select * from kafka_readings_view;
```

```bash
Query id: 52a27f19-eab1-4932-bc13-51792557809d

┌─id─────────────────────────────┬─platForm──┬─appname─┬────────────────time─┬───name─┐
│ 20201123123337811-840028       │ kafka     │         │ 2020-11-23 12:33:42 │  test  │
└────────────────────────────────┴───────────┴─────────┴─────────────────────┴────────┘

1 rows in set. Elapsed: 0.003 sec. Processed 2.51 thousand rows, 176.96 KB (985.20 thousand rows/s., 69.38 MB/s.)
```

> 注意：kafka源数据中需要包含新的字段列，否则数据就是null
>
> 消息格式更改时升级架构的方法不变。同样，物化视图提供了一种非常通用的方式来使Kafka消息适应目标表数据。您甚至可以定义多个实例化视图，以将消息流拆分到不同的目标表中。
