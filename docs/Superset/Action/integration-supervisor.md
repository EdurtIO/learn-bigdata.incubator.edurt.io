---
layout: default
title: 集成Supervisor
nav_order: 6
parent: Action(实战)
grand_parent: Superset
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 安装Supervisor环境

---

```bash
pip install supervisor -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 配置Supervisor

---

- 创建supervisor配置文件

```bash
vim /hadoop/dc/superset.conf
```

在文件中写入以下内容:

```python
[program:superset]
command=bash -c 'source "/hadoop/dc/venv/bin/activate" && superset runserver'
user=root                   ; setuid to this UNIX account to run the program
redirect_stderr=true          ; redirect proc stderr to stdout (default false)
stdout_logfile=/home/tianhengrd/website_control/logs/superset/supervisord.log
autostart=false
autorestart=true
redirect_stderr=true
stopsignal=KILL
killasgroup=true
stopasgroup=true
```

- 启动superset服务

```bash
/usr/bin/supervisorctl -c /hadoop/dc/superset.conf
```