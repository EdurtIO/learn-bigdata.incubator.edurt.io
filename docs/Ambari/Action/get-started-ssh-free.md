---
layout: default
title: 配置集群各主机SSH免密
nav_order: 2
parent: Action(实战)
grand_parent: Ambari
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}


### 基本环境信息

---

|主机名|IP|版本|
|:---:|---|---|
|ambari-common|10.10.0.201|CentOS 7|
|ambari-server|10.10.0.202|CentOS 7|
|ambari-agent-001|10.10.0.203|CentOS 7|
|ambari-agent-002|10.10.0.204|CentOS 7|
|ambari-agent-003|10.10.0.205|CentOS 7|

### 设置机器节点信息

---

- 修改主机名(登录到集群中的所有节点进行操作)

```java
echo 'ambari-common' > /etc/hostname
```

- 设置主机列表到系统环境

```java
vim /etc/hosts
```

在文件中末尾追加以下内容：

```java
# ambari cluster hosts
10.10.0.201 ambari-common
10.10.0.202 ambari-server
10.10.0.203 ambari-agent-001
10.10.0.204 ambari-agent-002
10.10.0.205 ambari-agent-003
```

