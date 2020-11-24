---
layout: default
title: ReplicatedMergeTree表
nav_order: 5
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

如果我们需要使用ClickHouse的ReplicatedMergeTree表同步功能我们需要做一些配置操作

### 修改集群配置

---

- 修改配置文件支持读取外部配置信息

我们只需要修改`/etc/clickhouse-server/config.xml`集群配置文件，在该文件中增加类似以下配置信息

```xml
<macros incl="macros" optional="true" />
```

一般此配置默认在ClickHouse中存在的

- 创建配置信息，一般我们可一使用include方式或者在`/etc/clickhouse-server/config.d`文件夹下创建，默认该文件夹不存在，我们使用第二种方式配置

创建新的配置文件`macros-ck-cluster.xml`

```bash
mkdir /etc/clickhouse-server/config.d/
touch /etc/clickhouse-server/config.d/macros-ck-cluster.xml
```

在改配置文件中输入以下内容(注意每个节点的配置信息不相同，比如我们在ck1节点中操作，ck1节点的备份是ck2,那么ck1的配置信息如下)：

```xml
<yandex>
    <macros>
        <replica>ck2</replica>
        <shard>1</shard>
        <layer>ck_cluster</layer>
    </macros>
</yandex>
```

- `replica` 配置当前节点的备份同步节点信息
- `shard` 指定的是集群分片信息中的配置，在集群我配置的是`shard_1`
- `layer` 指定我们的集群标志，或者使用`cluster`关键字

### 创建ReplicatedMergeTree表

---

- 使用以下建表语句创建数据表

```sql
CREATE TABLE default.test ON CLUSTER mycluster_1
(
    `id` Int64,
    `ymd` Int64
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/replicated/{shard}/test', '{replica}')
PARTITION BY ymd
ORDER BY id
```

我们在创建表的时候指定了`ReplicatedMergeTree(xxxx)`，里面传递了两个参数，我们对这两个参数一一描述

- `/clickhouse/tables/` 这一部分指定的是在ZK上创建的路径地址，可随意变换只要记得即可
- `{shard}` 指的是分片的标志，同一个分片内的所有机器应该保持相同。建议使用使用的是集群名+分片名的配置也就是`{layer}-{shard}`，这里的数据就是在`macros`中配置的属性
- `test` 建议使用表名称
- `{replica}` 参数建议在`macros`配置成机器的hostname，因为每台机器的hostname都是不一样的，因此就能确保每个表的识别符都是唯一的了

- 登录ClickHouse客户端执行SQL创建数据表返回如下及创建成功

```bash
CREATE TABLE default.test ON CLUSTER mycluster_1
(
    `id` Int64,
    `ymd` Int64
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/replicated/{shard}/test', '{replica}')
PARTITION BY ymd
ORDER BY id

Query id: 63135671-8f24-4846-a0a8-471abf608305

┌─host──────────────────┬─port─┬─status─┬─error─┬─num_hosts_remaining─┬─num_hosts_active─┐
│ ck1 │ 9000 │      0 │       │                   1 │                1 │
└───────────────────────┴──────┴────────┴───────┴─────────────────────┴──────────────────┘
┌─host──────────────────┬─port─┬─status─┬─error─┬─num_hosts_remaining─┬─num_hosts_active─┐
│ ck2 │ 9000 │      0 │       │                   0 │                0 │
└───────────────────────┴──────┴────────┴───────┴─────────────────────┴──────────────────┘

2 rows in set. Elapsed: 0.301 sec.
```

### 测试ReplicatedMergeTree数据表

---

- 在ck1节点中插入数据到test表

```sql
insert into default.test values('1', '20201112');
```

返回类似如下信息标志插入成功

```bash
INSERT INTO default.test VALUES

Query id: 1333b8ce-74e2-4d67-a4b8-0183304bd661

Ok.

1 rows in set. Elapsed: 0.032 sec.
```

- 使用ClickHouse客户端连接ck1查询数据

```bash
clickhouse-client -h ck1 --port 9000 --multiquery --query="select * from test"
```

返回如下内容

```sql
1	20201112
```

- 使用ClickHouse客户端连接ck2查询数据查看数据是否同步

```bash
clickhouse-client -h ck2 --port 9000 --multiquery --query="select * from test"
```

返回如下内容

```sql
1	20201112
```

两台节点数据返回一致说明我们的分布式表创建成功。