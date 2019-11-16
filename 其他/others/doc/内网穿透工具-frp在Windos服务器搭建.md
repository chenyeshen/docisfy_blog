# 内网穿透工具-frp在Windos服务器搭建

对于没有公网 IP 的内网用户来说，远程管理或在外网访问内网机器上的服务是一个问题。通常解决方案就是用内网穿透工具将内网的服务穿透到公网中，便于远程管理和在外部访问。内网穿透的工具很多，之前也介绍过，比如nginx，花生壳等等。

今天给大家介绍另一款好用内网穿透工具 FRP，FRP 全名：Fast Reverse Proxy。FRP 是一个使用 Go 语言开发的高性能的反向代理应用，可以帮助您轻松地进行内网穿透，对外网提供服务。FRP 支持 TCP、UDP、HTTP、HTTPS等协议类型，并且支持 Web 服务根据域名进行路由转发。

FRP官方下载地址：https://github.com/fatedier/frp/releases  

## FRP 的作用

**1.利用处于内网或防火墙后的机器，对外网环境提供 HTTP 或 HTTPS 服务。**
**2.对于 HTTP, HTTPS 服务支持基于域名的虚拟主机，支持自定义域名绑定，使多个域名可以共用一个 80 端口。**
**3.利用处于内网或防火墙后的机器，对外网环境提供 TCP 和 UDP 服务，例如在家里通过 SSH 访问处于公司内网环境内的主机。**

## FRP 安装

### 我的环境：

```
新睿云云服务器：windows系统
域名：frp.chenyeshen.club 解释到该服务器上
```

### 查看服务的公网ip

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029120734.png)

### 打开防火墙 7000端口

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029120948.png)

### 云服务器下载frp

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029121144.png)

### 修改frps.ini

```
[common]
bind_port = 7000
vhost_http_port = 8080
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029121315.png)

### cmd启动服务端：

```
frps.exe -c frps.ini
不要直接双击 frps.exe
```

### 本地电脑下载frp   修改frpc.ini

```
[common]
server_addr = 115.220000000  //公网ip
server_port = 7000    //端口

[frp]
type = http
local_ip = 127.0.0.1
local_port = 8080
custom_domains = frp.chenyeshen.club
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029121951.png)

### 配置解析备案的域名

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029122147.png)

### cmd启动客户端 ：

```
frpc.exe
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191029122508.png)

**到这里恭喜搭建成功**

**本地运行一个8080端口项目 访问frp.chenyeshen.club就OK了**



