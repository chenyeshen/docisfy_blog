# 搭建hadoop伪分布式环境bug:Java HotSpot(TM) 64-Bit Server VM warning: You have loaded library /usr/local/hado

Java HotSpot(TM) 64-Bit Server VM warning: You have loaded library /usr/local/hadoop-2.2.0/lib/native/libhadoop.so.1.0.0 which might have disabled stack guard. The VM will try to fix the stack guard now.
....
Java: ssh: Could not resolve hostname Java: Name or service not known
HotSpot(TM): ssh: Could not resolve hostname HotSpot(TM): Name or service not known
64-Bit: ssh: Could not resolve hostname 64-Bit: Name or service not known
....

这个问题的错误原因会发生在64位的操作系统上，原因是从官方下载的hadoop使用的本地库文件(例如lib/native/libhadoop.so.1.0.0)都是基于32位编译的，运行在64位系统上就会出现上述错误。解决方法之一是在64位系统上重新编译hadoop，另一种方法是在hadoop-env.sh和yarn-env.sh中添加如下两行：

```
export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_PREFIX}/lib/native  
export HADOOP_OPTS="-Djava.library.path=$HADOOP_PREFIX/lib" 
```

