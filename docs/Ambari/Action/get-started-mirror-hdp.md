---
layout: default
title: 6:构建HDP私有源
nav_order: 7
parent: Action(实战)
grand_parent: Ambari
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

我们本篇文章主要讲述如何去同步远程服务器中的HDP数据源到本地，并将其作为局域网yum安装源。

### 基本环境信息

---

> 由于是通过HDP数据源安装HDP组件，我们只需要在一台机器上运行即可，我们这里部署到了和ambari-common(该节点压力较小)节点在一起。不过在实际的线上环境我们推荐将其分开部署。

|主机名|IP|版本|
|:---:|---|---|
|ambari-common|10.10.0.201|CentOS 7|

### HDP数据源配置

---

- 登录到`ambari-common`节点中

```
ssh ambari-common -p 22
```

> ambari-common需要在本地`/etc/hosts`文件中配置相应服务器映射，否则无法直接使用登录操作

- 下载hortonworks官方提供的HDP仓库源

在下载前我们需要检验是否安装`wget`命令行，如果没有安装此命令，使用以下命令安装它

```
sudo yum install wget
```

使用以下命令下载hortonworks官方提供的HDP仓库源

```
wget -nv http://public-repo-1.hortonworks.com/HDP/centos7/2.x/updates/2.4.2.0/hdp.repo -O /etc/yum.repos.d/hdp.repo
```

`-O`指定的是我们下载文件到的本地路径，注意这里是大写的O不是0

hdp的官方源的格式为`hdp/<OsVersion>/<HDPVersionRegex>/updates/<HDPVersion>/hdp.repo`

如果我们需要安装其他系统的或者其他版本的源只需要修改`<OsVersion>`和`<HDPVersionRegex>`(hdp大版本),`<HDPVersion>`(hdp绝对版本)

> 需要注意的是`/etc/yum.repos.d/hdp.repo`路径尽量不要修改，这样方便我们记住hdp的源所在系统的位置。

- 安装源配置文件下载完成后需要进行源的校验

```
sudo yum repolist
```

返回类似如下响应

```
HDP-2.4.2.0
HDP-UTILS-1.1.0.20
源标识
HDP-2.4.2.0
HDP-UTILS-1.1.0.20
```

这标志着我们的hdp安装源配置文件是可用的。

### HDP数据源同步

---

- 创建本地需要存放安装包文件路径

```
sudo mkdir -p /var/www/html/hdp/centos7/
```

`-p`命令标志我们需要进行递归创建文件夹

我们建议您的命名格式和我们类似`<源名称>/<系统版本>`

- 进入刚刚创建的目录中

```
cd /var/www/html/hdp/centos7/
```

当然我们也可以使用`&&`组合命令模式

- 开始同步远程服务资源到本地

```
reposync -r HDP-2.4.2.0
```

`-r`是告诉系统要进行递归同步

`HDP-2.4.2.0`指的是我们刚刚使用源检测命令返回的源标识

此时会去hortonworks官网进行同步，同步的速度具体是根据主机的网络而定。

或者可以使用后台同步方式：

```
nohup reposync -r HDP-2.4.2.0 >> sync-hdp.log &
```

或者可以使用screen命令进行窗口session模式同步。文件总大小大约在`5-6GB`。

### HDP-UTILS数据源同步

---

- 创建本地需要存放安装包文件路径

```
sudo mkdir -p /var/www/html/hdp-utils/centos7/
```

`-p`命令标志我们需要进行递归创建文件夹

我们建议您的命名格式和我们类似`<源名称>/<系统版本>`

- 进入刚刚创建的目录中

```
cd /var/www/html/hdp-utils/centos7/
```

当然我们也可以使用`&&`组合命令模式

- 开始同步远程服务资源到本地

```
reposync -r HDP-UTILS-1.1.0.20
```

`-r`是告诉系统要进行递归同步

`HDP-UTILS-1.1.0.20`指的是我们刚刚使用源检测命令返回的源标识

此时会去hortonworks官网进行同步，同步的速度具体是根据主机的网络而定。

或者可以使用后台同步方式：

```
nohup reposync -r HDP-UTILS-1.1.0.20 >> sync-hdp-utils.log &
```

或者可以使用screen命令进行窗口session模式同步。文件总大小大约在`500MB-2GB`。

> 如果出现`Error: /var/run/yum.pid 已被锁定，PID为 <XXXX> 的另一个程序正在运行。`的信息，我们可以忽略，这是因为系统只允许yum单线程运行。等待上一个yum同步完成后进行再次同步。

### 构建内网HDP源

---

- 生成本地资源库

```
createrepo /var/www/html/hdp/centos7/HDP-2.4.2.0
```

会出现类似如下反馈信息

```
Spawning worker xxx with xxx pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite Dbs complete
```

出现以上提示信息时，标志着我们的本地针对于hdp的库信息已经构建完成。

- 启动提供mirror源的http服务

```
service httpd start
```

当然也可以使用以下命令启动服务

```
/bin/systemctl start httpd.service
```

- 校验源是否可以使用http服务对外开放

浏览器打开`http://ambari-common/hdp/centos7/HDP-2.4.2.0`

> HDP-UTILS本地私有源制作，重复此步骤修改为HDP-UTILS路径即可。

这里我们是不需要添加端口信息的，因为http服务的默认端口就是80，浏览器打开后会出现一个文件浏览器，会显示一些文件以及目录列表，当然也可以使用nginx去做mirror源。