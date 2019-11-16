# ls command not found 的解决办法

原因是因为环境变量的问题，编辑profile文件没有写正确，导致在命令行下 ls等命令不能够识别。

解决办法：在命令行下打入下面这段就可以了

```
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191101104254.png)

