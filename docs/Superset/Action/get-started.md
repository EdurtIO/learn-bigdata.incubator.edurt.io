---
layout: default
title: Superset安装部署
nav_order: 2
parent: Action(实战)
grand_parent: Superset
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

Superset 是一款由 Airbnb 开源的“现代化的企业级 BI（商业智能） Web 应用程序”，其通过创建和分享 dashboard，为数据分析提供了轻量级的数据查询和可视化方案。Superset 的前端主要用到了 React 和 NVD3/D3，而后端则基于 Python 的 Flask 框架和 Pandas、SQLAlchemy 等依赖库，主要提供了这几方面的功能：

- 集成数据查询功能，支持多种数据库，包括 MySQL、PostgresSQL、Oracle、SQL Server、SQLite、SparkSQL 等，并深度支持 Druid。
- 通过 NVD3/D3 预定义了多种可视化图表，满足大部分的数据展示功能。如果还有其他需求，也可以自开发更多的图表类型，或者嵌入其他的 JavaScript 图表库（如 HighCharts、ECharts）。
- 提供细粒度安全模型，可以在功能层面和数据层面进行访问控制。支持多种鉴权方式（如数据库、OpenID、LDAP、OAuth、REMOTE_USER 等）。

### 安装基础依赖

---

- 系统环境

|环境|版本|
|---|---|
|Superset|0.18.4|
|Python|2.7|
|OS|CentOS7|

- 更新 python-setuptools

```bash
sudo yum upgrade python-setuptools
```

- 安装cryptography以及依赖

```java
sudo yum install gcc gcc-c++ libffi-devel python-devel python-pip python-wheel openssl-devel libsasl2-devel openldap-devel
```

- 安装pip

```bash
wget "https://pypi.python.org/packages/source/p/pip/pip-1.5.4.tar.gz#md5=834b2904f92d46aaa333267fb1c922bb" --no-check-certificate
tar -xzvf pip-1.5.4.tar.gz
cd pip-1.5.4
python setup.py install
```

### 安装Python虚拟环境

---

- 安装virtualenv

```bash
pip install virtualenv
```

- 创建Python虚拟环境

```bash
virtualenv venv
 
启动虚拟环境: source venv/bin/activate
退出虚拟环境: deactivate
```

### 安装superset

---

> 注意：以下步骤需在python虚拟环境操作

- 更新pip和setuptools

```bash
pip install --upgrade setuptools pip
```

- 安装superset

```bash
pip install superset
```

> 如果安装过程很慢,可以使用清华镜像

> pip install -i https://pypi.tuna.tsinghua.edu.cn/simple superset==<VERSION>

### 配置superset

---

- 创建管理用户(需要先设置用户名在设置用户密码)

```bash
fabmanager create-admin --app superset
```

- 更新数据库

```bash
superset db upgrade
```

- 加载演示数据[可选]

```bash
superset load_examples
```

- 初始化superset

```bash
superset init
```

- 启动superset服务(默认端口8080, 或使用-p参数指定端口)

```bash
superset runserver
```

> 如果您是开发者请使用以下方式启动服务

```bash
superset runserver -d
```

> 卸载之前的安装

```bash
pip uninstall superset
```