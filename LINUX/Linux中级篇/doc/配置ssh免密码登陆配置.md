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

