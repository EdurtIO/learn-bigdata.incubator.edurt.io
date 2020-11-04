---
layout: default
title: Presto源码编译
nav_order: 2
has_children: false
parent: Development(开发)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

我们进行Presto二次开发的话必须要执行以下操作步骤.

### 必要环境

|环境|版本|
|---|---|
|System|Mac(Linux)**不推荐使用Windows**|
|Java|11+|
|Maven|3.6+|
|Python|2.4+|
|IDEA(Eclipse)|-|

### 克隆源码

> 源码文件较大,克隆可能较慢,视网络而言

```java
git clone https://github.com/prestodb/presto.git
```

### 进行编译

- 进入源码目录

```java
cd presto
```

- 编译源码

如果本机已安装Maven(也可以执行未安装的命令)

```java
mvn clean install package -DskipTests -Dcheckstyle.skip -X
```

未安装Maven执行

```java
./mvnw clean install package -DskipTests -Dcheckstyle.skip -X
```

> 注意: 出现的错误详见*常见错误模块*
> 如果编译出现错误`java.lang.OutOfMemoryError: unable to create new native thread`此时建议单独编译出现错误的模块