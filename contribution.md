---
layout: default
title: 如何贡献？
nav_order: 1
description: "本文告知我们如何去贡献本仓库源码"
permalink: /contribution
---

{: .no_toc }

注意
{: .label .label-red }

当您贡献审核通过后，程序会自动将您贡献的信息展示到站点首页(包含但不限于获取您在GitHub上的公开用户名称)

- 首先我们先要将我们的源码克隆到本地


```bash
git clone https://github.com/EdurtIO/learn-bigdata.incubator.edurt.io.git
```

- 创建我们的数据分支,例如我们要创建相关`spark`的资料

```bash
git checkout feature
git checkout -b feature-spark
mkdir docs/Spark
```

- 创建相关的资料文件夹(以`Action`为例)

```bash
mkdir docs/Spark/Action
```

- 在该文件夹中创建相关资料markdown文件,格式为

```bash
---
layout: default
title: Spark
nav_order: 2
has_children: true
permalink: docs/Spark
---

# Presto
{: .no_toc }

```


> nav_order一定要，这是我们的排序规则，如果有子目录请参照其他已经完成的分支进行书写

提示
{: .label .label-blue }

书写完成后直接push到仓库中,然后提交一个`Pull Requests`合并到`preview`分支等待审核通过后会发布到`https://learn-bigdata.incubator.edurt.io`网站
