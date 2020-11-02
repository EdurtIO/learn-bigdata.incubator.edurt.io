---
layout: default
title: The number of hits for the query (39771) exceeds the configured max hits (1000)
nav_order: 5
has_children: false
parent: Mistakes(问题)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 错误信息

---

使用presto接入es数据源后查询数据出现以错误:

```java
2020-04-29T17:30:54.150+0800	ERROR	remote-task-callback-8	com.facebook.presto.execution.StageExecutionStateMachine	Stage execution 20200429_093051_00000_v3ng9.2.0 failed
com.facebook.presto.spi.PrestoException: The number of hits for the query (39771) exceeds the configured max hits (1000)
	at com.facebook.presto.elasticsearch.ElasticsearchRecordCursor.sendElasticsearchQuery(ElasticsearchRecordCursor.java:224)
	at com.facebook.presto.elasticsearch.ElasticsearchRecordCursor.<init>(ElasticsearchRecordCursor.java:86)
	at com.facebook.presto.elasticsearch.ElasticsearchRecordSet.cursor(ElasticsearchRecordSet.java:52)
	at com.facebook.presto.spi.RecordPageSource.<init>(RecordPageSource.java:38)
	at com.facebook.presto.split.RecordPageSourceProvider.createPageSource(RecordPageSourceProvider.java:48)
	at com.facebook.presto.spi.connector.ConnectorPageSourceProvider.createPageSource(ConnectorPageSourceProvider.java:52)
	at com.facebook.presto.split.PageSourceManager.createPageSource(PageSourceManager.java:58)
	at com.facebook.presto.operator.ScanFilterAndProjectOperator.getOutput(ScanFilterAndProjectOperator.java:227)
	at com.facebook.presto.operator.Driver.processInternal(Driver.java:381)
	at com.facebook.presto.operator.Driver.lambda$processFor$8(Driver.java:283)
	at com.facebook.presto.operator.Driver.tryWithLock(Driver.java:677)
	at com.facebook.presto.operator.Driver.processFor(Driver.java:276)
	at com.facebook.presto.execution.SqlTaskExecution$DriverSplitRunner.processFor(SqlTaskExecution.java:1077)
	at com.facebook.presto.execution.executor.PrioritizedSplitRunner.process(PrioritizedSplitRunner.java:162)
	at com.facebook.presto.execution.executor.TaskExecutor$TaskRunner.run(TaskExecutor.java:545)
	at com.facebook.presto.$gen.Presto_0_234_SNAPSHOT_a260a6c____20200429_093033_1.run(Unknown Source)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
```

### 解决方案

---

通过以上错误日志我们分析可以得到错误是因为查询的数据过多而我们只限制了1000的数据量导致的,这时我们去源码中看了以下发现一个很有意思的配置属性那就是`elasticsearch.max-hits`

官方对这个属性的解释是单个Elasticsearch请求可以获取的最大匹配数

错误日志显示的是我们拉下来的数据是39771,而我们的限制是1000(也就是官方默认的限制数量)

知道了问题存在位置,我们解决起来简单多了,只需要修改`etc/catalog/elasticsearch.properties`配置文件,在文件中添加`elasticsearch.max-hits`属性重启服务即可