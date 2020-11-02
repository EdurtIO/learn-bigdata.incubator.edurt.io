---
layout: default
title: 配置Elasticsearch数据源
nav_order: 2
has_children: false
parent: Action(实战)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 强烈建议使用Elasticsearch 6.0.0或更高版本

在实际工作中我们使用到elasticsearch的场景也很多,为了方便我们统一SQL的查询方式,我们需要将elasticsearch接入到presto中,当然这也是合理的,接下来我们讲解如何进行elasticsearch数据源的接入!

### 数据源配置

---

- 首先进入presto安装目录

```bash
cd <PrestoHome>
```

- 创建presto对接elasticsearch的配置文件

```bash
vim etc/catalog/elasticsearch.properties
```

在该文件中配置以下内容:

```java
connector.name=elasticsearch
elasticsearch.default-schema-name=test
elasticsearch.table-description-directory=etc/elasticsearch/
elasticsearch.scroll-size=1000
elasticsearch.scroll-timeout=30s
elasticsearch.request-timeout=2s
elasticsearch.max-request-retries=10
elasticsearch.max-request-retry-time=90s
elasticsearch.max-hits=1000000
```

参数的详细含义详见[官方文档](https://prestosql.io/docs/current/connector/elasticsearch.html)

### 数据表配置

---

我们配置的数据表目录是`etc/elasticsearch/`,所以我们需要在该目录下创建相关数据表配置

比如我们在es中有一个明教test的索引,索引大概如下

```json
{
    "test": {
        "mappings": {
            "elasticsearch": {},
            "doc": {
                "properties": {
                    "msg": {
                        "type": "text",
                        "fields": {
                            "keyword": {
                                "type": "keyword",
                                "ignore_above": 256
                            }
                        }
                    },
                    "query": {
                        "properties": {
                            "match": {
                                "properties": {
                                    "msg": {
                                        "type": "text",
                                        "fields": {
                                            "keyword": {
                                                "type": "keyword",
                                                "ignore_above": 256
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

在该索引中我们只有一个字段那就是msg,根据这个索引我们配置适配presto的数据表

数据表配置如下:

```json
{
    "tableName":"test",
    "schemaName":"test",
    "host":"localhost",
    "port": 9300,
    "clusterName":"es",
    "index":"test",
    "indexExactMatch":false,
    "type":"doc",
    "columns":[
        {
            "name":"msg",
            "type":"varchar",
            "jsonPath":"msg",
            "jsonType":"varchar"
        }
    ]
}
```

需要注意的是我们在columns中的类型指定的是presto中的数据类型
jsonPath针对于json数据而言,不是json数据的话直接使用key即可,详细的参数配置详见[官方文档](https://prestodb.io/docs/current/connector/elasticsearch.html)

> 注意事项:
> 
> 1. clusterName一定要于ES服务配置的一致,否则会出现无法连接错误
>
> 2. jsonPath配置格式为`$.key`

配置完成后重启presto服务即可

### 数据测试

---

- 连接presto客户端

```bash
presto-cli/target/presto-cli-0.235-SNAPSHOT-executable.jar  --server <PrestoServer>
```

- 执行查询sql

```bash
SELECT msg FROM elasticsearch.test.test limit 1;
```

`elasticsearch.test.test`: \<catalog>.\<database>.\<table>

返回结果如下:

```java
 msg 
-----
 你好 
(1 row)

Query 20200429_095419_00007_p45px, FINISHED, 1 node
Splits: 18 total, 18 done (100.00%)
0:05 [39.8K rows, 660KB] [8.12K rows/s, 135KB/s]
```

返回我们在ES中的数据结果,我们集成ES成功!

> 注意: 需要同步配置etc目录到所有的节点中,并重启服务