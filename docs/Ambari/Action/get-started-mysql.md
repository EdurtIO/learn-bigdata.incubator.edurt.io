---
layout: default
title: 4:MySQL服务安装配置
nav_order: 5
parent: Action(实战)
grand_parent: Ambari
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

我们使用MySQL作为保存Ambari的元数据的底层存储。当然Ambari还支持其他的底层存储，这里我们就不做一一的解释和演示。

由于我们使用的是CentOS7系统，默认系统中并不安装MySQL服务，所以我们需要单独去安装该服务。并在CentOS7中也不再支持`yum install mysql`

### 基本环境信息

---

> 由于我们为了演示机器有限所以将MySQL服务部署到了和ambari-common(该节点压力较小)节点在一起。不过在实际的线上环境我们推荐将其分开部署。

|主机名|IP|版本|
|:---:|---|---|
|ambari-common|10.10.0.201|CentOS 7|

### 安装MySQL

---

- 安装MySQL官方源

```bash
sudo rpm -ivh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
```

此操作会将MySQL官方社区的yum源配置文件安装到我们的本地系统yum源中。

- 安装MySQL Server服务

```bash
sudo yum install mysql-server
```

在安装过程中会出现以下提示信息

```bash
Is this ok [y/d/N]
```

看到此提示后我们输入`y`进行继续安装。

> 注意：安装的进度根据当前网络的问题而定。

如果提示`警告：RPM数据库已被非yum程序修改。`或者英文的提示，此时可以忽略，这是因为我们安装第三方软件的时候，系统会做一些校验通知，并且这个操作会修改yum的一些配置文件信息。

在CentOS 7系统中安装MySQL服务完成后会提示`MySQL服务已经替代mariadb`，看到此提示信息我们也可以忽略。因为CentOS 7默认支持mariadb并不支持MySQL。

- 启动MySQL服务

```
service mysqld start
```

会得到以下反馈

```
Redirecting to /bin/systemctl start mysql.service
```

此时如果不出现任何错误，那么表明MySQL服务启动成功。

我们为了防止每次系统重启后需要手动启动MySQL服务，我们做以下配置设置MySQL服务为系统开机启动：

```
systemctl enable mysqld
```

此时不会有任何反馈。

- 连接MySQL服务做相关配置

默认MySQL安装完成后是没有任何密码的我们通过使用root用户可以直接登陆进去，但是这样是不安全的，我们不建议这么去做，建议设置一个密码用于管理MySQL权限。

使用以下命令登陆MySQL服务

```
mysql -uroot
```

我们会得到类似以下反馈

```
mysql>
```

这表明我们已经成功连接MySQL服务，此时我们可以做对MySQL服务的一些配置。

- 设置MySQL管理员密码

我们需要进入到MySQL的默认管理库中。

```
use mysql;
```

该表中存放了MySQL相关的一些元数据信息。我们需要修改的是`user`表内容。

执行以下操作进行修改MySQL root用户的初始密码

```
update user set password=password('AmbariMySQL@2020') where user = 'root';
```

需要注意的是：

- 第一个`password`指的是`user`表中的字段
- 第二个`password`指的是mysql系统的中密码加密函数

> ⚠️：我们update的时候务必要增加where条件，否则会出现MySQL默认用户库中用户密码统一问题，这是我们不应该看到的东西，请切记。

此时会反馈类似如下内容：

```
Query OK, 4 rows affected (0.00 sec)
Rows matched: 4 Changed：4 Warning：0
```

如果我们修改的时候`Warning`出现了大于0的时候标志这我们修改的时候出现了一些非致命的问题，当然你也可以忽略，也可以去进行修复它。

然后我们使用`exit`命令退出MySQL客户端。

- 校验用户设置密码的有效性

可选操作。重启MySQL服务`service mysqld restart`

如果运行时出现类似以下提示

```
The service command supports only basic LSB actions ...
```

此时我们修改命令为`systemctl restart mysql.service`即可

我们再次使用以下命令连接MySQL服务

```
mysql -uroot
```

运行命令后，我们会得到类似以下提示

```
ERROR 1045 (28000)：Access denied for user 'root'@'localhost' (using password: NO)
```

得到此反馈后，标志着我们必须要通过有效的密码去连接数据库，这也验证了我们设置了密码的过程是有效的。

此时我们通过以下方式连接MySQL服务

```
mysql -uroot -p'AmbariMySQL@2020'
```

回车后我们可以正常登录MySQL服务。

`-p` 标志我们要指定连接服务使用`-u`对应的用户密码

到此为止我们已经安装好了需要的MySQL服务。