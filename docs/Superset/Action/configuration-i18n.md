---
layout: default
title: 支持国际化配置
nav_order: 4
parent: Action(实战)
grand_parent: Superset
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

superset安装完成后在15版本前都是未做国际话的,需要手动配置,此文便是配置过程!

### 初始化国际化源码

---

- 下载superset汉化包(通过以下网址需要下载自己需要的国际化文件)

```bash
https://github.com/apache/incubator-superset/tree/master/superset/translations
```

- 复制国际化文件到superset目录

```bash
cp -r <汉化文件夹目录> /root/superset/venv/lib/python2.7/site-packages/superset
```

### 配置国际化

---

- 修改配置文件增加国际化配置

```bash
vim /root/superset/venv/bin/superset_config.py
```

在文件中加入以下内容:

```bash
BABEL_DEFAULT_LOCALE='zh'
LANGUAGES = {
    'zh': {'flag': 'cn', 'name': 'Chinese'},
    'en': {'flag': 'us', 'name': 'English'}
}
```

- 重新编译国际化文件使其配置生效

```bash
pybabel compile -d translations
```

> 编译后重启服务即可看到国际化后的superset,选择相应的语言即可