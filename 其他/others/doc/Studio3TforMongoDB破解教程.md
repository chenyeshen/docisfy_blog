# Studio 3T 破解教程

**此教程并非真正破解，而是通过重置studio 3t的试用时间解决的。每次开机重启脚本重置试用时间**

### **1、创建文件studio3t.bat**

```
@echo off
ECHO 重置Studio 3T的使用日期......
FOR /f "tokens=1,2,* " %%i IN ('reg query "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\3t\mongochef\enterprise" ^| find /V "installation" ^| find /V "HKEY"') DO ECHO yes | reg add "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\3t\mongochef\enterprise" /v %%i /t REG_SZ /d ""
ECHO 重置完成, 按任意键退出......
pause>nul
exit
```

**如果上述内容不行，说明不识别中文字符，改为**

```
@echo 
ECHO 
FOR /f "tokens=1,2,* " %%i IN ('reg query "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\3t\mongochef\enterprise" ^| find /V "installation" ^| find /V "HKEY"') DO ECHO yes | reg add "HKEY_CURRENT_USER\Software\JavaSoft\Prefs\3t\mongochef\enterprise" /v %%i /t REG_SZ /d ""
ECHO 
pause>nul
exit
```

### 2 运行文件

##### 1. 可以双击studio3t.bat运行，打印`重置完成, 任意键退出.`说明已经破解

##### 2. 或者将文件studio3t.bat文件移动到如下路径中

```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp

```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191028144700.png)





