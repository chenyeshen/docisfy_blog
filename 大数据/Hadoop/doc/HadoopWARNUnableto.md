# Hadoop之—— WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform...



直接在log4j日志中去除告警信息。在//usr/local/hadoop-2.5.2/etc/hadoop/log4j.properties文件中添加

```
log4j.logger.org.apache.hadoop.util.NativeCodeLoader=ERROR
```

