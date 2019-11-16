# CentOS 7 安装JDK详细步骤

#### 第一种方式：yum命令安装

检索包含java的列表

```
[root@node-100 ~]# yum list java*

```

如果有结果类似如下：

```
[root@node-100 ~]# yum list java*
已加载插件：fastestmirror, langpacks
Determining fastest mirrors
* base: mirrors.nwsuaf.edu.cn
* extras: mirrors.cn99.com
* updates: mirrors.cn99.com
可安装的软件包
java-1.6.0-openjdk.x86_64                                                                   1:1.6.0.41-1.13.13.1.el7_3                                               base   
java-1.6.0-openjdk-demo.x86_64                                                              1:1.6.0.41-1.13.13.1.el7_3                                               base   
java-1.6.0-openjdk-devel.x86_64                                                             1:1.6.0.41-1.13.13.1.el7_3                                               base   
java-1.6.0-openjdk-javadoc.x86_64                                                           1:1.6.0.41-1.13.13.1.el7_3                                               base   
java-1.6.0-openjdk-src.x86_64                                                               1:1.6.0.41-1.13.13.1.el7_3                                               base   
java-1.7.0-openjdk.x86_64                                                                   1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.7.0-openjdk-accessibility.x86_64                                                     1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.7.0-openjdk-demo.x86_64                                                              1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.7.0-openjdk-devel.x86_64                                                             1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.7.0-openjdk-headless.x86_64                                                          1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.7.0-openjdk-javadoc.noarch                                                           1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.7.0-openjdk-src.x86_64                                                               1:1.7.0.201-2.6.16.1.el7_6                                               updates
java-1.8.0-openjdk.i686                                                                     1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk.x86_64                                                                   1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-accessibility.i686                                                       1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-accessibility.x86_64                                                     1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-accessibility-debug.i686                                                 1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-accessibility-debug.x86_64                                               1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-debug.i686                                                               1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-debug.x86_64                                                             1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-demo.i686                                                                1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-demo.x86_64                                                              1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-demo-debug.i686                                                          1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-demo-debug.x86_64                                                        1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-devel.i686                                                               1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-devel.x86_64                                                             1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-devel-debug.i686                                                         1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-devel-debug.x86_64                                                       1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-headless.i686                                                            1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-headless.x86_64                                                          1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-headless-debug.i686                                                      1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-headless-debug.x86_64                                                    1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-javadoc.noarch                                                           1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-javadoc-debug.noarch                                                     1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-javadoc-zip.noarch                                                       1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-javadoc-zip-debug.noarch                                                 1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-src.i686                                                                 1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-src.x86_64                                                               1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-src-debug.i686                                                           1:1.8.0.191.b12-1.el7_6                                                  updates
java-1.8.0-openjdk-src-debug.x86_64                                                         1:1.8.0.191.b12-1.el7_6                                                  updates
java-11-openjdk.i686                                                                        1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk.x86_64                                                                      1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-debug.i686                                                                  1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-debug.x86_64                                                                1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-demo.i686                                                                   1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-demo.x86_64                                                                 1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-demo-debug.i686                                                             1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-demo-debug.x86_64                                                           1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-devel.i686                                                                  1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-devel.x86_64                                                                1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-devel-debug.i686                                                            1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-devel-debug.x86_64                                                          1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-headless.i686                                                               1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-headless.x86_64                                                             1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-headless-debug.i686                                                         1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-headless-debug.x86_64                                                       1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc.i686                                                                1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc.x86_64                                                              1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc-debug.i686                                                          1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc-debug.x86_64                                                        1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc-zip.i686                                                            1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc-zip.x86_64                                                          1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc-zip-debug.i686                                                      1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-javadoc-zip-debug.x86_64                                                    1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-jmods.i686                                                                  1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-jmods.x86_64                                                                1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-jmods-debug.i686                                                            1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-jmods-debug.x86_64                                                          1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-src.i686                                                                    1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-src.x86_64                                                                  1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-src-debug.i686                                                              1:11.0.1.13-3.el7_6                                                      updates
java-11-openjdk-src-debug.x86_64                                                            1:11.0.1.13-3.el7_6                                                      updates
java-atk-wrapper.i686                                                                       0.30.4-5.el7                                                             base   
java-atk-wrapper.x86_64                                                                     0.30.4-5.el7                                                             base   
java_cup.noarch                                                                             1:0.11a-16.el7                                                           base   
java_cup-javadoc.noarch                                                                     1:0.11a-16.el7                                                           base   
java_cup-manual.noarch                                                                      1:0.11a-16.el7                                                           base   
javacc.noarch                                                                               5.0-10.el7                                                               base   
javacc-demo.noarch                                                                          5.0-10.el7                                                               base   
javacc-javadoc.noarch                                                                       5.0-10.el7                                                               base   
javacc-manual.noarch                                                                        5.0-10.el7                                                               base   
javacc-maven-plugin.noarch                                                                  2.6-17.el7                                                               base   
javacc-maven-plugin-javadoc.noarch                                                          2.6-17.el7                                                               base   
javamail.noarch                                                                             1.4.6-8.el7                                                              base   
javamail-javadoc.noarch                                                                     1.4.6-8.el7                                                              base   
javapackages-tools.noarch                                                                   3.4.1-11.el7                                                             base   
javassist.noarch                                                                            3.16.1-10.el7                                                            base   
javassist-javadoc.noarch                                                                    3.16.1-10.el7                                                            base   
[root@node-100 ~]# 

```

选择需要的JDK版本yum命令安装：

```
yum install -y java-1.8.0-openjdk-devel.x86_64    

```

检查版本：

```
[root@node-100 ~]# java -version
java version "1.8.0_191"
Java(TM) SE Runtime Environment (build 1.8.0_191-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.191-b12, mixed mode)
[root@node-100 ~]# 

```

#### 第二种方式：下载后安装

去Oracle官网下载所需JDK版本:

<https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html>

上传至所在服务器，进行解压后

```
[root@node-100 jdk1.8.0_191]# pwd
/usr/local/java/jdk1.8.0_191
[root@node-100 jdk1.8.0_191]# ls
bin  COPYRIGHT  include  javafx-src.zip  jre  lib  LICENSE  man  README.html  release  src.zip  THIRDPARTYLICENSEREADME-JAVAFX.txt  THIRDPARTYLICENSEREADME.txt
[root@node-100 jdk1.8.0_191]# 

```

设置环境变量：

```
[root@node-100 ~]# vim /etc/profile

```

新增：

```
#设置jdk环境变量
export JAVA_HOME=/usr/local/java/jdk1.8.0_191  #jdk安装目录

export JRE_HOME=${JAVA_HOME}/jre

export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib:$CLASSPATH

export JAVA_PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin

export PATH=$PATH:${JAVA_PATH}

:wq #保存

```

使其生效：

```
[root@node-100 ~]# source /etc/profile
[root@node-100 ~]# 

```

检查版本：

```
[root@node-100 ~]# java -version
java version "1.8.0_191"
Java(TM) SE Runtime Environment (build 1.8.0_191-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.191-b12, mixed mode)
[root@node-100 ~]#

```

------

##### 完。