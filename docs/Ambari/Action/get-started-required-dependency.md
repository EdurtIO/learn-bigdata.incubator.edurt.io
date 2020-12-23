---
layout: default
title: 配置集群环境必备依赖
nav_order: 4
parent: Action(实战)
grand_parent: Ambari
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

我们本篇文章主要讲述在安装Ambari服务前需要安装的各种第三方支撑的系统依赖。

### 安装配置NTP服务

---

因为在集群中我们要保证时间的一致性特使用NTP来作为时间的同步服务，此操作登录到所有节点执行

- 安装ntp

```shell
yum -y install ntp
```

当然我们也可以使用源码方式进行ntp服务的安装

- 设置开机启动

```shell
sudo systemctl enable ntpd
```

- 启动服务

```shell
sudo systemctl start ntpd
```

### 关闭服务器的防火墙服务

---

> 由于防火墙的限制可能会导致集群中的某些端口无法访问，未解决该问题我们将防火墙做关闭处理，此操作登录到所有节点执行

- 禁止防火墙重启

```shell
sudo systemctl disable firewalld
```

这样可以使我们重启服务器的时候防火墙服务不在跟随系统启动，但是未重启的服务器防火墙服务依然存在

- 关闭防火墙

```shell
sudo systemctl stop firewalld
```

### 设置selinux

---

> 为了防止集群中的节点通信，我们要将selinx禁止，此操作登录到所有节点执行

- 检查selinux状态

```shell
/usr/sbin/sestatus -v
```

我们只需要查看`SELinux status:`是否是disabled即可。`disabled`标志被禁止，`enable`标志服务启动

如果是`enable`状态的话我们需要将它关闭掉

- 关闭selinux

```shell
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
```

或者我们使用Vim进行文件编辑

```shell
vim /etc/selinux/config
```

将文件中的`SELINUX=enforcing`修改为`SELINUX=disable`

修改后重启服务器即可

### 设置umask

---

> 此操作登录到所有节点执行，该操作尽量使用root用户操作

- 设置umask值为0022

```shell
echo umask 0022 >> /etc/profile
```

- 重载umask配置

```shell
source /etc/profile
```

或者直接使用组合命令执行

```shell
echo umask 0022 >> /etc/profile && source /etc/profile
```

### 安装yum源相关依赖

---

> 此操作只需要在ambari-common节点中执行，该操作尽量使用root用户操作

- 安装依赖

```shell
sudo yum install yum-utils createrepo httpd yum-plugin-priorities
```

- 设置pluginconf(使用root用户，在ambari-common节点操作)

```shell
echo 'gpgcheck=0' >> /etc/yum/pluginconf.d/priorities.conf
```

或者我们使用Vim修改`/etc/yum/pluginconf.d/priorities.conf`文件，在文件末尾新启一行添加以下内容

```shell
gpgcheck=0
```

此时我们所有的集群依赖环境已经安装完成。