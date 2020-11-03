---
layout: default
title: Could not initialize class Netty4Plugin
nav_order: 4
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

配置Presto支持elasticsearch数据源后,启动服务出现以下错误

```java
Error in custom provider, java.lang.NoClassDefFoundError: Could not initialize class org.elasticsearch.transport.Netty4Plugin
  at com.facebook.presto.elasticsearch.ElasticsearchConnectorModule.createElasticsearchClient(ElasticsearchConnectorModule.java:62)
  while locating com.facebook.presto.elasticsearch.ElasticsearchClient
    for the 1st parameter of com.facebook.presto.elasticsearch.ElasticsearchSplitManager.<init>(ElasticsearchSplitManager.java:42)
  at com.facebook.presto.elasticsearch.ElasticsearchConnectorModule.configure(ElasticsearchConnectorModule.java:46)
  while locating com.facebook.presto.elasticsearch.ElasticsearchSplitManager
Caused by: java.lang.NoClassDefFoundError (same stack trace as error #3)
4 errors
	at com.google.inject.internal.Errors.throwCreationExceptionIfErrorsExist(Errors.java:543)
	at com.google.inject.internal.InternalInjectorCreator.injectDynamically(InternalInjectorCreator.java:186)
	at com.google.inject.internal.InternalInjectorCreator.build(InternalInjectorCreator.java:109)
	at com.google.inject.Guice.createInjector(Guice.java:87)
	at com.facebook.airlift.bootstrap.Bootstrap.initialize(Bootstrap.java:245)
	at com.facebook.presto.elasticsearch.ElasticsearchConnectorFactory.create(ElasticsearchConnectorFactory.java:67)
	... 10 more
```

### 解决方案

---

通过日志我们发现启动服务的时候出现了错误,该错误是因为无法初始化类导致的运行时异常,由于是我们增加了elasticsearch数据源才导致无法启动服务,这时候我们可以直接定位到是因为我们elasticsearch插件导致的错误

- 进入到elasticsearch插件目录中

```bash
cd plugin/presto-elasticsearch/
```

- 检查是否包含netty依赖包

```bash
ll |grep netty-
```

我们发现返回的数据是空,此时可以断定出来是因为缺少netty包导致的,我们只需要下载netty的依赖到插件目录下即可

```bash
wget https://repo1.maven.org/maven2/io/netty/netty-all/4.1.49.Final/netty-all-4.1.49.Final.jar
```

当然不实用netty-all包的话,也可以使用netty的各个组件包,列表如下:

```java
netty-buffer-4.1.13.Final.jar
netty-codec-4.1.13.Final.jar
netty-codec-http-4.1.13.Final.jar
netty-common-4.1.13.Final.jar
netty-handler-4.1.13.Final.jar
netty-resolver-4.1.13.Final.jar
netty-transport-4.1.13.Final.jar
```

依赖下载完成后重启服务即可