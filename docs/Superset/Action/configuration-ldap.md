---
layout: default
title: 支持LDAP用户配置
nav_order: 5
parent: Action(实战)
grand_parent: Superset
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

在企业内部大部分都使用的是统一账号管理,比如LDAP,OpenLDAP等各种账号管理系统,当然superset也是支持的,本文我们主要讲解一下如何接入配置LDAP账号。

### 配置必要环境

---

- 安装开发环境

```bash
yum install openssl-devel libsasl2-devel openldap-devel
```

- 安装ldap python依赖

```bash
pip install pyldap -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 配置LDAP支持

---

- 修改superset对mysql配置文件(一定要放置到python的根目录)

```bash
vim /root/superset/venv/bin/superset_config.py
```

在文件中写入以下内容:

```python
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
 
 
# LDAP
import ldap
from flask_appbuilder.security.manager import AUTH_OID, AUTH_REMOTE_USER, AUTH_DB, AUTH_LDAP, AUTH_OAUTH, AUTH_OAUTH
 
AUTH_TYPE = AUTH_LDAP
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "User"
AUTH_LDAP_SERVER = "ldap://localhost:389"
AUTH_LDAP_SEARCH = "DC=example,DC=int"
AUTH_LDAP_BIND_USER = "cn=function,OU=Email Account,dc=example,dc=int"
AUTH_LDAP_BIND_PASSWORD = "example"
AUTH_LDAP_UID_FIELD = "sAMAccountName"
```

需要注意的就是一定要将LDAP的配置和此配置信息对应,否则会提示授权失败,账号无法通过认证!

> 注意修改配置文件后, 重新启动superset服务即可