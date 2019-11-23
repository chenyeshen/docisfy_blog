# hive环境搭建提示: java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument

提示的错误信息:

```
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]

Exception in thread "main" java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument(ZLjava/lang/String;Ljava/lang/Object;)V
        at org.apache.hadoop.conf.Configuration.set(Configuration.java:1357)
        at org.apache.hadoop.conf.Configuration.set(Configuration.java:1338)
        at org.apache.hadoop.mapred.JobConf.setJar(JobConf.java:536)
        at org.apache.hadoop.mapred.JobConf.setJarByClass(JobConf.java:554)
        at org.apache.hadoop.mapred.JobConf.<init>(JobConf.java:448)
        at org.apache.hadoop.hive.conf.HiveConf.initialize(HiveConf.java:5141)
        at org.apache.hadoop.hive.conf.HiveConf.<init>(HiveConf.java:5099)
        at org.apache.hadoop.hive.common.LogUtils.initHiveLog4jCommon(LogUtils.java:97)
        at org.apache.hadoop.hive.common.LogUtils.initHiveLog4j(LogUtils.java:81)
        at org.apache.hadoop.hive.cli.CliDriver.run(CliDriver.java:699)
        at org.apache.hadoop.hive.cli.CliDriver.main(CliDriver.java:683)
        at sunreflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at org.aache.hadoop.util.RunJar.run(RunJar.java:323)
        at org.apache.hadoop.util.RunJar.main(RunJar.java:236)
```

关键在： com.google.common.base.Preconditions.checkArgument 这是因为hive内依赖的**guava.jar**和hadoop内的**版本不一致**造成的。 检验方法：

1. 查看hadoop安装目录下share/hadoop/common/lib内guava.jar版本
2. 查看hive安装目录下lib内guava.jar的版本 如果两者不一致，删除版本低的，并拷贝高版本的 问题解决！

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191123110341.png)

