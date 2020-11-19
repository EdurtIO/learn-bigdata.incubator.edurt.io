---
layout: default
title: ClickHouse安装部署
nav_order: 2
has_children: false
parent: Action(实战)
grand_parent: ClickHouse
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

### 基本配置环境

---

|依赖|版本|
|:---:|---|
|ClickHouse|20.11.3.3-2|
|CentOS|7.x|
|Gcc|4.8.5|

### 下载安装ClickHouse

---

- 离线安装方式(我们使用下载到本地进行安装)

```shell
wget https://repo.yandex.ru/clickhouse/rpm/stable/x86_64/clickhouse-client-20.11.3.3-2.noarch.rpm
wget https://repo.yandex.ru/clickhouse/rpm/stable/x86_64/clickhouse-common-static-20.11.3.3-2.x86_64.rpm
wget https://repo.yandex.ru/clickhouse/rpm/stable/x86_64/clickhouse-common-static-dbg-20.11.3.3-2.x86_64.rpm
wget https://repo.yandex.ru/clickhouse/rpm/stable/x86_64/clickhouse-server-20.11.3.3-2.noarch.rpm

yum install -y clickhouse-*
```

- yum源在线安装

```shell
sudo yum install yum-utils
sudo rpm --import https://repo.clickhouse.tech/CLICKHOUSE-KEY.GPG
sudo yum-config-manager --add-repo https://repo.clickhouse.tech/rpm/stable/x86_64

sudo yum install clickhouse-server clickhouse-client
```

> 如果您想使用最新版本，请将stable替换为testing（建议您在测试环境中使用）

### 配置ClickHouse

---

ClickHouse中的配置项很多，默认会在`/etc`下生成`clickhouse-server`和`clickhouse-client`两个目录，由于我们安装服务我们去修改`clickhouse-server`下的配置文件

- 修改`/etc/clickhouse-server/config.xml`

