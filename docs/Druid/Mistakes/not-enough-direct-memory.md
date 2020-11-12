---
layout: default
title: Not enough direct memory
nav_order: 2
parent: Mistakes(问题)
grand_parent: Druid
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 错误信息

---

再启动druid节点服务的时候出现以下错误:

```java
2019-10-08T03:41:50,703 ERROR [main] io.druid.cli.CliBroker - Error when starting up.  Failing.
com.google.inject.ProvisionException: Unable to provision, see the following errors:

1) Not enough direct memory.  Please adjust -XX:MaxDirectMemorySize, druid.processing.buffer.sizeBytes, druid.processing.numThreads, or druid.processing.numMergeBuffers: maxDirectMemory[34,359,738,368], memoryNeeded[40,802,189,293] = druid.processing.buffer.sizeBytes[2,147,483,647] * (druid.processing.numMergeBuffers[3] + druid.processing.numThreads[15] + 1)
  at io.druid.guice.DruidProcessingModule.getIntermediateResultsPool(DruidProcessingModule.java:110) (via modules: com.google.inject.util.Modules$OverrideModule -> com.google.inject.util.Modules$OverrideModule -> io.druid.guice.DruidProcessingModule)
  at io.druid.guice.DruidProcessingModule.getIntermediateResultsPool(DruidProcessingModule.java:110) (via modules: com.google.inject.util.Modules$OverrideModule -> com.google.inject.util.Modules$OverrideModule -> io.druid.guice.DruidProcessingModule)
  while locating io.druid.collections.NonBlockingPool<java.nio.ByteBuffer> annotated with @io.druid.guice.annotations.Global()
    for the 2nd parameter of io.druid.query.groupby.GroupByQueryEngine.<init>(GroupByQueryEngine.java:81)
  at io.druid.guice.QueryRunnerFactoryModule.configure(QueryRunnerFactoryModule.java:88) (via modules: com.google.inject.util.Modules$OverrideModule -> com.google.inject.util.Modules$OverrideModule -> io.druid.guice.QueryRunnerFactoryModule)
  while locating io.druid.query.groupby.GroupByQueryEngine
    for the 2nd parameter of io.druid.query.groupby.strategy.GroupByStrategyV1.<init>(GroupByStrategyV1.java:77)
  while locating io.druid.query.groupby.strategy.GroupByStrategyV1
    for the 2nd parameter of io.druid.query.groupby.strategy.GroupByStrategySelector.<init>(GroupByStrategySelector.java:43)
  while locating io.druid.query.groupby.strategy.GroupByStrategySelector
    for the 1st parameter of io.druid.query.groupby.GroupByQueryQueryToolChest.<init>(GroupByQueryQueryToolChest.java:105)
  at io.druid.guice.QueryToolChestModule.configure(QueryToolChestModule.java:101) (via modules: com.google.inject.util.Modules$OverrideModule -> com.google.inject.util.Modules$OverrideModule -> io.druid.guice.QueryRunnerFactoryModule)
  while locating io.druid.query.groupby.GroupByQueryQueryToolChest
  while locating io.druid.query.QueryToolChest annotated with @com.google.inject.multibindings.Element(setName=,uniqueId=80, type=MAPBINDER, keyType=java.lang.Class<? extends io.druid.query.Query>)
  at io.druid.guice.DruidBinders.queryToolChestBinder(DruidBinders.java:45) (via modules: com.google.inject.util.Modules$OverrideModule -> com.google.inject.util.Modules$OverrideModule -> io.druid.guice.QueryRunnerFactoryModule -> com.google.inject.multibindings.MapBinder$RealMapBinder)
  while locating java.util.Map<java.lang.Class<? extends io.druid.query.Query>, io.druid.query.QueryToolChest>
    for the 1st parameter of io.druid.query.MapQueryToolChestWarehouse.<init>(MapQueryToolChestWarehouse.java:36)
  while locating io.druid.query.MapQueryToolChestWarehouse
  while locating io.druid.query.QueryToolChestWarehouse
    for the 1st parameter of io.druid.server.QueryLifecycleFactory.<init>(QueryLifecycleFactory.java:52)
  at io.druid.server.QueryLifecycleFactory.class(QueryLifecycleFactory.java:52)
  while locating io.druid.server.QueryLifecycleFactory
    for the 1st parameter of io.druid.server.BrokerQueryResource.<init>(BrokerQueryResource.java:68)
  at io.druid.cli.CliBroker$1.configure(CliBroker.java:117) (via modules: com.google.inject.util.Modules$OverrideModule -> com.google.inject.util.Modules$OverrideModule -> io.druid.cli.CliBroker$1)
  while locating io.druid.server.BrokerQueryResource
```

### 解决方案

---

这个错误我们很容易解决,这个是因为内存资源不够造成的.出现此问题我们有两种解决方案,大概如下:

- 扩充服务总得内存资源

修改`conf/druid/<出现该错误的服务名>/jvm.config`配置文件,将`-XX:MaxDirectMemorySize=32g`配置修改为>=程序需要的大小

- 减少服务内部使用的内存资源

修改`conf/druid/<出现该错误的服务名>/runtime.properties`配置文件,修改以下配置参数:

```java
druid.processing.buffer.sizeBytes=2147483647
druid.processing.numThreads=15
```

将以上两个值配置小即可计算公式为

> -XX:MaxDirectMemorySize, druid.processing.buffer.sizeBytes, druid.processing.numThreads, or druid.processing.numMergeBuffers: maxDirectMemory[34,359,738,368], memoryNeeded[40,802,189,293] = druid.processing.buffer.sizeBytes[2,147,483,647] * (druid.processing.numMergeBuffers[3] + druid.processing.numThreads[15] + 1)

> 注意:根据具体的服务进行配置相关的内存资源.