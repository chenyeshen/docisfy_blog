# Hive入门及常用指令

## 基础命令

```
show databases; # 查看某个数据库
use 数据库;      # 进入某个数据库
show tables;    # 展示所有表
desc 表名;            # 显示表结构
show partitions 表名; # 显示表名的分区
show create table_name;   # 显示创建表的结构

# 建表语句
# 内部表
use xxdb; create table xxx;
# 创建一个表，结构与其他一样
create table xxx like xxx;
# 外部表
use xxdb; create external table xxx;
# 分区表
use xxdb; create external table xxx (l int) partitoned by (d string)
# 内外部表转化
alter table table_name set TBLPROPROTIES ('EXTERNAL'='TRUE'); # 内部表转外部表
alter table table_name set TBLPROPROTIES ('EXTERNAL'='FALSE');# 外部表转内部表

# 表结构修改
# 重命名表
use xxxdb; alter table table_name rename to new_table_name;
# 增加字段
alter table table_name add columns (newcol1 int comment ‘新增’)；
# 修改字段
alter table table_name change col_name new_col_name new_type；
# 删除字段(COLUMNS中只放保留的字段)
alter table table_name replace columns (col1 int,col2 string,col3 string)；
# 删除表
use xxxdb; drop table table_name;
# 删除分区
# 注意：若是外部表，则还需要删除文件(hadoop fs -rm -r -f  hdfspath)
alter table table_name drop if exists partitions (d=‘2016-07-01');

# 字段类型
# tinyint, smallint, int, bigint, float, decimal, boolean, string
# 复合数据类型
# struct, array, map

```

## 复合数据类型

```
# array
create table person(name string,work_locations array<string>)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ',';
# 数据
biansutao beijing,shanghai,tianjin,hangzhou
linan changchu,chengdu,wuhan
# 入库数据
LOAD DATA LOCAL INPATH '/home/hadoop/person.txt' OVERWRITE INTO TABLE person;
select * from person;
# biansutao       ["beijing","shanghai","tianjin","hangzhou"]
# linan           ["changchu","chengdu","wuhan"]

# map
create table score(name string, score map<string,int>)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ','
MAP KEYS TERMINATED BY ':';
# 数据
biansutao '数学':80,'语文':89,'英语':95
jobs '语文':60,'数学':80,'英语':99
# 入库数据
LOAD DATA LOCAL INPATH '/home/hadoop/score.txt' OVERWRITE INTO TABLE score;
select * from score;
# biansutao       {"数学":80,"语文":89,"英语":95}
# jobs            {"语文":60,"数学":80,"英语":99}

# struct
CREATE TABLE test(id int,course struct<course:string,score:int>)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ',';
# 数据
1 english,80
2 math,89
3 chinese,95
# 入库
LOAD DATA LOCAL INPATH '/home/hadoop/test.txt' OVERWRITE INTO TABLE test;
# 查询
select * from test;
# 1       {"course":"english","score":80}
# 2       {"course":"math","score":89}
# 3       {"course":"chinese","score":95}

```

## 配置优化

```
# 开启任务并行执行
set hive.exec.parallel=true
# 设置运行内存
set mapreduce.map.memory.mb=1024;
set mapreduce.reduce.memory.mb=1024;
# 指定队列
set mapreduce.job.queuename=jppkg_high;
# 动态分区，为了防止一个reduce处理写入一个分区导致速度严重降低，下面需设置为false
# 默认为true
set hive.optimize.sort.dynamic.partition=false;
# 设置变量
set hivevar:factor_timedecay=-0.3;
set hivevar:pre_month=${zdt.addDay(-30).format("yyyy-MM-dd")};
set hivevar:pre_date=${zdt.addDay(-1).format("yyyy-MM-dd")};
set hivevar:cur_date=${zdt.format("yyyy-MM-dd")};
# 添加第三方jar包, 添加临时函数
add jar ***.jar;
# 压缩输出，ORC默认自带压缩，不需要额外指定,如果使用非ORCFile,则设置如下
hive.exec.compress.output=true
# 如果一个大文件可以拆分，为防止一个Map读取过大的数据，拖慢整体流程，需设置
hive.hadoop.suports.splittable.combineinputformat
# 避免因数据倾斜造成的计算效率，默认false
hive.groupby.skewindata
# 避免因join引起的数据倾斜
hive.optimize.skewjoin
# map中会做部分聚集操作，效率高，但需要更多内存
hive.map.aggr   -- 默认打开
hive.groupby.mapaggr.checkinterval  -- 在Map端进行聚合操作的条目数目
# 当多个group by语句有相同的分组列，则会优化为一个MR任务。默认关闭。
hive.multigroupby.singlemr
# 自动使用索引，默认不开启，需配合row group index，可以提高计算速度
hive.optimize.index.filter

```

