---
layout: default
title: Tez安装部署
nav_order: 2
has_children: false
parent: Action(实战)
grand_parent: Tez
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}
   
对于Tez的安装部署我们通过两个方面来讲诉，一个就是原生支持Apache Hadoop(或者HDP)，另一中就是在CDH的环境中集成使用。

### 基础环境

---

- 以下是安装服务的必要环境

|依赖|版本|
|:---:|---|
|Tez|>= 0.10.x|
|CentOS|7.x|
|Java|1.8.0_212+|
|Hadoop|Apache(HDP) 3.x - CDH6.0.x|
|Node|v8.x|

### Tez On Apache(HDP)编译

---

> 注意我们需要Protobuf 2.5.0的环境支持，具体怎么安装可通过网上自行查询改资料很多。

由于tez已经是apache中的顶级项目所以对于集成Apache版或者HDP版本的Hadoop生态圈比较简单，我们只需要下载官方提供的下载包即可使用，不过我们不建议直接使用该包安装，建议使用源码编译进行安装。

- 我们先将tez的源码克隆到本地

```java
git clone https://github.com/apache/tez.git
```

- 修改tez根目录中的`pom.xml`中hadoop的依赖

修改`<hadoop.version>3.1.3</hadoop.version>`为公司线上的hadoop实际版本

- 使用以下命令进行源码编译

```java
mvn install package -DskipTests -Dcheckstyle.skip -X
```

如果出现jar冲突问题可以增加`-U`参数进行依赖强制覆盖操作

### Tez On CDH

---

- 修改tez根目录中的`pom.xml`中hadoop的依赖

修改`<hadoop.version>3.1.3</hadoop.version>`为公司线上的hadoop实际版本，比如我们的是`3.0.0-cdh6.0.1`那么该参数修改为`<hadoop.version>3.0.0-cdh6.0.1</hadoop.version>`

- 由于CDH版本的集群比较特殊，需要通过CDH的Maven的中央仓库下载依赖，还需要添加CDH的仓库地址，同样修改根目录的`pom.xml`文件在`repositories`节点中增加以下代码

```java
<repository>
    <id>cloudera</id>
    <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
    <name>Cloudera Repositories</name>
    <snapshots>
        <enabled>false</enabled>
    </snapshots>
</repository>
```

- 我们还需要支持以下CDH的插件下载，修改根目录的`pom.xml`文件在`pluginRepositories`节点中增加以下代码

```java
<pluginRepository>
    <id>cloudera</id>
    <name>Cloudera Repositories</name>
    <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
</pluginRepository>
```

- 使用以下命令进行源码编译

```java
mvn install package -DskipTests -Dcheckstyle.skip -X
```

如果出现jar冲突问题可以增加`-U`参数进行依赖强制覆盖操作

### 安装部署Tez

---

不管我们使用以上哪两种方式编译完以后会在`tez-dist/target`生成以下目录结构

```java
drwxr-xr-x   2 shicheng  staff    64B  9 10 11:01 archive-tmp
drwxr-xr-x   3 shicheng  staff    96B  9 10 11:03 maven-archiver
drwxr-xr-x  30 shicheng  staff   960B  9 10 11:02 tez-0.10.1-SNAPSHOT
drwxr-xr-x  28 shicheng  staff   896B  9 10 11:03 tez-0.10.1-SNAPSHOT-minimal
-rw-r--r--   1 shicheng  staff    17M  9 10 11:03 tez-0.10.1-SNAPSHOT-minimal.tar.gz
-rw-r--r--   1 shicheng  staff    52M  9 10 11:02 tez-0.10.1-SNAPSHOT.tar.gz
-rw-r--r--   1 shicheng  staff   2.9K  9 10 11:03 tez-dist-0.10.1-SNAPSHOT-tests.jar
```

核心的文件我们需要使用`tez-0.10.1-SNAPSHOT.tar.gz`，当然`tez-0.10.1-SNAPSHOT-minimal.tar.gz`也可以使用，但是我们不建议这么去做，这里少了好多依赖不建议去使用。

- 编译完成后我们将打包后的文件上传到HDFS中，方便集群的其他节点使用

```java
hadoop fs -put -f tez-0.10.1-SNAPSHOT.tar.gz /user/tez/
```

`-f`参数标志我们要强制覆盖原有的文件

- 在`{HIVE_HOME}/conf`目录下创建`tez-site.xml`文件，或者直接修改`hive-site.xml`配置文件，键入内容如下

```java
<configuration>
    <property>
        <name>tez.lib.uris</name>
        <value>${fs.defaultFS}/user/tez/tez-0.10.1-SNAPSHOT.tar.gz</value>
    </property>
</configuration>
```

- 增加tez的环境变量支持方便hive可以使用，修改`{HIVE_HOME}/conf`目录下的`conf/hive-env.sh`脚本文件，在文件末尾增加类似以下内容

```java
export TEZ_HOME=<TezHome>

CDH可以使用类似

HADOOP_CLASSPATH=/opt/cloudera/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554/lib/tez/conf:/opt/cloudera/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554/lib/tez/*:/opt/cloudera/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554/lib/tez/lib/*
```

或者直接拷贝所有的tez相关文件到hive的目录中

### 调试使用Tez

---

- 我们通过hive客户端连接到hive窗口中输入以下命令设置hive执行引擎为tez

```java
set hive.execution.engine=tez;
```

当然我们可以修改`hive-site.xml`配置文件自动启用tez引擎，由于我们现在是测试所以做临时生效配置。

- 执行我们的测试sql

```java
select count(1) from temp.t1;
```

出现以下内容即为成功

```java
----------------------------------------------------------------------------------------------
        VERTICES      MODE        STATUS  TOTAL  COMPLETED  RUNNING  PENDING  FAILED  KILLED
----------------------------------------------------------------------------------------------
Map 1 .......... container     SUCCEEDED      2          2        0        0       0       0
Reducer 2        container     SUCCEEDED      1          0        0        1       4       0
----------------------------------------------------------------------------------------------
VERTICES: 01/02  [========================>>] 100%   ELAPSED TIME: 19.70 s
----------------------------------------------------------------------------------------------
```

> 建议删除tez目录下的所有hadoop包，使用`tez.use.cluster.hadoop-libs`参数接管
