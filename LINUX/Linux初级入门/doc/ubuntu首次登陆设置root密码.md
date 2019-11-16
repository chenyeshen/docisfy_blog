### 给root用户设置密码

ubuntu默认root密码是随机的，即每次开机都有一个新的root密码。我们可以在终端输入命令sudo passwd，然后输入当前用户的密码

**打开终端，输入命令**

```
sudo passwd
```



然后系统会让你输入新密码并确认，此时的密码就是root新密码。修改成功后，输入命令

```
su root
```

，再输入新的密码就ok了 

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191024181202.png)

