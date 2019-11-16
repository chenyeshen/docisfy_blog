# mysql5.7初始化密码报错 ERROR 1820 (HY000): You must reset your password using ALTER USER statement before

### mysql初始化密码常见报错问题

**1，mysql5.6是密码为空直接进入数据库的，但是mysql5.7就需要初始密码**

```
cat /var/log/mysqld.log | grep password
```



**2，然后执行 mysql -uroot -p ，输入上面的到的密码进入，用该密码登录后，必须马上修改新的密码，不然会报如下错误**：

```
mysql> use mysql;
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
```


**3，如果你想要设置一个简单的测试密码的话，比如设置为123456，会提示这个错误，报错的意思就是你的密码不符合要求**

```
mysql> alter user 'root'@'localhost' identified by '123456';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
```


这个其实与validate_password_policy的值有关。

默认是1，即MEDIUM，所以刚开始设置的密码必须符合长度，且必须含有数字，小写或大写字母，特殊字符。
有时候，只是为了自己测试，不想密码设置得那么复杂，譬如说，我只想设置root的密码为123456。
必须修改两个全局参数：

首先，修改validate_password_policy参数的值

```
mysql> set global validate_password_policy=0;
Query OK, 0 rows affected (0.00 sec)
```


validate_password_length(密码长度)参数默认为8，我们修改为1

```
mysql> set global validate_password_length=1;
Query OK, 0 rows affected (0.00 sec)
```


**4，完成之后再次执行修改密码语句即可成功**

```
mysql> alter user 'root'@'localhost' identified by '123456';
Query OK, 0 rows affected (0.00 sec)
```

