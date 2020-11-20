---
layout: default
title: ClickHouse多集群配置
nav_order: 4
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 为了我们方便找到我们的配置信息，我们将CK集群做分开配置

### 修改集群配置

---

- 修改`vim /etc/clickhouse-server/config.xml`配置文件

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

删除以上两个配置信息，新增以下内容

```xml
<remote_servers incl="clickhouse_remote_servers" />
<zookeeper incl="zookeeper-servers" optional="true" />

<include_from>/etc/clickhouse-server/ck-cluster.xml</include_from>
```

- `remote_servers` 标志我们在外部文件中引用的集群配置节点是`clickhouse_remote_servers`
- `zookeeper` 标志我们在外部文件引用的ZK集群配置节点是`zookeeper-servers`
- `include_from` 标志我们引用的外部配置文件，指定文件的绝对路径

### 新建集群配置文件

---

刚刚我们指定了`/etc/clickhouse-server/ck-cluster.xml`配置文件，此时我们需要去对该文件做配置

- 创建新的配置文件

```bash
touch /etc/clickhouse-server/ck-cluster.xml
```

在新的配置文件中增加`zookeeper`和`clickhouse`集群信息

```xml
<yandex>
    <zookeeper-servers>
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
    </zookeeper-servers>
    
    <clickhouse_remote_servers>
        <ck_cluster>
            <shard_1>
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
            </shard_1>
            <shard_2>
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
            </shard_2>
            <shard_3>
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
            </shard_3>
        </ck_cluster>
    </clickhouse_remote_servers> 

    <networks>
        <ip>::/0</ip>
    </networks>
</yandex>
```

> 此处需要注意的是在yandex中配置的相关节点一定到和config.xml中的`<remote_servers incl="clickhouse_remote_servers" />
                                          <zookeeper incl="zookeeper-servers" optional="true" />`这两个属性的incl一致，否则会扫描不到集群标志
> 修改配置后我们不需要重启服务，ClickHouse会自动加载修改后的配置信息
> 我们配置多个集群使用多个配置文件即可，多个replica节点配置多个也是可以的
