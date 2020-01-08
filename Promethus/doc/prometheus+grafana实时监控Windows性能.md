# prometheus + grafana 实时监控 Windows性能

## 下载Windows采集（wmi_exporter）

**下载地址：**https://github.com/martinlindhe/wmi_exporter/releases/download/v0.3.3/wmi_exporter-0.3.3-amd64.msi
Windows默认9182端口。直接双击安装即可。
访问http://IP:9182/metrics；显示以下数据说明数据采集器安装成功
![](https://i.loli.net/2020/01/08/gesJGIBpHc83TZW.png)

## 下载Prometheus安装包（Windows版本）

地址：<https://prometheus.io/download/>

![](https://i.loli.net/2020/01/08/gScxVFWv2z1BMLG.png)

## **Prometheus配置**：

prometheus.yml配置文件请求获取exporter采集器数据；

```
  - job_name: '工作名'
    static_configs:
    scrape_interval:5s
    - targets: ['IP:9182']
```

启动后 ，访问：<http://localhost:9090/>
能够访问，**说明安装并启动成功**。

![](https://i.loli.net/2020/01/08/tDKOwY4Rh3AkmvE.png)

选择**Status**下的**Targets**

![](https://i.loli.net/2020/01/08/YBrO9wodPu6IgCj.png)

## grafana配置Prometheus数据库

grafana导入dashboard 8781;

windows的dashboard模板  8781；
下载位置： <https://grafana.com/dashboards/8781>



Linux的dashboard模板;
下载位置： <https://grafana.com/dashboards/8919/revisions>

![](https://i.loli.net/2020/01/08/FXmBTKnrQRuw4MI.png)

导入模板点击load配置

![](https://i.loli.net/2020/01/08/NJLblwOmevSkoIt.png)

![](https://i.loli.net/2020/01/08/13nI9oDHEv64kmt.png)



导入数据源Prometheus模板

![](https://i.loli.net/2020/01/08/IeYXNPoVDhwCALT.png)



## Prometheus仪表盘

![](https://i.loli.net/2020/01/08/skYhTewRCEQc5af.png)

## springboot整合Prometheus+grafana仪表盘  （Dashboards： 4701）

启动Grafana，配置Prometheus数据源，这里以ID是4701的Doshboard为例（地址：https://grafana.com/dashboards/4701）如图。

在Grafana内点击如图所示import按钮

在如图所示位置填写4701，然后点击load。

接下来导入Doshboard。

![](https://i.loli.net/2020/01/08/ebCjVTKW6iINFkE.png)





![](https://i.loli.net/2020/01/08/ks4F7OoyZ1fWCBH.png)