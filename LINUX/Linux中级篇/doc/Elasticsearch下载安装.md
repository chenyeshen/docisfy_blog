# Elasticsearch下载安装

### 1、Windows版

##### 1.1、下载

访问官网的下载地址：https://www.elastic.co/downloads/elasticsearch，windows版的下载ZIP格式的。

如果不想下载最新版的，可以点击“past releases”选择过去的版本。我这里下载的是6.2.4版本的。

##### 1.2、解压

解压下载的压缩包，比如我这里是解压到了D盘根目录，会出现D:\elasticsearch-6.2.4文件夹。

##### 1.3、启动

进入elasticsearch的bin目录，双击elasticsearch.bat启动服务，默认端口是9200，如下图：



启动完成之后，在浏览器中访问http://localhost:9200/，出现如下图所示内容表明Elasticsearch启动成功。



### 2、linux版（centos7）

##### 2.1、下载

如果你的linux可以访问外网的话，推荐直接在linux中下载，执行如下命令：

```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.4.tar.gz
```



##### 2.2、解压

执行解压命令：

```
tar -zxvf elasticsearch-6.2.4.tar.gz
```

解压完成后，会出现elasticsearch-6.2.4目录。

##### 2.3、启动

执行启动命令：

```
./bin/elasticsearch
```


如果你是root用户启动的话，会报"can not run elasticsearch as root"的错误。因为安全问题elasticsearch不让用root用户直接运行，所以要创建新用户，继续阅读2.4步骤。

##### 2.4、创建新用户

**第一步：liunx创建新用户："adduser yjclsx"，然后给创建的用户加密码："passwd yjclsx"，输入两次密码。**

**第二步：切换刚才创建的用户："su yjclsx"，然后启动elasticsearch。如果显示Permission denied权限不足，则继续进行第三步。**

**第三步：给新用户赋权限，因为这个用户本身就没有权限，肯定自己不能给自己付权限。所以要用root用户登录并赋予权限，chown -R yjclsx/你的elasticsearch安装目录。**

通过上面三步就可以启动elasticsearch了。

##### 2.5、验证启动是否成功

如果一切正常，Elasticsearch就会在默认的9200端口运行。这时，打开另一个命令行窗口，请求该端口：

```
curl localhost:9200
```


如果得到如下的返回，就说明启动成功了：



##### 2.6、远程访问elasticsearch服务

默认情况下，Elasticsearch 只允许本机访问，如果需要远程访问，可以修改 Elasticsearch 安装目录中的config/elasticsearch.yml文件，去掉network.host的注释，将它的值改成0.0.0.0，让任何人都可以访问，然后重新启动 Elasticsearch 。

```
network.host: 0.0.0.0
```


上面代码中，"network.host:"和"0.0.0.0"中间有个空格，不能忽略，不然启动会报错。线上服务不要这样设置，要设成具体的 IP。

##### 2.7、常见错误及其解决方式

**错误一：max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]**

解决：执行下面的命令：

```
sudo sysctl -w vm.max_map_count=262144
```


**错误二：max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]**

解决：执行下面的命令：

```
sudo vim /etc/security/limits.conf
```


在limits.conf最下方加入下面两行（这里的yjclsx是之前2.4步骤中新建的用户名）：

```
yjclsx hard nofile 65536
yjclsx soft nofile 65536
```

