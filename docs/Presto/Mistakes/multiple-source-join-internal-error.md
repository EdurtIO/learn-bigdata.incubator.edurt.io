---
layout: default
title: Presto Join查询出现Internal error
nav_order: 7
has_children: false
parent: Mistakes(问题)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

通过字面意思我们可以判断出来是系统内部出现了问题？那么该问题是怎么产生的呢？

该问题产生是一般是在使用`Presto`进行了Join关联查询，导致关联的两个表中的关联字段不一致导致的。

### 错误信息

---

比如我有两个数据表，分别是`t1`表和`t2`表，他们的表结构分别是：

- t1表结构

|列名|类型|
|---|---|
|c1|bigint|
|c2|bigint|


- t2表结构

|列名|类型|
|---|---|
|c1|bigint|
|c2|varchar (hive中是string)|

当我们使用以下两个SQL查询时，会出现不通的结果

```sql
select
    t1.c1, t2.c1
from t1 as t1
left join t2 as t2
on t1.c1 = t2.c1
limit 1
```

在Presto中我们运行以上sql是可以正确拿到查询结果的，但我们换作以下SQL就会出现不同的结果

```sql
select
    t1.c2, t2.c2
from t1 as t1
left join t2 as t2
on t1.c2 = t2.c2
limit 1
```

此时运行SQL就会出现`Internal error`错误信息

### 解决方案

---

单单通过返回`Internal error`的错误信息我们是无法获取到有效的信息的，但是我们细心观察会发现

在t1表中的c2字段的类型是bigint，然而在t2表中的c2字段是varchar类型的

这样我们会的出一个结论就是由于两个表的字段类型不一致而产生了这个错误，既然知道了错误，解决也就简单了

我们尝试对关联表的关联字段做cast转换，转换为同一类型，修改后的sql如下

```sql
select
    t1.c2, t2.c2
from t1 as t1
left join t2 as t2
on cast(t1.c2 as varchar) = cast(t2.c2 as varchar)
limit 1
```

运行修改后的sql可以正常查询出来有效的结果，为了方便用户，建议写SQL的时候做一下操作(前提是使用Presto引擎查询)

> 在做关联查询的时候，将双表的关联字段做成cast(xxxx as varchar), 当然转换为其他的类型也可以