---
layout: default
title: common全局配置MySQL
nav_order: 3
parent: Action(实战)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 以下操作需要进入druid-io安装文件的根目录下操作，比如我的druid-io安装目录为：/hadoop/dc/druid-0.9.1.1 那么我们需要操作 cd /hadoop/dc/druid-0.9.1.1

### 创建mysql-metadata-storage目录

---

```java
mkdir -p extensions/mysql-metadata-storage && cd extensions/mysql-metadata-storage
```

### 下载配置MySql

---

由于MySQL连接配置默认在Druid中没有被打包进来，所以需要我们手动去进行MySQL客户端连接包的下载

```java
wget https://www.mvnjar.com/central/maven2/io/druid/extensions/mysql-metadata-storage/0.9.1/mysql-metadata-storage-0.9.1.jar
wget http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
```

`mysql-metadata-storage-<DruidVersion>.jar`: Druid连接MySQL存储工具类
`mysql-connector-java-<MYSQLVERSION>.jar`: MySQL JDBC连接器

> 注意每个jar的版本，版本一定要对应，否则无法连接

### 修改Druid配置

---

修改`common.runtime.properties`配置文件，在文件中找到`druid.extensions.loadList`参数，在该参数的列表中增加`mysql-metadata-storage`配置，修改后的内容大概如下

```java
druid.extensions.loadList=["druid-kafka-eight", "druid-s3-extensions", "druid-histogram", "druid-datasketches", "druid-lookups-cached-global", "mysql-metadata-storage"]
```

> 如果配置文件中有其他的集成，列表中的只可能会更多。