## 常用函数

```
# if 函数，如果满足条件，则返回A， 否则返回B
if (boolean condition, T A, T B)
# case 条件判断函数, 当a为b时则返回c；当a为d时，返回e；否则返回f
case a when b then c when d then e else f end
# 将字符串类型的数据读取为json类型，并得到其中的元素key的值
# 第一个参数填写json对象变量，第二个参数使用$表示json变量标识，然后用.读取对象或数组；
get_json_object(string s, '$.key')
# url解析
# parse_url('http://facebook.com/path/p1.php?query=1','HOST')返回'facebook.com' 
# parse_url('http://facebook.com/path/p1.php?query=1','PATH')返回'/path/p1.php' 
# parse_url('http://facebook.com/path/p1.php?query=1','QUERY')返回'query=1'，
parse_url()
# explode就是将hive一行中复杂的array或者map结构拆分成多行
explode(colname)
# lateral view 将一行数据adid_list拆分为多行adid后，使用lateral view使之成为一个虚表adTable，使得每行的数据adid与之前的pageid一一对应, 因此最后pageAds表结构已发生改变，增加了一列adid
select pageid, adid from pageAds
lateral view explode(adid_list) adTable as adid
# 去除两边空格
trim()
# 大小写转换
lower(), upper()
# 返回列表中第一个非空元素,如果所有值都为空，则返回null
coalesce(v1, v2, v3, ...)
# 返回当前时间
from_unixtime(unix_timestamp(), 'yyyy-MM-dd HH:mm:ss')
# 返回第二个参数在待查找字符串中的位置（找不到返回0）
instr(string str, string search_str)
# 字符串连接
concat(string A, string B, string C, ...)
# 自定义分隔符sep的字符串连接
concat_ws(string sep, string A, string B, string C, ...)
# 返回字符串长度
length()
# 反转字符串
reverse()
# 字符串截取
substring(string A, int start, int len)
# 将字符串A中的符合java正则表达式pat的部分替换为C;
regexp_replace(string A, string pat, string C)
# 将字符串subject按照pattern正则表达式的规则进行拆分，返回index制定的字符
# 0:显示与之匹配的整个字符串， 1：显示第一个括号里的， 2：显示第二个括号里的
regexp_extract(string subject, string pattern, int index)
# 按照pat字符串分割str，返回分割后的字符串数组
split(string str, string pat)
# 类型转换
cast(expr as type)
# 将字符串转为map, item_pat指定item之间的间隔符号，dict_pat指定键与值之间的间隔
str_to_map(string A, string item_pat, string dict_pat)
# 提取出map的key, 返回key的array
map_keys(map m)
# 日期函数
# 日期比较函数，返回相差天数，datediff('${cur_date},d)
    datediff(date1, date2)

```

## HQL和SQL的差异点

```
# 1 select distinct 后必须指定字段名
# 2 join 条件仅支持等值关联且不支持or条件
# 3 子查询不能在select中使用；
# 4 HQL中没有UNION，可使用distinct+ union all 实现 UNION；
# 5 HQL以分号分隔，必须在每个语句结尾写上分号；
# 6 HQL中字符串的比较比较严格，区分大小写及空格，因此在比较时建议upper(trim(a))=upper(trim(b))
# 7 日期判断，建议使用to_date(),如：to_date(orderdate)=‘2016-07-18’
# 8 关键字必须在字段名上加``符号，如select `exchange` from xxdb.xxtb;
# 9 数据库和表/视图之间仅有1个点，如xx_db.xx_tb;

# HQL不支持update/delete
# 实际采用union all + left join (is null)变相实现update
# 思路：
# 1 取出增量数据；
# 2 使用昨日分区的全量数据通过主键左连接增量数据，并且只取增量表中主键为空的数据（即，取未发生变化的全量数据）；
# 3 合并1、2的数据覆盖至最新的分区，即实现了update；

# HQL delete实现
# 采用not exists/left join(is null)的方法变相实现。
# 1.取出已删除的主键数据（表B）；
# 2.使用上一个分区的全量数据（表A）通过主键左连接A，并且只取A中主键为空的数据，然后直接insert overwrite至新的分区；
```

## 基本概念

