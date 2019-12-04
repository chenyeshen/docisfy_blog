# ssh实现远程免密登录

  平常我们每次登陆远程服务器都要输入密码多麻烦啊，而且远程服务器开启密码登陆可能被黑客暴力试错破解，因此后面我们会禁止服务器通过密码登录，不过我们先实现下免密登录再去那样做(不然你把密码登录关了还怎么登？？？哈哈)：
**①首先在客户端通过特定算法生成一对秘钥(公钥私钥)**

```
ssh-keygen -t rsa  -C "666666@gmail.com"

参数说明： 
-t 加密算法类型，这里是使用rsa算法 如果没有指定则默认生成用于SSH-2的RSA密钥。这里使用的是rsa。
同时在密钥中有一个注释字段，用-C来指定所指定的注释，可以方便用户标识这个密钥，指出密钥的用途或其他有用的信息。
所以在这里输入自己的邮箱或者其他信息都行

```

  当然，如果不想要这些可以直接输入(一般也是这么做的)下面命令：

```
ssh-keygen

```

  之后会在用户的根目录下的`.ssh`文件夹生成私钥`id_rsa`和公钥`id_rsa.pub`。本地的`.ssh`的文件夹存在以下几个文件:

```
id_rsa : 执行命令后生成的私钥文件
id_rsa.pub ： 执行命令后生成的公钥文件
know_hosts : 已知的主机公钥清单//ssh命令远程连接不同服务器时可以选择接受到不同的公钥，会将这些主机的公钥都保存在这里

```

`注意：`执行上面命令后，它要求你输入加密的一些附加参数，不用管，一般默认就好，**一直回车**即可生成秘钥。
**②将客户端的公钥~/.ssh/id_rsa.pub通过ssh-copy-id -i拷贝到服务器**

```
$ ssh-copy-id -i ~/.ssh/id_rsa.pub user@xxx.xxx.xxx.xxx

user代表Linux用户，xxx.xxx.xxx.xxx代表远程主机地址，下面为例子：
$ ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.2.128

```

`注意：`此时需要登录到[user@xxx.xxx.xxx.xxx](https://links.jianshu.com/go?to=mailto%3Auser%40xxx.xxx.xxx.xxx)服务器的密码(没错，这里又用到了前面**ssh密码登录**里讲过的步骤)，输入正确后即可在服务器生成公钥，**该公钥保存在服务器家目录的.ssh的authorized_keys文件中**(作用：存放远程免密登录的公钥,主要通过这个文件记录多台机器的公钥)，然后退出即可。
③当客户端以后再发送连接请求，包括**用户名、IP**：

```
ssh root@xxx.xxx.xxx.xxx

```

④服务器得到客户端的请求后，就会到`authorized_keys`中查找，如果有响应的用户名和IP，就会**随机**生成一个字符串；
⑤服务器将使用客户端拷贝过来的公钥进行加密，然后发送给客户端；
⑥得到服务器发送来的消息后，客户端会使用私钥进行解密，然后将解密后的字符串发送给服务器；
⑦服务器接收到客户端发送来的字符串后，跟之前的字符串进行对比，如果一致，就允许免密码登录。

  是不是很方便呢？

# 禁用密码登陆

  既然开启了SSH免密登陆，就可以把密码登陆关闭了。这样既可以快速连接远程服务器，也可以防止黑客攻击服务器，美滋滋啊。下面为具体步骤。

- 修改`/etc/ssh/sshd_config`文件:

```
vim /etc/ssh/sshd_config

```

- 将其中3行命令更改，前面若带#，就删掉，作用是可以用密钥登陆服务器：

```
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

```

- 然后在修改其中`PasswordAuthentication`属性为`no`，即禁用密码登陆：

```
PasswordAuthentication no

```

- 重启sshd服务：

```
systemctl restart sshd.service

```

`注`：本地密钥请保存好，远程服务器`authorized_keys`中公钥也别乱修改。