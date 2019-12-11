# 配置ssh免密码登陆配置

###  1. 查看.ssh文件

```
[root@localhost ~]# cd ~
[root@localhost ~]# ls -al
总用量 40
dr-xr-x---.  4 root root  181 11月 12 09:59 .
dr-xr-xr-x. 17 root root  240 11月  2 01:43 ..
-rw-------.  1 root root 1241 11月  1 14:04 anaconda-ks.cfg
-rw-------.  1 root root 9348 11月 12 12:13 .bash_history
-rw-r--r--.  1 root root   18 12月 29 2013 .bash_logout
-rw-r--r--.  1 root root  176 12月 29 2013 .bash_profile
-rw-r--r--.  1 root root  176 12月 29 2013 .bashrc
-rw-r--r--.  1 root root  100 12月 29 2013 .cshrc
-rw-------.  1 root root 1050 11月 12 01:51 .mysql_history
drwxr-----.  3 root root   19 11月  1 16:57 .pki
drwx------.  2 root root   80 11月 12 12:29 .ssh
-rw-r--r--.  1 root root  129 12月 29 2013 .tcshrc
[root@localhost ~]# 
```



![](https://i.loli.net/2019/11/12/T3tO7rkpAUu6f9W.png)

### 2. 进入.ssh目录下

```
[root@localhost ~]# cd .ssh/
[root@localhost .ssh]# ls
known_hosts

```

![](https://i.loli.net/2019/11/12/BkZp9KYszOgAhxj.png)

### 3.ssh生成秘钥

```
[root@localhost .ssh]# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:e2BG+ixGotwMDUdIHZX7TNGQ0nG8/v7eqJH/rRh2gOQ root@localhost
The key's randomart image is:
+---[RSA 2048]----+
| ..ooo.oo*.      |
|  ... o +.o      |
|  . .  o....     |
|   +  .o.o..     |
|  . o o+S.E .    |
| . = o =oo.  o   |
|  o o o + ..= .  |
|     . . . ..* o.|
|           .++*o+|
+----[SHA256]-----+
[root@localhost .ssh]# ^C
[root@localhost .ssh]# 

```

![](https://i.loli.net/2019/11/12/xwAquaDIRzQjHnC.png)

### 4.复制公钥

```
[root@localhost .ssh]# cp  id_rsa.pub  authorized_keys
```

![](https://i.loli.net/2019/11/12/KUuOpc1VWdMZBsf.png)

### 5.ssh登录本地测试成功

```
[root@localhost .ssh]# ssh localhost
Last login: Tue Nov 12 12:30:30 2019 from localhost
[root@localhost ~]# 

```

# 多系统免密码登录

在客户端服务器通过ssh-gen命令生成一个公钥/私钥，将生成的公钥拷贝到待免密码登陆的服务器，最后通过密钥加密解密配对的形式实现登陆。

服务系统A：192.168.65.128

服务系统B：192.168.65.129

服务系统A连接服务系统B

###  1.) 拷贝服务系统A中公钥id_rsa.pub到服务系统B

```
scp id_rsa.pub root@192.168.65.129:/opt/software/
```

### 2.) 在服务系统B中将服务系统A拷贝的公钥文件写入到认证文件

```
cat id_rsa.pub >> ~/.ssh/authorized_keys
```

![img](http://upload-images.jianshu.io/upload_images/5629542-9d0c90950c1c5aaf.png?imageMogr2/auto-orient/strip|imageView2/2/w/638/format/webp)



### 3.) 服务系统A测试登录服务系统B

![img](http://upload-images.jianshu.io/upload_images/5629542-40c2daf874e5fe18.png?imageMogr2/auto-orient/strip|imageView2/2/w/665/format/webp)

服务系统A登录服务系统B