---
layout: default
title: 支持MySQL存储配置
nav_order: 3
parent: Action(实战)
grand_parent: Superset
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

> 注意: 配置MySQL存储后以前的非使用该存储介质的所有数据将会清除掉(除非做了数据恢复)

### 安装MySQL相关环境

---

- 安装mysql开发环境

```bash
yum install mysql-devel
```

- 安装mysql python依赖

```bash
pip install mysqlclient MySQL-python
```

> 如果出现冲突使用以下方式解决

```bash
yum clean all
yum repolist
yum -y install gcc gcc-c++ kernel-devel
yum -y install python-devel libxslt-devel libffi-devel openssl-devel
```

### 配置MySQL

---

- 修改superset对mysql配置文件(一定要放置到python的根目录)

```bash
vim /root/superset/venv/bin/superset_config.py
```

在文件中写入以下内容:

```bash
import sys # import sys package, if not already imported
reload(sys)
sys.setdefaultencoding('utf-8')
# Superset specific config
#---------------------------------------------------------
ROW_LIMIT = 200000
SUPERSET_WORKERS = 4
 
SUPERSET_WEBSERVER_PORT = 8099
#---------------------------------------------------------
 
#---------------------------------------------------------
# Flask App Builder configuration
#---------------------------------------------------------
# Your App secret key
SECRET_KEY = '\2\1t567fgj7dtghjdhfui64@#$&77cvw424tkey\1\2\e\y\y\h'
 
# The SQLAlchemy connection string to your database backend
# This connection defines the path to the database that stores your
# superset metadata (slices, connections, tables, dashboards, ...).
# Note that the connection information to connect to the datasources
# you want to explore are managed directly in the web UI
#SQLALCHEMY_DATABASE_URI = 'sqlite:////path/to/superset.db'
SQLALCHEMY_DATABASE_URI = 'mysql://root:123456@172.17.31.248:3306/superset'
 
# Flask-WTF flag for CSRF
CSRF_ENABLED = True
 
# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = ''
```

> 注意修改元数据存储后, 原有数据不会被迁移, 需要重新初始化数据

### 初始化数据

---

- 创建管理用户(需要先设置用户名在设置用户密码)

```bash
fabmanager create-admin --app superset
```

- 更新数据库

```bash
superset db upgrade
```