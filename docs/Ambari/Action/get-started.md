---
layout: default
title: Ambari使用场景及介绍
nav_order: 2
parent: Action(实战)
grand_parent: Ambari
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

本篇文章主要讲解Ambari的一些基础知识，让大家对Ambari有一个潜意识的认识。

### 什么是Ambari？

---

Apache Ambari是一种基于Web的集群管理工具，支持Apache Hadoop的供应，管理和监控。Ambari目前已支持大多数Hadoop组件，包括HDFS，MapReduce，Hive，Pig，HBase，Zookeeper，Sqoop和HCatalog等。

Apache Ambari支持HDFS，MapReduce，Hive，Pig，HBase，Zookeeper，Sqoop和HCatalog等的集中管理。也是5个顶级Hadoop集群管理工具之一。

### Ambari支持的组件？

---


| 组件服务 | 是否支持 |
| --- | --- |
| HDFS | 是 |
| HBase | 是 |
| Hive | 是 |
| Yarn | 是 |
| Storm | 是 |
| Kafka | 是 |
| Knox | 是 |
| Solr | 是 |
| Druid | 是 |
| 更多(自定义) | 是 |

### Ambari的功能

---

Ambari和Hadoop等开源软件一样，也是Apache Software Foundation组织中的一个项目，并且是顶级项目。目前最新的发布版本是2.7.5(2020年)，未来不久将发布其他的版本。就Ambari的作用来说，就是创建，管理，监控Hadoop集群，但是这里的Hadoop是广义的，指的是Hadoop整个生态圈(例如Hive，HBase，Sqoop，Zookeeper等)，而并不是特指Hadoop。用一句话来说，Ambari就是为了让Hadoop及相关的大数据组件更容易使用的一个工具。

### Ambari的业绩

---

通过一步一步的安装向导简化了集群供应。

- 预先配置好关键的运维指标(Metrics)，也可以直接查看Hadoop Core(HDFS和MapReduce)及相关项目(如HBase，Hive和HCatalog等)是否健康。
- 支持作业与任务执行的可视化和分析，能够更好的查看依赖和性能。
- 通过一个完成的RESTful API把监控信息暴露出来，集成了现有的监控运维工具。
- Ambari使用Ganglia收集度量指标，用Nagios支持系统报警，当需要引起管理员的关注时(比如，节点停机或磁盘剩余空间不足等问题)，系统将向其发送邮件。
- Ambari能够安装安全的(基于Kerberos)Hadoop集群，以此实现了对Hadoop安全的支持，提供了基于角色的用户认证，授权和审计功能，并为用户管理集成了LDAP和Active Directory。

### Ambari使用场景

---

- Hadoop集群管理及一键部署
- Spark集群管理及一键部署
- Storm集群管理及一键部署
- Kafka集群管理及一键部署
- ......更多的集群组件管理及一键部署

### Ambari系统架构

---

![](/assets/images/Ambari/Action/get-started/Ambari-System-architecture.PNG)

Ambari核心分为

- `Ambari Server` 管理Ambari的底层服务，提供大量的RESTful API接口
- `Ambari Agent` 用于监控管理集群节点的各种指标并上报至Ambari Server
- `Ambari Web` Ambari服务的可视化UI界面
- `Ambari Ams` Ambari的核心监控中心

### Ambari核心开发语言

---

- Java
- Python

大部分都是使用Java进行开发的。