```xml
<?xml version="1.0"?>
<!--
       NOTE: User and query level settings are set up in "users.xml" file.
-->
<yandex>
    <logger>
        <!-- Possible levels: https://github.com/pocoproject/poco/blob/develop/Foundation/include/Poco/Logger.h#L105 -->
        <level>trace</level>
        <log>/data2/clickhouse/clickhouse-server.log</log>
        <errorlog>/data2/clickhouse/clickhouse-server.err.log</errorlog>
        <size>1000M</size>
        <count>10</count>
        <!-- <console>1</console> --> <!-- Default behavior is autodetection (log to console if not daemon mode and is tty) -->
    </logger>
    <!--display_name>production</display_name--> <!-- It is the name that will be shown in the client -->
    <http_port>9123</http_port>
    <tcp_port>9000</tcp_port>

    <!-- For HTTPS and SSL over native protocol. -->
    <!--
             <https_port>8443</https_port>
    <tcp_port_secure>9440</tcp_port_secure>
    -->

    <!-- Used with https_port and tcp_port_secure. Full ssl options list: https://github.com/ClickHouse-Extras/poco/blob/master/NetSSL_OpenSSL/include/Poco/Net/SSLManager.h#L71 -->
    <openSSL>
        <server> <!-- Used for https server AND secure tcp port -->
            <!-- openssl req -subj "/CN=localhost" -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/clickhouse-server/server.key -out /etc/clickhouse-server/server.crt -->
            <certificateFile>/etc/clickhouse-server/server.crt</certificateFile>
            <privateKeyFile>/etc/clickhouse-server/server.key</privateKeyFile>
            <!-- openssl dhparam -out /etc/clickhouse-server/dhparam.pem 4096 -->
            <dhParamsFile>/etc/clickhouse-server/dhparam.pem</dhParamsFile>
            <verificationMode>none</verificationMode>
            <loadDefaultCAFile>true</loadDefaultCAFile>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
        </server>

        <client> <!-- Used for connecting to https dictionary source -->
            <loadDefaultCAFile>true</loadDefaultCAFile>
            <cacheSessions>true</cacheSessions>
            <disableProtocols>sslv2,sslv3</disableProtocols>
            <preferServerCiphers>true</preferServerCiphers>
            <!-- Use for self-signed: <verificationMode>none</verificationMode> -->
            <invalidCertificateHandler>
                <!-- Use for self-signed: <name>AcceptCertificateHandler</name> -->
                <name>RejectCertificateHandler</name>
            </invalidCertificateHandler>
        </client>
    </openSSL>

    <!-- Default root page on http[s] server. For example load UI from https://tabix.io/ when opening http://localhost:8123 -->
    <!--
             <http_server_default_response><![CDATA[<html ng-app="SMI2"><head><base href="http://ui.tabix.io/"></head><body><div ui-view="" class="content-ui"></div><script src="http://loader.tabix.io/master.js"></script></body></html>]]></http_server_default_response>
    -->

    <!-- Port for communication between replicas. Used for data exchange. -->
    <interserver_http_port>9009</interserver_http_port>

    <listen_host>0.0.0.0</listen_host>
    <!-- Don't exit if ipv6 or ipv4 unavailable, but listen_host with this protocol specified -->
    <!-- <listen_try>0</listen_try> -->

    <!-- Allow listen on same address:port -->
    <!-- <listen_reuse_port>0</listen_reuse_port> -->

    <!-- <listen_backlog>64</listen_backlog> -->

    <max_connections>4096</max_connections>
    <keep_alive_timeout>3</keep_alive_timeout>

    <!-- Maximum number of concurrent queries. -->
    <max_concurrent_queries>100</max_concurrent_queries>

    <!-- Set limit on number of open files (default: maximum). This setting makes sense on Mac OS X because getrlimit() fails to retrieve
                  correct maximum value. -->
    <!-- <max_open_files>262144</max_open_files> -->

    <!-- Size of cache of uncompressed blocks of data, used in tables of MergeTree family.
                  In bytes. Cache is single for server. Memory is allocated only on demand.
         Cache is used when 'use_uncompressed_cache' user setting turned on (off by default).
         Uncompressed cache is advantageous only for very short queries and in rare cases.
      -->
    <uncompressed_cache_size>8589934592</uncompressed_cache_size>

    <!-- Approximate size of mark cache, used in tables of MergeTree family.
                  In bytes. Cache is single for server. Memory is allocated only on demand.
         You should not lower this value.
      -->
    <mark_cache_size>5368709120</mark_cache_size>


    <!-- Path to data directory, with trailing slash. -->
    <path>/data2/clickhouse/data/</path>

    <!-- Path to temporary data for processing hard queries. -->
    <tmp_path>/data2/clickhouse/tmp/</tmp_path>
    <!-- Directory with user provided files that are accessible by 'file' table function. -->
    <user_files_path>/data2/clickhouse/user_files/</user_files_path>

    <!-- Path to configuration file with users, access rights, profiles of settings, quotas. -->
    <users_config>users.xml</users_config>

    <!-- Default profile of settings. -->
    <default_profile>default</default_profile>

    <!-- System profile of settings. This settings are used by internal processes (Buffer storage, Distibuted DDL worker and so on). -->
    <!-- <system_profile>default</system_profile> -->

    <!-- Default database. -->
    <default_database>default</default_database>

    <mlock_executable>false</mlock_executable>

    <zookeeper incl="zookeeper-servers" optional="true" />

    <!-- Substitutions for parameters of replicated tables.
                   Optional. If you don't use replicated tables, you could omit that.

         See https://clickhouse.yandex/docs/en/table_engines/replication/#creating-replicated-tables
      -->
    <macros incl="macros" optional="true" />

    <!-- Reloading interval for embedded dictionaries, in seconds. Default: 3600. -->
    <builtin_dictionaries_reload_interval>3600</builtin_dictionaries_reload_interval>

    <!-- Maximum session timeout, in seconds. Default: 3600. -->
    <max_session_timeout>3600</max_session_timeout>

    <!-- Default session timeout, in seconds. Default: 60. -->
    <default_session_timeout>60</default_session_timeout>

    <!-- Query log. Used only for queries with setting log_queries = 1. -->
    <query_log>
        <!-- What table to insert data. If table is not exist, it will be created.
                          When query log structure is changed after system update,
              then old table will be renamed and new table will be created automatically.
        -->
        <database>system</database>
        <table>query_log</table>
        <!--
                         PARTITION BY expr https://clickhouse.yandex/docs/en/table_engines/custom_partitioning_key/
            Example:
                event_date
                toMonday(event_date)
                toYYYYMM(event_date)
                toStartOfHour(event_time)
        -->
        <partition_by>toYYYYMM(event_date)</partition_by>
        <!-- Interval of flushing data. -->
        <flush_interval_milliseconds>7500</flush_interval_milliseconds>
    </query_log>

    <!-- Trace log. Stores stack traces collected by query profilers.
                  See query_profiler_real_time_period_ns and query_profiler_cpu_time_period_ns settings. -->
    <trace_log>
        <database>system</database>
        <table>trace_log</table>

        <partition_by>toYYYYMM(event_date)</partition_by>
        <flush_interval_milliseconds>7500</flush_interval_milliseconds>
    </trace_log>

    <!-- Query thread log. Has information about all threads participated in query execution.
                  Used only for queries with setting log_query_threads = 1. -->
    <query_thread_log>
        <database>system</database>
        <table>query_thread_log</table>
        <partition_by>toYYYYMM(event_date)</partition_by>
        <flush_interval_milliseconds>7500</flush_interval_milliseconds>
    </query_thread_log>

    <dictionaries_config>*_dictionary.xml</dictionaries_config>

    <!-- Uncomment if you want data to be compressed 30-100% better.
                  Don't do that if you just started using ClickHouse.
      -->
    <compression incl="clickhouse_compression">
    </compression>

    <!-- Allow to execute distributed DDL queries (CREATE, DROP, ALTER, RENAME) on cluster.
                  Works only if ZooKeeper is enabled. Comment it if such functionality isn't required. -->
    <distributed_ddl>
        <!-- Path in ZooKeeper to queue with DDL queries -->
        <path>/a8root/clickhouse/task_queue/ddl</path>

        <!-- Settings from this profile will be used to execute DDL queries -->
        <!-- <profile>default</profile> -->
    </distributed_ddl>

    <graphite_rollup_example>
        <pattern>
            <regexp>click_cost</regexp>
            <function>any</function>
            <retention>
                <age>0</age>
                <precision>3600</precision>
            </retention>
            <retention>
                <age>86400</age>
                <precision>60</precision>
            </retention>
        </pattern>
        <default>
            <function>max</function>
            <retention>
                <age>0</age>
                <precision>60</precision>
            </retention>
            <retention>
                <age>3600</age>
                <precision>300</precision>
            </retention>
            <retention>
                <age>86400</age>
                <precision>3600</precision>
            </retention>
        </default>
    </graphite_rollup_example>
    <format_schema_path>/data2/clickhouse/format_schemas/</format_schema_path>
</yandex>
```

