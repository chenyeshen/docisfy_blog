# rpm五种操作的常用命令

在 Linux 操作系统下，几乎所有的软件均通过RPM 进行安装、卸载及管理等操作。RPM 的全称为Redhat Package Manager ，是由Redhat 公司提出的，用于管理Linux 下软件包的软件。Linux 安装时，除了几个核心模块以外，其余几乎所有的模块均通过RPM 完成安装。RPM 有五种操作模式，分别为：安装、卸载、升级、查询和验证。

### **1、RPM 查询操作**

命令：
rpm -q …
附加查询命令：
a 查询所有已经安装的包
以下附加命令用于查询安装包的信息；
i 显示安装包的信息；
l 显示安装包中的所有文件被安装到哪些目录下；
s 显示安装版中的所有文件状态及被安装到哪些目录下；
以下附加命令用于指定需要查询的是安装包还是已安装后的文件；
p 查询的是安装包的信息；
f 查询的是已安装的某文件信息；
举例如下：
rpm -qa | grep tomcat4 查看 tomcat4 是否被安装；
rpm -qip example.rpm 查看 example.rpm 安装包的信息；
rpm -qif /bin/df 查看/bin/df 文件所在安装包的信息；
rpm -qlf /bin/df 查看/bin/df 文件所在安装包中的各个文件分别被安装到哪个目录下；

### **2、RPM 安装操作**

命令：
rpm -i 需要安装的包文件名
举例如下：
rpm -i example.rpm 安装 example.rpm 包；
rpm -iv example.rpm 安装 example.rpm 包并在安装过程中显示正在安装的文件信息；
rpm -ivh example.rpm 安装 example.rpm 包并在安装过程中显示正在安装的文件信息及安装进度；

### **3、RPM 卸载操作**

命令：
rpm -e 需要卸载的安装包
在卸载之前，通常需要使用rpm -q …命令查出需要卸载的安装包名称。
举例如下：
rpm -e tomcat4 卸载 tomcat4 软件包
rpm -evh example 卸载example软件包并在卸载过程中显示卸载的文件信息及卸载进度；

### **4、RPM 升级操作**

命令：
rpm -U 需要升级的包
举例如下：
rpm -Uvh example.rpm 升级example.rpm软件包并在升级过程中显示升级的文件信息及升级进度；

### **5、RPM 验证操作**

验证软件包是通过比较已安装的文件和软件包中的原始文件信息来进行的。验证主要是比较文件的尺寸， MD5 校验码，文件权限， 类型， 属主和用户组等。
如果有错误信息输出， 您应当认真加以考虑，是通过删除还是重新安装来解决出现的问题。
命令：
rpm -V 需要验证的包
举例如下：
rpm -Vf /etc/tomcat4/tomcat4.conf
输出信息类似如下：
S.5....T c /etc/tomcat4/tomcat4.conf
其中，S 表示文件大小修改过，T 表示文件日期修改过。

### **RPM 的其他附加命令**

--force 强制操作 如强制安装删除等；
--requires 显示该包的依赖关系；
--nodeps 忽略依赖关系并继续操作；

**例如：campost:~/backup/libxml2 # rpm -qa|grep xml**
yast2-xml-2.16.1-1.23
pyxml-0.8.4-194.17
libxml2-2.7.1-10.8
xmlcharent-0.3-403.14
libxml2-32bit-2.7.1-10.8
python-xml-2.6.0-8.6
libxml2-python-2.7.1-10.8
**campost:~/backup/libxml2 # rpm -ivh libxml2-devel-2.7.1-9.9.1.x86_64.rpm**
warning: libxml2-devel-2.7.1-9.9.1.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
error: Failed dependencies:
​        zlib-devel is needed by libxml2-devel-2.7.1-9.9.1.x86_64
​        readline-devel is needed by libxml2-devel-2.7.1-9.9.1.x86_64
**campost:~/backup/libxml2 # rpm -ivh zlib-devel-1.2.3-4.el5.x86_64.rpm**
warning: zlib-devel-1.2.3-4.el5.x86_64.rpm: Header V3 DSA signature: NOKEY, key ID e8562897
Preparing...                ########################################### [100%]
   1:zlib-devel             ########################################### [100%]
**campost:~/backup/libxml2 # rpm -ivh readline-devel-5.2-141.16.x86_64.rpm**
warning: readline-devel-5.2-141.16.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
error: Failed dependencies:
​        ncurses-devel is needed by readline-devel-5.2-141.16.x86_64
campost:~/backup/libxml2 # rpm -ivh ncurses-devel-5.6-89.16.x86_64.rpm
warning: ncurses-devel-5.6-89.16.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
error: Failed dependencies:
​        /usr/bin/tack is needed by ncurses-devel-5.6-89.16.x86_64
**campost:~/backup/libxml2 # rpm -ivh tack-5.6-89.16.x86_64.rpm**
warning: tack-5.6-89.16.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
Preparing...                ########################################### [100%]
   1:tack                   ########################################### [100%]
**campost:~/backup/libxml2 # rpm -ivh ncurses-devel-5.6-89.16.x86_64.rpm**
warning: ncurses-devel-5.6-89.16.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
Preparing...                ########################################### [100%]
   1:ncurses-devel          ########################################### [100%]
**campost:~/backup/libxml2 # rpm -ivh readline-devel-5.2-141.16.x86_64.rpm**
warning: readline-devel-5.2-141.16.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
Preparing...                ########################################### [100%]
   1:readline-devel         ########################################### [100%]
**campost:~/backup/libxml2 # rpm -ivh libxml2-devel-2.7.1-9.9.1.x86_64.rpm**
warning: libxml2-devel-2.7.1-9.9.1.x86_64.rpm: Header V3 RSA/SHA256 signature: NOKEY, key ID 3dbdc284
Preparing...                ########################################### [100%]
   1:libxml2-devel          ########################################### [100%]
**campost:~/backup/libxml2 # rpm -ivh libxml2-2.7.6-1.x86_64.rpm**
warning: libxml2-2.7.6-1.x86_64.rpm: Header V3 DSA signature: NOKEY, key ID de95bc1f
error: Failed dependencies:
​        rpmlib(FileDigests) <= 4.6.0-1 is needed by libxml2-2.7.6-1.x86_64