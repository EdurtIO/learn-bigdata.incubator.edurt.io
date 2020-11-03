---
layout: default
title: Configuration property 'elasticsearch.default-schema' was not used
nav_order: 3
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
1) Configuration property 'elasticsearch.default-schema' was not used
  at com.facebook.airlift.bootstrap.Bootstrap.lambda$initialize$2(Bootstrap.java:238)

1 error
	at com.google.inject.internal.Errors.throwCreationExceptionIfErrorsExist(Errors.java:543)
	at com.google.inject.internal.InternalInjectorCreator.initializeStatically(InternalInjectorCreator.java:159)
	at com.google.inject.internal.InternalInjectorCreator.build(InternalInjectorCreator.java:106)
	at com.google.inject.Guice.createInjector(Guice.java:87)
	at com.facebook.airlift.bootstrap.Bootstrap.initialize(Bootstrap.java:245)
	at com.facebook.presto.elasticsearch.ElasticsearchConnectorFactory.create(ElasticsearchConnectorFactory.java:67)
	... 10 more
```

### 解决方案

---

通过错误我们分析到这个是因为某个配置属性不存在导致服务启动失败,我们看了一下官方文档发现也是这样改配置的,但是这样导致了服务无法启动成功,看了源码后才发现已经将`elasticsearch.default-schema`属性修改成了`elasticsearch.default-schema-name`,但是官方文档没有仔细说明.

出现这个问题原因是presto拆分后分成了prestodb和prestosql两个版本,在prestosql的代码中进行了部分重构,而prestodb引用了中的部分特性进行了一些代码合并,导致文档没有更新!

知道了问题存在位置,我们解决起来简单多了,只需要修改`etc/catalog/elasticsearch.properties`配置文件中的`elasticsearch.default-schema`属性为`elasticsearch.default-schema-name`重启服务即可