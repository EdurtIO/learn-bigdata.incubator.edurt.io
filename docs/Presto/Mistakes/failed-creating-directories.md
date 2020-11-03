---
layout: default
title: Failed creating directories无法创建相关文件夹
nav_order: 2
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

具体的错误内容如下:

```java
Error notifying ProvisionListener com.facebook.airlift.bootstrap.LifeCycleModule$$Lambda$2532/1425928133 of com.facebook.presto.raptor.filesystem.LocalFileStorageService.
 Reason: com.facebook.airlift.bootstrap.LifeCycleStartException: Exception in PostConstruct method com.facebook.presto.raptor.filesystem.LocalFileStorageService::start()
  while locating com.facebook.presto.raptor.filesystem.LocalFileStorageService
  at com.facebook.presto.raptor.filesystem.LocalFileSystemModule.configure(LocalFileSystemModule.java:28) (via modules: com.facebook.presto.raptor.filesystem.FileSystemModule -> com.facebook.presto.raptor.filesystem.LocalFileSystemModule)
  while locating com.facebook.presto.raptor.storage.StorageService
    for the 2nd parameter of com.facebook.presto.raptor.storage.OrcStorageManager.<init>(OrcStorageManager.java:187)
  while locating com.facebook.presto.raptor.storage.OrcStorageManager
  at com.facebook.presto.raptor.storage.StorageModule.configure(StorageModule.java:84)
  while locating com.facebook.presto.raptor.storage.StorageManager
    for the 1st parameter of com.facebook.presto.raptor.RaptorPageSourceProvider.<init>(RaptorPageSourceProvider.java:51)
  at com.facebook.presto.raptor.RaptorModule.configure(RaptorModule.java:56)
  while locating com.facebook.presto.raptor.RaptorPageSourceProvider
    for the 5th parameter of com.facebook.presto.raptor.RaptorConnector.<init>(RaptorConnector.java:99)
  at com.facebook.presto.raptor.RaptorModule.configure(RaptorModule.java:54)
  while locating com.facebook.presto.raptor.RaptorConnector
Caused by: com.facebook.airlift.bootstrap.LifeCycleStartException: Exception in PostConstruct method com.facebook.presto.raptor.filesystem.LocalFileStorageService::start()
	at com.facebook.airlift.bootstrap.LifeCycleManager.startInstance(LifeCycleManager.java:245)
	at com.facebook.airlift.bootstrap.LifeCycleManager.addInstance(LifeCycleManager.java:211)
	at com.facebook.airlift.bootstrap.LifeCycleModule.provision(LifeCycleModule.java:62)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:120)
	at com.google.inject.internal.ProvisionListenerStackCallback.provision(ProvisionListenerStackCallback.java:66)
	at com.google.inject.internal.ConstructorInjector.construct(ConstructorInjector.java:93)
	at com.google.inject.internal.ConstructorBindingImpl$Factory.get(ConstructorBindingImpl.java:306)
	at com.google.inject.internal.FactoryProxy.get(FactoryProxy.java:62)
	at com.google.inject.internal.ProviderToInternalFactoryAdapter.get(ProviderToInternalFactoryAdapter.java:40)
	at com.google.inject.internal.SingletonScope$1.get(SingletonScope.java:168)
	at com.google.inject.internal.InternalFactoryToProviderAdapter.get(InternalFactoryToProviderAdapter.java:39)
	at com.google.inject.internal.SingleParameterInjector.inject(SingleParameterInjector.java:42)
	at com.google.inject.internal.SingleParameterInjector.getAll(SingleParameterInjector.java:65)
	at com.google.inject.internal.ConstructorInjector.provision(ConstructorInjector.java:113)
	at com.google.inject.internal.ConstructorInjector.access$000(ConstructorInjector.java:32)
	at com.google.inject.internal.ConstructorInjector$1.call(ConstructorInjector.java:98)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:112)
	at com.facebook.airlift.bootstrap.LifeCycleModule.provision(LifeCycleModule.java:54)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:120)
	at com.google.inject.internal.ProvisionListenerStackCallback.provision(ProvisionListenerStackCallback.java:66)
	at com.google.inject.internal.ConstructorInjector.construct(ConstructorInjector.java:93)
	at com.google.inject.internal.ConstructorBindingImpl$Factory.get(ConstructorBindingImpl.java:306)
	at com.google.inject.internal.FactoryProxy.get(FactoryProxy.java:62)
	at com.google.inject.internal.ProviderToInternalFactoryAdapter.get(ProviderToInternalFactoryAdapter.java:40)
	at com.google.inject.internal.SingletonScope$1.get(SingletonScope.java:168)
	at com.google.inject.internal.InternalFactoryToProviderAdapter.get(InternalFactoryToProviderAdapter.java:39)
	at com.google.inject.internal.SingleParameterInjector.inject(SingleParameterInjector.java:42)
	at com.google.inject.internal.SingleParameterInjector.getAll(SingleParameterInjector.java:65)
	at com.google.inject.internal.ConstructorInjector.provision(ConstructorInjector.java:113)
	at com.google.inject.internal.ConstructorInjector.access$000(ConstructorInjector.java:32)
	at com.google.inject.internal.ConstructorInjector$1.call(ConstructorInjector.java:98)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:112)
	at com.facebook.airlift.bootstrap.LifeCycleModule.provision(LifeCycleModule.java:54)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:120)
	at com.google.inject.internal.ProvisionListenerStackCallback.provision(ProvisionListenerStackCallback.java:66)
	at com.google.inject.internal.ConstructorInjector.construct(ConstructorInjector.java:93)
	at com.google.inject.internal.ConstructorBindingImpl$Factory.get(ConstructorBindingImpl.java:306)
	at com.google.inject.internal.ProviderToInternalFactoryAdapter.get(ProviderToInternalFactoryAdapter.java:40)
	at com.google.inject.internal.SingletonScope$1.get(SingletonScope.java:168)
	at com.google.inject.internal.InternalFactoryToProviderAdapter.get(InternalFactoryToProviderAdapter.java:39)
	at com.google.inject.internal.SingleParameterInjector.inject(SingleParameterInjector.java:42)
	at com.google.inject.internal.SingleParameterInjector.getAll(SingleParameterInjector.java:65)
	at com.google.inject.internal.ConstructorInjector.provision(ConstructorInjector.java:113)
	at com.google.inject.internal.ConstructorInjector.access$000(ConstructorInjector.java:32)
	at com.google.inject.internal.ConstructorInjector$1.call(ConstructorInjector.java:98)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:112)
	at com.facebook.airlift.bootstrap.LifeCycleModule.provision(LifeCycleModule.java:54)
	at com.google.inject.internal.ProvisionListenerStackCallback$Provision.provision(ProvisionListenerStackCallback.java:120)
	at com.google.inject.internal.ProvisionListenerStackCallback.provision(ProvisionListenerStackCallback.java:66)
	at com.google.inject.internal.ConstructorInjector.construct(ConstructorInjector.java:93)
	at com.google.inject.internal.ConstructorBindingImpl$Factory.get(ConstructorBindingImpl.java:306)
	at com.google.inject.internal.ProviderToInternalFactoryAdapter.get(ProviderToInternalFactoryAdapter.java:40)
	at com.google.inject.internal.SingletonScope$1.get(SingletonScope.java:168)
	at com.google.inject.internal.InternalFactoryToProviderAdapter.get(InternalFactoryToProviderAdapter.java:39)
	at com.google.inject.internal.InternalInjectorCreator.loadEagerSingletons(InternalInjectorCreator.java:211)
	at com.google.inject.internal.InternalInjectorCreator.injectDynamically(InternalInjectorCreator.java:182)
	at com.google.inject.internal.InternalInjectorCreator.build(InternalInjectorCreator.java:109)
	at com.google.inject.Guice.createInjector(Guice.java:87)
	at com.facebook.airlift.bootstrap.Bootstrap.initialize(Bootstrap.java:245)
	at com.facebook.presto.raptor.RaptorConnectorFactory.create(RaptorConnectorFactory.java:101)
	at com.facebook.presto.connector.ConnectorManager.createConnector(ConnectorManager.java:364)
	at com.facebook.presto.connector.ConnectorManager.addCatalogConnector(ConnectorManager.java:222)
	at com.facebook.presto.connector.ConnectorManager.createConnection(ConnectorManager.java:214)
	at com.facebook.presto.connector.ConnectorManager.createConnection(ConnectorManager.java:200)
	at com.facebook.presto.metadata.StaticCatalogStore.loadCatalog(StaticCatalogStore.java:123)
	at com.facebook.presto.metadata.StaticCatalogStore.loadCatalog(StaticCatalogStore.java:98)
	at com.facebook.presto.metadata.StaticCatalogStore.loadCatalogs(StaticCatalogStore.java:80)
	at com.facebook.presto.metadata.StaticCatalogStore.loadCatalogs(StaticCatalogStore.java:68)
	at com.facebook.presto.server.PrestoServer.run(PrestoServer.java:135)
	at com.facebook.presto.server.PrestoServer.main(PrestoServer.java:77)
Caused by: com.facebook.presto.spi.PrestoException: Failed creating directories: /var/data/staging
	at com.facebook.presto.raptor.filesystem.LocalFileStorageService.createDirectory(LocalFileStorageService.java:220)
	at com.facebook.presto.raptor.filesystem.LocalFileStorageService.start(LocalFileStorageService.java:85)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at com.facebook.airlift.bootstrap.LifeCycleManager.startInstance(LifeCycleManager.java:240)
	... 69 more
```

### 解决方案

---

这个是因为我们没有权限在/var中自动创建相关文件夹,此时需要修改`presto-main/etc/catalog/raptor.properties`配置文件,将`storage.data-directory=`修改成可以进行存储的数据目录(目录需要提前创建好)