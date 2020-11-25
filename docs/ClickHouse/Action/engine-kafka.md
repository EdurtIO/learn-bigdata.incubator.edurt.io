---
layout: default
title: ClickHouse整合Kafka
nav_order: 100
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

要将数据从Kafka主题读取到ClickHouse表，我们需要三件事：

- 一个目标MergeTree表，以提供接收数据的宿主
- Kafka引擎表，使主题看起来像ClickHouse表
- 物化视图，可将数据自动从Kafka移动到目标表

### 创建存储消费数据表

---

创建`kafka_readings`用于接收Kafka的数据，登录到ClickHouse并执行以下SQL

```sql
CREATE TABLE kafka_readings (
    id String,
    platForm String,
    appname String,
    time DateTime
) Engine = MergeTree
PARTITION BY toYYYYMMDD(time)
ORDER BY (time);
```

- `MergeTree` 指定创建表的引擎
- `PARTITION BY` 指定我们的分区数据，我们使用时间转换为ymd格式
- `ORDER BY` 指定我们的排序规则，当然也可以不指定

### 创建消费Kafka数据表

---

使用Kafka引擎创建一个表以连接到主题并读取数据。该引擎将使用消费主题`test`和消费者组`test_consumer_group1`从kafka的集群中读取数据。输入格式为`JSONEachRow`。

> 请注意，我们省略了`time`列。这是目标表中的别名，将从`time`列自动填充。

登录到ClickHouse并执行以下SQL

```sql
CREATE TABLE kafka_readings_queue (
    id String,
    platForm String,
    appname String,
    time DateTime
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'kafka-cluster-001:9092,kafka-cluster-002:9092',
       kafka_topic_list = 'test',
       kafka_group_name = 'readings_consumer_group1',
       kafka_format = 'JSONEachRow';
```

- `kafka_broker_list` kafka消费集群的broker列表
- `kafka_topic_list` 消费kafka的Topic
- `kafka_group_name` kafka消费组
- `kafka_format` 消费数据的格式化类型，当然还有其他格式的数据详见[Formats for Input and Output Data](https://clickhouse.tech/docs/en/interfaces/formats/)
    - JSONEachRow表示每行一条数据的json格式。一般如果是json格式的话，设置JSONEachRow即可
    - 如果需要输入嵌套的json，请设置input_format_import_nested_json=1

### 创建物化视图合并表传输数据

---

我们已经创建了本地数据表和消费Kafka表，最后需要创建视图表方便把数据导入到ClickHouse，登录到ClickHouse并执行以下SQL

```sql
CREATE MATERIALIZED VIEW kafka_readings_view TO kafka_readings AS
SELECT id, platForm, appname, time
FROM kafka_readings_queue;
```

### 测试各个数据表

---

我们使用以下SQL分别去测试查询数据

- 查询`kafka_readings`表，会返回相关数据总数

```sql
select count(1) from kafka_readings;
```

```bash
SELECT count(1)
FROM kafka_readings

Query id: 25375f84-9271-4e7b-bf32-cf1ccadef78e

┌─count(1)─┐
│     8834 │
└──────────┘

1 rows in set. Elapsed: 0.003 sec.
```

- 查询`kafka_readings_queue`表，会返回当前Kafka新增消费数据总数(连接kafka会有些慢)

```sql
select count(1) from kafka_readings_queue;
```

```bash
SELECT count(1)
FROM kafka_readings_queue

Query id: 420b4430-673e-411c-8db9-509fcc23feef

┌─count(1)─┐
│        0 │
└──────────┘

1 rows in set. Elapsed: 7.215 sec.
```

如果有新增数据的话那么这里的`count(1)`就是非0数据，这里的数会出现变化，根据新的数据而定

- 查询`kafka_readings_view`表，一般得到的数据和`kafka_readings`相差无几，除非实时数据很多

```sql
select count(1) from kafka_readings_view;
```

```bash
SELECT count(1)
FROM kafka_readings_view

Query id: 302e3306-dc38-4668-9469-edd109430e39

┌─count(1)─┐
│     8861 │
└──────────┘

1 rows in set. Elapsed: 0.003 sec. Processed 8.86 thousand rows, 35.44 KB (3.13 million rows/s., 12.50 MB/s.)
```

### 创建分布式表

---

```sql
CREATE TABLE kafka_readings_distributed ON CLUSTER mycluster_1
(
    id String,
    platForm String,
    appname String,
    time DateTime
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/replicated/{shard}/kafka_readings_distributed', '{replica}')
PARTITION BY ymd
ORDER BY id
```

> 这里也可以去创建Distributed表，看情况而定

- 创建视图的转换

```sql
CREATE MATERIALIZED VIEW kafka_readings_distributed_view TO kafka_readings_distributed AS
SELECT id, platForm, appname, time
FROM kafka_readings_queue;
```

此时去查询该表数据即可。