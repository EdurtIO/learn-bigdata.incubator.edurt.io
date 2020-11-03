---
layout: default
title: Presto自定义Scalar函数
nav_order: 4
has_children: false
parent: Development(开发)
grand_parent: Presto
---

## 目录
{: .no_toc .text-delta }

1. TOC
{:toc}

在Presto中有大量的function,但是这些函数并不能完全的适合我们的使用,比如我们想直接使用某些hive的函数在presto中,那么此时就需要进行自定义函数,在presto中函数分为`scalar`,`window`,`aggregate`这三种形式,本文我们主要讲解如何自定义一个`scalar`的函数~

`scalar`函数应用于列表的每个元素（在这种情况下为每个选定的行），而无需更改列表的元素的顺序或数量。具体含义详见[map functions](https://en.wikipedia.org/wiki/Map_(higher-order_function))

### 开发环境准备

---

> 注意: 此步操作将影响到后续的所有操作,请严格按照规则准备

- 必备条件

    - 务必要确保线上或者需要使用的Presto版本
    - 根据Presto版本要选择相应的JDK环境(`>=`)

- 可选条件

    - Presto实际运行环境
    
- 开发环境(以下是我的开发环境)

|名称|版本|
|:---:|:---:|
|presto|0.235|
|java|>=1.8.0_212|
|maven|>=3.5.0|

### 开发代码

---

- 创建一个maven项目

```bash
mvn archetype:generate -DgroupId=io.edurt.tutorial -DartifactId=tutorial -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

- 使用IDEA打开创建好的项目删除以下文件

```java
src/main/java/io/edurt/tutorial/App.java
src/test/java/io/edurt/tutorial/AppTest.java
```

- 为了方便后续我们其他函数的教程接下来我们按照module的形式进行开发[`可选`]

修改`pom.xml`文件中的`<packaging>jar</packaging>`为`<packaging>pom</packaging>`

```java
cd tutorial
mvn archetype:generate -DarchetypeCatalog=internal -DgroupId=io.edurt.tutorial -DartifactId=tutorial-presto -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```

- 增加presto模块必备的依赖包

在pom.xml文件中增加以下内容

```java
<properties>
    <java.version>1.8</java.version>
    <dependency.presto.version>0.235-SNAPSHOT</dependency.presto.version>
    <plugin.maven.compiler.version>2.3.2</plugin.maven.compiler.version>
</properties>

<dependencies>
    <dependency>
        <groupId>com.facebook.presto</groupId>
        <artifactId>presto-main</artifactId>
        <version>${dependency.presto.version}</version>
    </dependency>
    <dependency>
        <groupId>com.facebook.presto</groupId>
        <artifactId>presto-spi</artifactId>
        <version>${dependency.presto.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>${plugin.maven.compiler.version}</version>
            <configuration>
                <source>${java.version}</source>
                <target>${java.version}</target>
                <encoding>UTF-8</encoding>
            </configuration>
        </plugin>
    </plugins>
</build>
```

- 我们创建一个简单的`hello_scalar`函数来判断字符串的非空状态,创建核心类文件`StringFunctions`

在该文件中键入以下内容

```java
import com.facebook.presto.spi.function.Description;
import com.facebook.presto.spi.function.ScalarFunction;
import com.facebook.presto.spi.function.SqlNullable;
import com.facebook.presto.spi.function.SqlType;
import com.facebook.presto.spi.type.StandardTypes;
import io.airlift.slice.Slice;
import io.airlift.slice.Slices;

public class StringFunctions {

    private StringFunctions() {
    }

    @SqlNullable
    @ScalarFunction(value = "hello_scalar")
    @Description(value = "print hello scalar")
    @SqlType(StandardTypes.VARCHAR)
    public static Slice helloScalar(@SqlType(StandardTypes.VARCHAR) Slice string) {
        return Slices.utf8Slice("hello scalar");
    }

}
```

`@SqlNullable` 标记参数可以是空
`@ScalarFunction` 用来标记我们提供的函数名称
`@Description` 对该函数的描述
`@SqlType` 参数的类型,详见`StandardTypes`类即可

> 注意: 传递的参数类型是`Slice`,然后在使用`@SqlType`标注数据类型

#### 编写单元测试模块

---

- 编写函数测试类`TestStringFunctions`

在pom.xml文件中增加以下依赖

```java
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.12</version>
</dependency>
```

在`TestStringFunctions`文件中添加以下内容

```java
import com.facebook.presto.metadata.FunctionListBuilder;
import io.airlift.slice.Slice;
import io.airlift.slice.Slices;
import io.edurt.tutorial.presto.scalar.function.StringFunctions;
import org.junit.Assert;
import org.junit.Test;

public class TestStringFunctions {

    @Test
    public void testFunctionCreate() throws Exception {
        FunctionListBuilder builder = new FunctionListBuilder();
        builder.scalars(StringFunctions.class);
    }

    @Test
    public void testHelloScalar() throws Exception {
        Slice result = StringFunctions.helloScalar(Slices.utf8Slice("中国"));
        Assert.assertEquals("hello scalar", result.toStringUtf8());
    }

}
```

运行单元测试代码即可,测试通过后说明我们定义的function没有问题!

此时我们的函数已经定义好了,不过我们还需要将我们定义好的函数通知presto加载,presto是以插件形式进行加载function的,接下来编写插件的引导区

- 新建插件引导器类文件`FunctionLoadPlugin`

插件引导器大致做以下3种操作:

1.实现Presto的插件机制主类`com.facebook.presto.spi.Plugin`
2.实现插件文件的加载
3.实现插件文件的解压

通过以上操作我们的插件引导器代码如下:

```java
import com.facebook.presto.spi.Plugin;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class FunctionLoadPlugin implements Plugin {

    private List<Class<?>> getFunctionClasses() throws IOException {
        List<Class<?>> classes = Lists.newArrayList();
        String classResource = this.getClass().getName().replace(".", "/") + ".class";
        String jarURLFile = Thread.currentThread().getContextClassLoader().getResource(classResource).getFile();
        int jarEnd = jarURLFile.indexOf('!');
        String jarLocation = jarURLFile.substring(0, jarEnd); // This is in URL format, convert once more to get actual file location
        jarLocation = new URL(jarLocation).getFile();

        ZipInputStream zip = new ZipInputStream(new FileInputStream(jarLocation));
        for (ZipEntry entry = zip.getNextEntry(); entry != null; entry = zip.getNextEntry()) {
            if (entry.getName().endsWith(".class") && !entry.isDirectory()) {
                String className = entry.getName().replace("/", "."); // This still has .class at the end
                className = className.substring(0, className.length() - 6); // remvove .class from end
                try {
                    classes.add(Class.forName(className));
                } catch (ClassNotFoundException e) {
                }
            }
        }
        return classes;
    }

    @Override
    public Set<Class<?>> getFunctions() {
        try {
            List<Class<?>> classes = getFunctionClasses();
            Set<Class<?>> set = Sets.newHashSet();
            for (Class<?> clazz : classes) {
                if (clazz.getName().startsWith("io.edurt.tutorial.presto.scalar.function")) {
                    set.add(clazz);
                }
            }
            return ImmutableSet.<Class<?>>builder().addAll(set).build();
        } catch (IOException e) {
            return ImmutableSet.of();
        }

    }
}
```

- 添加插件扫描配置

在`src/main/resources`目录下创建`META-INF/services`文件夹,并在该文件夹下创建`com.facebook.presto.spi.Plugin`文件,在文件中录入以下内容

```java
io.edurt.tutorial.presto.scalar.FunctionLoadPlugin
```

文件内容为指定加载插件的主类

#### 服务器测试function

- 打包文件,同步到服务器进行测试

打包前我们还需要修改我们的pom.xml配置文件

修改`build`模块添加以下内容

```java
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-release-plugin</artifactId>
    <version>2.5.1</version>
</plugin>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>2.3</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <artifactSet>
                    <includes>
                        <include>com.google.guava:guava</include>
                    </includes>
                </artifactSet>
                <relocations>
                    <relocation>
                        <pattern>com.google</pattern>
                        <shadedPattern>com.google.shaded</shadedPattern>
                    </relocation>
                </relocations>
            </configuration>
        </execution>
    </executions>
</plugin>
```

进入项目根目录执行以下命令

```bash
mvn clean package -X
```

- 远程服务器测试

我们将打包好的文件上传到远程服务器的`<PrestoHome>/plugin/<PluginName>`目录,将打包好的插件放到`<PluginName>`目录重启presto服务(*每个节点都要做此操作*)

使用Presto客户端连接Presto服务(注意替换为客户端的路径)

```java
./presto-cli-0.235-executable.jar --server 'localhost:8080'
```

执行sql

```java
select hello_scalar('');
```

以下是返回结果

```java
    _col0
--------------
 hello scalar
(1 row)

Query 20200427_020056_00002_h5i5g, FINISHED, 1 node
Splits: 17 total, 17 done (100.00%)
0:02 [0 rows, 0B] [0 rows/s, 0B/s]
```

源码详见[GitHub](https://github.com/EdurtIO/tutorial/tree/master/presto/presto-functions-scalar)