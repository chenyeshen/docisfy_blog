### 修改权限-chmod

通过数字变更权限

r=4 w=2 x=1 rwx=4+2+1=7

chmod u=rwx,g=rx,o=x 文件目录名

相当于 chmod 751 文件目录名

• 案例演示

要求：将 /home/abc.txt 文件的权限修改成 rwxr-xr-x, 使用给数字的方式实现：

```
chmod  751 abc.txt
```

