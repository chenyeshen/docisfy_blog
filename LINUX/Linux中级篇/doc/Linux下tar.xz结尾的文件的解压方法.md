

###  Linux下tar.xz结尾的文件的解压方法

```
$xz -d ***.**tar.xz**

$tar -xvf  ***.tar
```

​     可以看到这个压缩包也是打包后再压缩，外面是xz压缩方式，里层是tar打包方式。

​      **补充：目前可以直接使用 tar xvJf  \***.tar.xz来解压**