我们一般修改以下配置项：

- `logger` 修改日志的存放路径
- `http_port` 修改浏览器访问的端口，默认为`8123`
- `tcp_port` 修改tcp协议的传输端口
- `openSSL` 一些ssl的认证配置文件，我们暂时不做ssl认证，此处不做处理
- `listen_host` 如果我们要对外使用服务的话，此处需要修改成`0.0.0.0`
- `remote_servers` 此处是集群相关的配置信息后续会详解

其他自定义的配置可自行修改，修改配置后我们便可以启动一个本地的ClickHouse服务

- 创建相关目录及权限

```shell
mkdir -p /data2/clickhouse

chown -R clickhouse:clickhouse /data2/clickhouse
```

### 操作ClickHouse

---

- 启动服务

```shell
sudo -u clickhouse clickhouse-server --daemon --pid-file=/var/run/clickhouse-server/clickhouse-server.pid --config-file=/etc/clickhouse-server/config.xml
```

- `--daemon` 标志我们要后台启动服务
- `--pid-file` 指定服务启动后的进行文件路径
- `--config-file` 指定服务启动的配置文件

如果我们使用调试可使用以下命令

```shell
sudo -u clickhouse clickhouse-server start
```

> 要用单独的用户启动，如果使用root启动的话系统会做提示信息

### 调试ClickHouse服务

---

ClickHouse安装完成后会生成`clickhouse-server`和`clickhouse-client`两个目录，这个时候我们使用`clickhouse-client`去测试服务

```shell
clickhouse-client -h clickhouse --port 9000 --multiquery --query="show databases"
```

> 注意：--port指定的是tcp的端口

运行查询数据库列表返回类似以下信息

```shell
_temporary_and_external_tables
default
system
```

此语法可以使用多个SQL按照英文`;`分割每个SQL即可

> 更多clickhouse-client信息使用clickhouse-client --help查看
