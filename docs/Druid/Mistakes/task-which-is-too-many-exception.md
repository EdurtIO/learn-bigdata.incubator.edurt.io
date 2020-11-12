---
layout: default
title: druid task which is too many Exception occurred during persist and merge
nav_order: 3
parent: Mistakes(问题)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 错误信息

---

druid集群执行task时任务运行FAILED,仔细查看log文件,我们发现出现以下两个错误:

- 错误一

```java
java.lang.IllegalStateException: Wrote[3155952492] bytes, which is too many.
	at com.google.common.base.Preconditions.checkState(Preconditions.java:200) ~[guava-16.0.1.jar:?]
	at io.druid.segment.data.GenericIndexedWriter.close(GenericIndexedWriter.java:109) ~[druid-processing-0.9.1.1.jar:0.9.1.1]
	at io.druid.segment.serde.ComplexMetricColumnSerializer.close(ComplexMetricColumnSerializer.java:76) ~[druid-processing-0.9.1.1.jar:0.9.1.1]
	at io.druid.segment.IndexMerger.makeIndexFiles(IndexMerger.java:877) ~[druid-processing-0.9.1.1.jar:0.9.1.1]
	at io.druid.segment.IndexMerger.merge(IndexMerger.java:423) ~[druid-processing-0.9.1.1.jar:0.9.1.1]
	at io.druid.segment.IndexMerger.mergeQueryableIndex(IndexMerger.java:244) ~[druid-processing-0.9.1.1.jar:0.9.1.1]
	at io.druid.segment.IndexMerger.mergeQueryableIndex(IndexMerger.java:217) ~[druid-processing-0.9.1.1.jar:0.9.1.1]
	at io.druid.segment.realtime.plumber.RealtimePlumber$4.doRun(RealtimePlumber.java:548) [druid-server-0.9.1.1.jar:0.9.1.1]
	at io.druid.common.guava.ThreadRenamingRunnable.run(ThreadRenamingRunnable.java:42) [druid-common-0.9.1.1.jar:0.9.1.1]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [?:1.8.0_212]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [?:1.8.0_212]
	at java.lang.Thread.run(Thread.java:748) [?:1.8.0_212]
```

- 错误二

```java
com.metamx.common.ISE: Exception occurred during persist and merge.
	at io.druid.segment.realtime.plumber.RealtimePlumber.finishJob(RealtimePlumber.java:671) ~[druid-server-0.9.1.1.jar:0.9.1.1]
	at io.druid.indexing.common.task.RealtimeIndexTask.run(RealtimeIndexTask.java:405) [druid-indexing-service-0.9.1.1.jar:0.9.1.1]
	at io.druid.indexing.overlord.ThreadPoolTaskRunner$ThreadPoolTaskRunnerCallable.call(ThreadPoolTaskRunner.java:436) [druid-indexing-service-0.9.1.1.jar:0.9.1.1]
	at io.druid.indexing.overlord.ThreadPoolTaskRunner$ThreadPoolTaskRunnerCallable.call(ThreadPoolTaskRunner.java:408) [druid-indexing-service-0.9.1.1.jar:0.9.1.1]
	at java.util.concurrent.FutureTask.run(FutureTask.java:266) [?:1.8.0_212]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [?:1.8.0_212]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [?:1.8.0_212]
	at java.lang.Thread.run(Thread.java:748) [?:1.8.0_212]
```

### 解决方案

---

通过以上错误我们推算出导致任务失败的核心原因是因为数据量过大,无法是数据做最终的合并操作,导致任务执行失败!

我们可以尝试数据摄取进行优化,大概优化过程如下:

修改`tuningConfig`部分为以下配置信息

```java
{
    "tuningConfig": {
        "windowPeriod": "PT10M",
        "type": "realtime",
        "maxRowsPerSegment": "50000000",
        "intermediatePersistPeriod": "PT10m",
        "maxRowsInMemory": "1000000"
    }
}
```

**tuningConfig.windowPeriod**: 数据流摄取时间窗口
**tuningConfig.type**: 设置为realtime即为数据流摄取
**tuningConfig.maxRowsInMemory**: 在存盘之前内存中最大的存储行数，指的是聚合后的行数
**tuningConfig.maxRowsPerSegment**: 每个segment最大的存储行数
**tuningConfig.reportParseExceptions**: 是否汇报数据解析错误