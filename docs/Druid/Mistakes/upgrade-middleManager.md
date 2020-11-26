---
layout: default
title: middleManager节点升级
nav_order: 100
parent: Mistakes(问题)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

我们在升级druid服务的时候,升级`historical`,`overlord`,`broker`,`coordinator`这些服务很简单,但是由于在`middleManager`节点中运行着大量的task计算任务,我们升级的话需要进行一些安全操作.

### 升级准备

---

- 禁止Overlord再向指定服务的MiddleManager分配任务**必须操作**

```bash
curl -X POST http://<MiddleManager_IP:PORT>/druid/worker/v1/disable
```

该操作会告诉overlord节点,不让其在为该MiddleManager节点进行分配任务,此时的`Druid Overlord Console`页面中该MiddleManager节点的`work version`无任何显示,默认启用状态显示0标志.

- 查看指定MiddleManager任务列表**建议升级时使该节点的所有task结束后做升级操作**

```bash
curl -X GET http://<MiddleManager_IP:PORT>/druid/worker/v1/tasks
```

### 升级操作

---

- 停止旧版middleManager节点

```java
ps -ef|grep 'io.druid.cli.Main server middleManager'|grep -v grep| awk '{print $2}' | xargs kill
```

- 启动新版middleManager节点

```bash
cd /hadoop/data1/druid-0.16.0
./bin/middleManager.sh start
```

启动日志位于./log/middleManager.log,确保服务启动成功后,程序升级成功

- 启用Overlord向指定MiddleManager分配任务**必须操作,否则无法分配任务**

```bash
curl -X POST http://<MiddleManager_IP:PORT>/druid/worker/v1/enable
```