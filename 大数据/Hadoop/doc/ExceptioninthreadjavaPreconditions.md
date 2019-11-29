# Exception in thread “main” java.lang.NoClassDefFoundError: com/google/common/base/Preconditions

问题原因， hadoop 提供的相关  guava-版本号.jar 包与pom.xml版本不一致，设置相同即可。
此 jar 包的位置，在 hadoop 目录下的`/share/hadoop/tools/lib`.

```
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>27.0-jre</version>
</dependency>
```

![](https://i.loli.net/2019/11/29/4bNwSB7LkhXjcag.png)