```
# hive
hive是基于hadoop的一个数据仓库工具，可以将结构化的数据文件映射为一张数据库库表，并提供类SQL查询功能。
# 基本组成
用户接口：CLI，shell命令行；JDBC/ODBC是hive的java实现；webGUI是通过浏览器访问hive；
元数据存储：通常是存储在关系数据库如mysql, derby中；hive的元数据包括表的名字，表的列和分区及其属性，表的属性（是否为外部表），表的数据所在目录等。
解释器，编译器，优化器完成HQL查询语句从词法分析，语法分析，编译，优化以及查询计划的生成。生成的查询存储在HDFS中，并随后有mapreduce调用执行。
因此，hive与Hadoop的关系可以理解为用户发出SQL查询语句，hive将查询存储在HDFS中，然后由mapreduce调用执行。
# table
Hive 中的 Table 和数据库中的 Table 在概念上是类似的，每一个 Table 在 Hive 中都有一个相应的目录存储数据。例如，一个表 pvs，它在 HDFS 中的路径为：/wh/pvs，其中，wh 是在 hive-site.xml 中由 ${hive.metastore.warehouse.dir} 指定的数据仓库的目录，所有的 Table 数据（不包括 External Table）都保存在这个目录中。
# partition
Partition 对应于数据库中的 Partition 列的密集索引，但是 Hive 中 Partition 的组织方式和数据库中的很不相同。在 Hive 中，表中的一个 Partition 对应于表下的一个目录，所有的 Partition 的数据都存储在对应的目录中。例如：pvs 表中包含 ds 和 city 两个 Partition，则对应于 ds = 20090801, ctry = US 的 HDFS 子目录为：/wh/pvs/ds=20090801/ctry=US；对应于 ds = 20090801, ctry = CA 的 HDFS 子目录为；/wh/pvs/ds=20090801/ctry=CA
# buckets
Buckets 对指定列计算 hash，根据 hash 值切分数据，目的是为了并行，每一个 Bucket 对应一个文件。将 user 列分散至 32 个 bucket，首先对 user 列的值计算 hash，对应 hash 值为 0 的 HDFS 目录为：/wh/pvs/ds=20090801/ctry=US/part-00000；hash 值为 20 的 HDFS 目录为：/wh/pvs/ds=20090801/ctry=US/part-00020
# external table
External Table 指向已经在 HDFS 中存在的数据，可以创建 Partition。它和 Table 在元数据的组织上是相同的，而实际数据的存储则有较大的差异。
Table 的创建过程和数据加载过程（这两个过程可以在同一个语句中完成），在加载数据的过程中，实际数据会被移动到数据仓库目录中；之后对数据对访问将会直接在数据仓库目录中完成。删除表时，表中的数据和元数据将会被同时删除。
External Table 只有一个过程，加载数据和创建表同时完成（CREATE EXTERNAL TABLE ……LOCATION），实际数据是存储在 LOCATION 后面指定的 HDFS 路径中，并不会移动到数据仓库目录中。当删除一个 External Table 时，仅删除元数据，表中的数据不会真正被删除。
# 全量数据和增量数据
查看分区信息
如果分区的大小随时间增加而增加，则最新的分区为全量数据
如果分区的大小随时间增加而大小上下变化，则每个分区都是增量数据
```

## 实际使用

```
# 增加分区
insert overwrite table table_name partition (d='${pre_date}')

# 建表语句
# 进行分区，每个分区相当于是一个文件夹，如果是双分区，则第二个分区作为第一个分区的子文件夹
drop table if exists employees;  
create table  if not exists employees(  
       name string,  
       salary float,  
       subordinate array<string>,  
       deductions map<string,float>,  
       address struct<street:string,city:string,num:int>  
) partitioned by (date_time string, type string)
row format delimited
fields terminated by '\t'
collection items terminated by ','
map keys terminated by ':'
lines terminated by '\n'
stored as textfile
location '/hive/...';

# hive桶
# 分区是粗粒度的，桶是细粒度的
# hive针对某一列进行分桶，对列值哈希，然后除以桶的个数求余的方式决定该条记录存放在哪个桶中
create table bucketed_user(id int, name string)
clustered by (id) sorted by (name) into 4 buckets
row format delimited
fields terminated by '\t'
stored as textfile;
# 注意，使用桶表的时候我们要开启桶表
set hive.enforce.bucketing=true;
# 将employee表中的name和salary查询出来插入到表中
insert overwrite table bucketed_user select salary, name from employees

如果字段类型是string，则通过get_json_object提取数据；
如果字段类型是struct或map,则通过col['xx']方式提取数据；
```

## shell指令

```
#!/bin/bash
hive -e "use xxxdb;"

cnt = `hive -e "..."`
echo "cnt=${cnt}"

# 循环语句
for ((i=1; i<=10; i+=1))
do
pre_date=`date -d -${i}days +%F`
done

# 定义日期
pre_date=`date -d -1days +%F`
pre_week=`date -d -7days +%F`

# 设置环境变量
export JAVA_HOME=jdk;
```

