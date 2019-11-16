# **windows10环境下的RabbitMQ安装步骤（图文）**

记录下本人在win10环境下安装RabbitMQ的步骤，以作备忘。

#### 第一步：下载并安装erlang

- 原因：RabbitMQ服务端代码是使用并发式语言Erlang编写的，安装Rabbit MQ的前提是安装Erlang。
- 下载地址：<http://www.erlang.org/downloads>

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100207108.png)

根据本机位数选择erlang下载版本。

- 下载完是这么个东西：

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100208044.png)

- 双击，点next就可以。

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100210984.png)

- 选择一个自己想保存的地方，然后next、finish就可以。

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100212393.png)

- 安装完事儿后要记得配置一下系统的环境变量。

此电脑-->鼠标右键“属性”-->高级系统设置-->环境变量-->“新建”系统环境变量

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100204703.png)

变量名：ERLANG_HOME

变量值就是刚才erlang的安装地址，点击确定。

然后双击系统变量path

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100211680.png)

点击“新建”，将%ERLANG_HOME%\bin加入到path中。

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100210271.png)

- 最后windows键+R键，输入cmd，再输入erl，看到版本号就说明erlang安装成功了。

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100213094.png)

#### 第二步：下载并安装RabbitMQ

- 下载地址：<http://www.rabbitmq.com/download.html>


- 双击下载后的.exe文件，安装过程与erlang的安装过程相同。
- RabbitMQ安装好后接下来安装RabbitMQ-Plugins。打开命令行cd，输入RabbitMQ的sbin目录。

我的目录是：D:\Program Files\RabbitMQ Server\rabbitmq_server-3.7.3\sbin

然后在后面输入rabbitmq-plugins enable rabbitmq_management命令进行安装

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100208714.png)

打开sbin目录，双击rabbitmq-server.bat

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100209495.png)

等几秒钟看到这个界面后，访问http://localhost:15672

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100205339.png)

然后可以看到如下界面

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528100213819.png)

默认用户名和密码都是guest

登陆即可。