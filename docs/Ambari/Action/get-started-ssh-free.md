---
layout: default
title: 配置集群SSH免密登录
nav_order: 2
parent: Action(实战)
grand_parent: Ambari
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}


### 基本环境信息

---

|主机名|IP|版本|
|:---:|---|---|
|ambari-common|10.10.0.201|CentOS 7|
|ambari-server|10.10.0.202|CentOS 7|
|ambari-agent-001|10.10.0.203|CentOS 7|
|ambari-agent-002|10.10.0.204|CentOS 7|
|ambari-agent-003|10.10.0.205|CentOS 7|

### 设置机器节点信息

---

- 修改主机名(登录到集群中的所有节点进行操作)

```java
echo 'ambari-common' > /etc/hostname
```

- 设置主机列表到系统环境(登录到集群中的所有节点进行操作)

```java
vim /etc/hosts
```

在文件中末尾追加以下内容：

```java
# ambari cluster hosts
10.10.0.201 ambari-common
10.10.0.202 ambari-server
10.10.0.203 ambari-agent-001
10.10.0.204 ambari-agent-002
10.10.0.205 ambari-agent-003
```

### 设置集群相关用户

---

> 注意：切勿使用hadoop，hdfs等这些集群特有的用户

- 创建bigdata用户(登录到集群中的所有节点进行操作)

```java
useradd bigdata
```

- 授权bigdata用户sudo权限和无密码(登录到集群中的所有节点进行操作)

```java
visudo
```

在文件的第99行或者`root    ALL=(ALL)       ALL`内容后新启一行添加以下内容

```java
root ALL=(ALL) NOPASSWD:ALL
```

- 测试bigdata用户(在对应的单节点上执行即可)

```java
su bigdata -
```

### 构建登录节点的SSH密钥

---

- 生成SSH密钥键值对(切换到bigdata用户)

```java
ssh-keygen
```

当反馈出现以下信息时

```java
Generating public/private rsa key pair.
Enter file in which to save the key (/home/bigdata/.ssh/id_rsa):
```

这里需要我们指定保存的文件，默认是`/home/bigdata/.ssh/id_rsa`，如果不特殊指定的话，直接回车即可

```java
Enter passphrase (empty for no passphrase):
```

这里可以输入密钥文件的密码，我们也是默认直接回车

```java
Enter same passphrase again:
```

这里需要重复输入上一步设置的密码，保证两次密码一致即可，再次回车此时会生成类似以下的反馈信息

```java
Your identification has been saved in /home/bigdata/.ssh/id_rsa.
Your public key has been saved in /home/bigdata/.ssh/id_rsa.
The key fingerprint is:
8b:8b:69:66:b4:3b:9a:6a:24:f0:60:dc:53:b8:43:2c bigdata@ambari-common
The key's randomart image is:
+--[ RSA 2048]----+
|  . .            |
| E + .           |
|. + o            |
|oo =             |
|oo  o   S        |
|... .  . .       |
|o  . .. .        |
| . .*o .         |
|o.o=+o.          |
+-----------------+
```

提示以上信息标志生成密钥成功

- 配置`authorized_keys`设置免密登录

我们需要将刚刚生成的密钥的`~/.ssh/id_rsa.pub`的内容追加到该文件中

```java
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

使用`cat ~/.ssh/authorized_keys`确保一下文件内容是否录入

- 授权`~/.ssh`和`authorized_keys`权限

```java
chmod 700 ~/.ssh/
chmod 600 ~/.ssh/authorized_keys
```

将`~/.ssh`远程拷贝复制到所有的节点

```java
sudo scp -r /home/bigdata/.ssh/ root@ambari-server:/home/bigdata/
sudo scp -r /home/bigdata/.ssh/ root@ambari-agent-001:/home/bigdata/
sudo scp -r /home/bigdata/.ssh/ root@ambari-agent-002:/home/bigdata/
sudo scp -r /home/bigdata/.ssh/ root@ambari-agent-003:/home/bigdata/
```

> 注意：此处要输入root账号的密码

### 校验SSH免密登录配置

---

- 登录到集群中的某节点中(我们使用ambari-server为例)

```java
ssh root@ambari-server
```

- 修改SSH密钥相关权限(每台节点执行)

```java
chown -R bigdata:bigdata /home/bigdata/.ssh/
```

- 测试免密登录(在ambari-common节点上执行)

```java
ssh ambari-server
```

此时不需要任何密码即可进行登录系统，注意会出现类似以下的回馈

```java
Are you sure want to continue conneting (yes/no)?
```

此处输入`yes`即可，默认第一次登录会出现该提示