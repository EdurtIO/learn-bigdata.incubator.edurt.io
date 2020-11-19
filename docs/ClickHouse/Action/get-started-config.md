---
layout: default
title: ClickHouse集群配置
nav_order: 3
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 注意：我们需要在每台节点中部署ClickHouse部署方式详见[ClickHouse安装部署]({{ site.baseurl }}{% link docs/ClickHouse/Action/get-started.md %})

我们一般配置ClickHouse集群只需要修改Zookeeper存储和节点添加即可。

### 节点信息

---

|主机|IP|
|:---:|---|
|ck1|10.10.0.1|
|ck2|10.10.0.2|
|ck3|10.10.0.3|

### 配置Zookeeper

---

在`/etc/clickhouse-server/config.xml`文件中添加以下配置信息

```xml
<zookeeper>
    <node index="1">
        <host>zk1</host>
        <port>2181</port>
    </node>
    <node index="2">
        <host>zk2</host>
        <port>2181</port>
    </node>
    <node index="3">
        <host>zk3</host>
        <port>2181</port>
    </node>
</zookeeper>
```

改配置文件主要配置连接Zookeeper的信息，每个节点的index不可重复

> 注意要添加到yandex节点中

### 配置ClickHouse集群

---

配置ClickHouse集群节点需要配置`remote_servers`节点

在`/etc/clickhouse-server/config.xml`文件中添加以下配置信息

```xml
<remote_servers>
    <ck_cluster>
        <shard>
            <weight>1</weight>
            <internal_replication>true</internal_replication>
            <replica>
                <host>ck1</host>
                <port>9000</port>
            </replica>
            <replica>
                <host>ck2</host>
                <port>9000</port>
            </replica>
        </shard>
        <shard>
            <weight>1</weight>
            <internal_replication>true</internal_replication>
            <replica>
                <host>ck2</host>
                <port>9000</port>
            </replica>
            <replica>
                <host>ck3</host>
                <port>9000</port>
            </replica>
        </shard>
        <shard>
            <weight>1</weight>
            <internal_replication>true</internal_replication>
            <replica>
                <host>ck3</host>
                <port>9000</port>
            </replica>
            <replica>
                <host>ck1</host>
                <port>9000</port>
            </replica>
        </shard>
    </ck_cluster>
</remote_servers>
```

- `ck_cluster` 集群标识，可以自行规定，在创建分布式表（引擎为Distributed）时需要用到。
- `weight` 每个分片的写入权重值，数据写入时会有较大概率落到weight值较大的分片，这里全部设为1。
- `internal_replication` 是否启用内部复制，即写入数据时只写入到一个副本，其他副本的同步工作靠复制表和ZooKeeper异步进行。

> 我们在shard分片中设置的是循环分片这样保证我们复制的节点某一个宕机后可以正常运行
> 
> 将配置分发到所有部署ClickHouse的节点中进行服务重启

此时我们的ClickHouse集群已经搭建完成！