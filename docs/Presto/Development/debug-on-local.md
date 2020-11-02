---
layout: default
title: Presto源码调试
nav_order: 3
has_children: false
parent: Development(开发)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

本地调试我们推荐使用Idea进行源码的修改调试,这样可友好的进行每行源码的debug方便我们找出问题,我们尚未在eclipse中进行源码调试!

> 本文也是基于idea进行源码调试!

首先我们需要将源码进行编译一次,这样可以节省idea的加载时间,具体的编译步骤详见[源码编译步骤]({{ site.baseurl }}{% link docs/Presto/Development/get-started.md %})

### 必备条件

---

|环境|版本|
|---|---|
|System|Mac(Linux)**不推荐使用Windows**|
|Java|11+|
|Maven|3.6+|
|Python|2.4+|
|IDEA(Eclipse)|-|

### 导入项目

---

- 打开IDEA选择`Open`打开下载并编译后的Presto源码

![](/assets/images/presto/development/debug-on-local/open.png)

> 由于源码过多,加载会稍微慢些,请等候源码加载完成

- 开启Maven项目自动导入模式(下图)

![](/assets/images/presto/development/debug-on-local/auto-import.png)

点击`Enable Auto-Import`即可自动加载依赖并加载

- Maven项目识别后目录大概如下

![](/assets/images/presto/development/debug-on-local/toc.png)

### 配置项目

---

- 设置JDK

同时按住`command`+';'键弹出设置窗口

![](/assets/images/presto/development/debug-on-local/jdk.png)

选择我们的JDK(1.8版本),然后点击`OK`按钮

- 设置本地调试的类属性

找到`presto-main`模块下的`PrestoServer`类文件,全路径为`presto-main/src/main/java/com/facebook/presto/server/PrestoServer.java`

在该类文件上鼠标右键弹出一下窗口

![](/assets/images/presto/development/debug-on-local/configuration.png)

点击`Create 'PrestoServer.main()'...`按钮弹出以下配置输入框

![](/assets/images/presto/development/debug-on-local/configuration_done.png)

我们详细配置有三个地方

1. 标志我们要启动的应用别名,这个随便书写,只要自己记得即可
2. `VM options`这里是我们的核心配置,需要配置我们本地调试的虚拟机环境书写内容如下
    ```java
     -ea -XX:+UseG1GC -XX:G1HeapRegionSize=32M -XX:+UseGCOverheadLimit -XX:+ExplicitGCInvokesConcurrent -Xmx2G -Dconfig=etc/config.properties -Dlog.levels-file=etc/log.properties -Djdk.attach.allowAttachSelf=true
    ```
    这里都是一些我们对jvm信息的配置,值的注意的是`-Dconfig`和`-Dlog.levels-file`这两文件分别是系统的配置文件和日志文件,如果我们需要使用外部的文件,我们在这里指定文件的绝对路径即可,默认我们会检索项目etc目录下的配置文件
3. `Working directory`指向的是我们项目的执行目录设置为`$MODULE_DIR$`

以上3个步骤设置完成后,点击`OK`按钮进行配置保存

### 配置hive数据源

---

> 为了方便测试我们以hive数据源做调试

需要修改`presto-main/etc/catalog/hive.properties`配置文件或者修改`VM options`配置增加以下内容(2选1即可)

```java
-Dhive.metastore.uri=thrift://localhost:9083
```

配置完成后我们在`PrestoServer`类文件上鼠标右键点击`Run 'PrestoServer.main()'`即可启动服务,如果出现`Failed creating directories`错误,请参照[Failed creating directories无法创建相关文件夹]({{ site.baseurl }}{% link docs/Presto/Mistakes/failed-creating-directories.md %})

### 本地SQL调试

---

我们需要使用到`presto-cli`,执行以下命令

```java
<PrestoSourceCodeHome>/presto-cli/target/presto-cli-0.235-SNAPSHOT-executable.jar
```

进入客户端后,执行要执行的sql即可.