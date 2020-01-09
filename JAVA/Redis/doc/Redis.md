[TOC]
Redis是一个开源的，先进的 key-value 存储可用于构建高性能，可扩展的 Web 应用程序的解决方案。Redis官方网网站是：http://www.redis.io/，如下：
 
 
Redis 有三个主要使其有别于其它很多竞争对手的特点：
 
- Redis是完全在内存中保存数据的数据库，使用磁盘只是为了持久性目的； 
- Redis相比许多键值数据存储系统有相对丰富的数据类型； 
- Redis可以将数据复制到任意数量的从服务器中； 
 
## Redis优点
 
- **异常快速 : **Redis是非常快的，每秒可以执行大约110000设置操作，81000个/每秒的读取操作。
 
- **支持丰富的数据类型 : **Redis支持最大多数开发人员已经知道如列表，集合，可排序集合，哈希等数据类型。
 
  这使得在应用中很容易解决的各种问题，因为我们知道哪些问题处理使用哪种数据类型更好解决。
 
- **操作都是原子的 : **所有 Redis 的操作都是原子，从而确保当两个客户同时访问 Redis 服务器得到的是更新后的值（最新值）。
 
- **MultiUtility工具：**Redis是一个多功能实用工具，可以在很多如：缓存，消息传递队列中使用（Redis原生支持发布/订阅），在应用程序中，如：Web应用程序会话，网站页面点击数等任何短暂的数据；
 
## Redis环境
 
要在 Ubuntu 上安装 Redis，打开终端，然后输入以下命令：
 
```
$sudo apt-get update
$sudo apt-get install redis-server
```
 
这将在您的计算机上安装Redis
 
**启动 Redis**
 
```
$redis-server
```
 
**查看 redis 是否还在运行**
 
```
$redis-cli
```
 
这将打开一个 Redis 提示符，如下图所示：
 
```
redis 127.0.0.1:6379>
```
 
在上面的提示信息中：127.0.0.1 是本机的IP地址，6379是 Redis 服务器运行的端口。现在输入 PING 命令，如下图所示：
 
```
redis 127.0.0.1:6379> ping
PONG
```
 
这说明现在你已经成功地在计算机上安装了 Redis。
 
## 在Ubuntu上安装Redis桌面管理器
 
要在Ubuntu 上安装 Redis桌面管理，可以从 [http://redisdesktop.com/download](http://redisdesktop.com/download) 下载包并安装它。
 
Redis 桌面管理器会给你用户界面来管理 Redis 键和数据。
 
## Redis数据类型
 
Redis 支持5种数据类型，说明如下：
 
## 字符串
 
Redis 字符串是一个字节序列。在 Redis 中字符串是二进制安全的，这意味着它们没有任何特殊终端字符来确定长度，所以可以存储任何长度为 512 兆的字符串。
 
**示例**
 
```
redis 127.0.0.1:6379> SET name "yiibai"
OK
redis 127.0.0.1:6379> GET name
"yiibai"
```
 
在上面的例子中，SET 和 GET 是 Redis 命令，name 和 "yiibai" 是存储在 Redis 的键和字符串值。
 
## 哈希
 
Redis哈希是键值对的集合。 Redis哈希是字符串字段和字符串值之间的映射，所以它们用来表示对象。
 
**示例**
 
```
redis 127.0.0.1:6379> HMSET user:1 username yiibai password yiibai points 200
OK
redis 127.0.0.1:6379> HGETALL user:1
 
1) "username"
2) "yiibai"
3) "password"
4) "yiibai"
5) "points"
6) "200"
```
 
在上面的例子中，哈希数据类型用于存储包含用户基本信息的用户对象。这里 HSET，HEXTALL 是 Redis 命令同时 user:1 也是一个键。
 
## 列表
 
Redis 列表是简单的字符串列表，通过插入顺序排序。可以添加一个元素到 Redis 列表的头部或尾部。
 
**示例**
 
```
redis 127.0.0.1:6379> lpush tutoriallist redis
(integer) 1
redis 127.0.0.1:6379> lpush tutoriallist mongodb
(integer) 2
redis 127.0.0.1:6379> lpush tutoriallist rabitmq
(integer) 3
redis 127.0.0.1:6379> lrange tutoriallist 0 10
 
1) "rabitmq"
2) "mongodb"
3) "redis"
```
 
列表的最大长度为  232 - 1 个元素（4294967295，每个列表的元素超过四十亿）。
 
## 集合
 
Redis 集合是字符串的无序集合。在 Redis 可以添加，删除和测试成员存在的时间复杂度为 O（1）。
 
**示例**
 
```
redis 127.0.0.1:6379> sadd tutoriallist redis
(integer) 1
redis 127.0.0.1:6379> sadd tutoriallist mongodb
(integer) 1
redis 127.0.0.1:6379> sadd tutoriallist rabitmq
(integer) 1
redis 127.0.0.1:6379> sadd tutoriallist rabitmq
(integer) 0
redis 127.0.0.1:6379> smembers tutoriallist
 
1) "rabitmq"
2) "mongodb"
3) "redis"
```
 
注：在上面的例子中 rabitmq 被添加两次，但由于它是只集合具有唯一特性。集合中的成员最大数量为 232 - 1（4294967295，每个集合有超过四十亿条记录）。
 
## 集合排序
 
不同的是，一个有序集合的每个成员都可以排序，就是为了按有序集合排序获取它们，按权重分值从最小到最大排序。虽然成员都是独一无二的，按权重分数值可能会重复。
 
**示例**
 
```
redis 127.0.0.1:6379> zadd tutoriallist 0 redis
(integer) 1
redis 127.0.0.1:6379> zadd tutoriallist 0 mongodb
(integer) 1
redis 127.0.0.1:6379> zadd tutoriallist 0 rabitmq
(integer) 1
redis 127.0.0.1:6379> zadd tutoriallist 0 rabitmq
(integer) 0
redis 127.0.0.1:6379> ZRANGEBYSCORE tutoriallist 0 1000
 
1) "redis"
2) "mongodb"
3) "rabitmq"
```
 
## Redis键
 
Redis 中的 keys 命令用于管理 redis 中的键。Redis keys命令使用的语法如下所示：
 
**语法**
 
```
redis 127.0.0.1:6379> COMMAND KEY_NAME
```
 
**示例**
 
```
redis 127.0.0.1:6379> SET yiibai redis
OK
redis 127.0.0.1:6379> DEL yiibai
(integer) 1
```
 
在上面的例子中 DEL 是一个命令，而 yiibai 是一个键。如果键被成功删除，则该命令的输出将是（整数）1，否则这将是（整数）0；
 
## Redis字符串
 
Redis 的字符串命令用于管理 redis 的字符串值。Redis 的字符串命令语法的使用如下所示：
 
**语法**
 
```
redis 127.0.0.1:6379> COMMAND KEY_NAME
 
```
 
**示例**
 
```
redis 127.0.0.1:6379> SET yiibai redis
OK
redis 127.0.0.1:6379> GET yiibai
"redis"
```
 
在上面示例中 SET 和 GET 是 Redis 的命令，这里 yiibai 就是一个键（key）；
 
## Redis哈希
 
Redis哈希是字符串字段和字符串值之间的映射，所以它是用来表示对象的一个完美的数据类型，Redis 的哈希值最多可存储超过4十亿字段-值对。
 
**示例**
 
```
redis 127.0.0.1:6379> HMSET yiibai name "redis tutorial" description "redis basic commands for caching" likes 20 visitors 23000
OK
redis 127.0.0.1:6379> HGETALL yiibai
 
1) "name"
2) "redis tutorial"
3) "description"
4) "redis basic commands for caching"
5) "likes"
6) "20"
7) "visitors"
8) "23000"
```
 
在上面的例子，我们在设置一个名为 yiibai Redis的哈希的教程详细信息（name, description, likes, visitors）。
 
## Redis列表
 
Redis列表是简单的字符串列表，通过插入顺序排序。您可以在Redis 列表的头或列表尾添加元素。列表的最大长度为  232 - 1 个元素（4294967295，每个列表可有超过四十亿个元素）。
 
**示例**
 
```
redis 127.0.0.1:6379> LPUSH tutorials redis
(integer) 1
redis 127.0.0.1:6379> LPUSH tutorials mongodb
(integer) 2
redis 127.0.0.1:6379> LPUSH tutorials mysql
(integer) 3
redis 127.0.0.1:6379> LRANGE tutorials 0 10
 
1) "mysql"
2) "mongodb"
3) "redis"
```
 
在上面的例子中的三个值由命令LPUSH 插入到 redis 名称为 tutorials 的列表。
 
## Redis集合
 
Redis集合是唯一字符串的无序集合。唯一集合是不允许数据有重复的键的。在 Redis 集合中添加，删除和测试成会是否存的时间复杂度为O（1）（恒定的时间，无论集合内包含元素的数量）。集合的最大长度为   232 - 1 个元素（4294967295，每个集合中超过四十亿个元素）。
 
**示例**
 
```
redis 127.0.0.1:6379> SADD yiibai redis
(integer) 1
redis 127.0.0.1:6379> SADD yiibai mongodb
(integer) 1
redis 127.0.0.1:6379> SADD yiibai mysql
(integer) 1
redis 127.0.0.1:6379> SADD yiibai mysql
(integer) 0
redis 127.0.0.1:6379> SMEMBERS yiibai
 
1) "mysql"
2) "mongodb"
3) "redis"
```
 
在上面的例子中的三个值被 Redis 的命令SADD插入到一个名为 yiibai 集合。
 
## Redis有序集合
 
Redis的有序集合类似于 Redis 的集合，但是存储的值在集合中具有唯一性。另外有序集合的每个成员都使用分值（score）的东西，这个分值就是用于将有序集合排序，从分值最小到最大来排序。
 
在 Redis 有序集合添加，删除和测试成员的存在的时间复杂度为 O（1）（恒定时间，无论集合内包含元素的数量）。列表的最大长度为 232 - 1 个元素（4294967295，每个集合的元素超过四十亿）。 
 
**示例**
 
```
redis 127.0.0.1:6379> ZADD yiibai 1 redis
(integer) 1
redis 127.0.0.1:6379> ZADD yiibai 2 mongodb
(integer) 1
redis 127.0.0.1:6379> ZADD yiibai 3 mysql
(integer) 1
redis 127.0.0.1:6379> ZADD yiibai 3 mysql
(integer) 0
redis 127.0.0.1:6379> ZADD yiibai 4 mysql
(integer) 0
redis 127.0.0.1:6379> ZRANGE yiibai 0 10 WITHSCORES
 
1) "redis"
2) "1"
3) "mongodb"
4) "2"
5) "mysql"
6) "4"
```
 
在上面的例子中的三个值及其分值被 ZADD 命令插入一个名称为 yiibai 的 redis 有序集合中
 
## Redis HyperLogLog
 
Redis HyperLogLog 是用来做基数统计的算法，HyperLogLog 的优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定 的、并且是很小的。
 
在 Redis 里面，每个 HyperLogLog 键只需要花费 12 KB 内存，就可以计算接近 2^64 个不同元素的基 数。这和计算基数时，元素越多耗费内存就越多的集合形成鲜明对比。但是，因为 HyperLogLog 只会根据输入元素来计算基数，而不会储存输入元素本身，所以 HyperLogLog 不能像集合那样，返回输入的各个元素。
 
**示例**
 
下面的例子说明了 HyperLogLog Redis 的工作原理：
 
```
redis 127.0.0.1:6379> PFADD tutorials "redis"
 
1) (integer) 1
 
redis 127.0.0.1:6379> PFADD tutorials "mongodb"
 
1) (integer) 1
 
redis 127.0.0.1:6379> PFADD tutorials "mysql"
 
1) (integer) 1
 
redis 127.0.0.1:6379> PFCOUNT tutorials
 
(integer) 3
```
 
## Redis发布订阅
 
Redis订阅和发布实现了通讯系统，发件人（在 Redis 中的术语称为发布者）发送邮件，而接收器（订户）接收它们。信息传输的链路称为通道。Redis 一个客户端可以订阅任意数量的通道。
 
**示例**
 
以下举例说明发布订阅用户如何工作。在下面的例子给出一个客户端订阅的通道命名 redisChat 。
 
```
redis 127.0.0.1:6379> SUBSCRIBE redisChat
 
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "redisChat"
3) (integer) 1
```
 
现在，两个客户端都在同一个通道名：redisChat 上发布消息，上述订阅客户端接收消息。
 
```
redis 127.0.0.1:6379> PUBLISH redisChat "Redis is a great caching technique"
 
(integer) 1
 
redis 127.0.0.1:6379> PUBLISH redisChat "Learn redis by tutorials point"
 
(integer) 1
 
 
1) "message"
2) "redisChat"
3) "Redis is a great caching technique"
1) "message"
2) "redisChat"
3) "Learn redis by tutorials point"
```
 
## Redis事务
 
Redis事务允许一组命令在单一步骤中执行。事务有两个属性，说明如下：
 
- 在一个事务中的所有命令作为单个独立的操作顺序执行。在Redis事务中的执行过程中而另一客户机发出的请求，这是不可以的；
- Redis事务是原子的。原子意味着要么所有的命令都执行，要么都不执行；
 
**示例**
 
Redis 事务由指令 MULTI 发起的，之后传递需要在事务中和整个事务中，最后由 EXEC 命令执行所有命令的列表。
 
```
redis 127.0.0.1:6379> MULTI
OK
List of commands here
redis 127.0.0.1:6379> EXEC
```
 
**示例**
 
下面的例子说明了 Redis 的事务是如何开始和执行。
 
```
redis 127.0.0.1:6379> MULTI
OK
redis 127.0.0.1:6379> SET tutorial redis
QUEUED
redis 127.0.0.1:6379> GET tutorial
QUEUED
redis 127.0.0.1:6379> INCR visitors
QUEUED
redis 127.0.0.1:6379> EXEC
 
1) OK
2) "redis"
3) (integer) 1
```
 
## Redis脚本
 
Redis 脚本是使用Lua解释脚本用来评估（计算）。从 Redis 2.6.0 版本开始内置这个解释器。命令 EVAL 用于执行 脚本命令。
 
**语法**
 
EVAL命令的基本语法如下：
 
```
redis 127.0.0.1:6379> EVAL script numkeys key [key ...] arg [arg ...]
```
 
**示例**
 
下面的例子说明了 Redis 脚本是如何工作的：
 
```
redis 127.0.0.1:6379> EVAL "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 key1 key2 first second
 
1) "key1"
2) "key2"
3) "first"
4) "second"
```
 
## Redis连接
 
Redis 的连接命令基本上都用于管理 Redis服务器与客户端连接。
 
**示例**
 
下面的例子说明了一个客户端在Redis服务器上，如何检查服务器是否正在运行并验证自己。
 
```
redis 127.0.0.1:6379> AUTH "password"
OK
redis 127.0.0.1:6379> PING
PONG
```
 
## Redis备份
 
Redis的SAVE命令用于创建当前 Redis 数据库的备份。
 
**语法**
 
Redis 的 SAVE 命令的基本语法如下所示：
 
```
127.0.0.1:6379> SAVE
```
 
**示例**
 
以下示例显示了如何在Redis的当前数据库中创建备份。
 
```
127.0.0.1:6379> SAVE
 
OK
```
 
在执行此命令之后，将在 redis 目录中创建一个 dump.rdb 文件。
 
## 恢复 Redis 数据
 
要恢复 redis 数据只需要要将 Redis 的备份文件（dump.rdb）放到 Redis 的目录中，并启动服务器。要了解知道 Redis 目录在什么位置，可使用 CONFIG 命令，如下所示：
 
```
127.0.0.1:6379> CONFIG get dir
 
1) "dir"
2) "/user/yiibai/redis-2.8.13/src"
```
 
在上面的命令命令输出为 /user/yiibai/redis-2.8.13/src 就是使用的 Redis 目录，也就是 Redis 的服务器安装的目录。
 
## Bgsave
 
创建 Redis 的备份也可以使用备用命令 BGSAVE 。此命令将启动备份过程，并在后台运行此。
 
**示例**
 
```
127.0.0.1:6379> BGSAVE
 
Background saving started
```
 
## Redis安全
 
Redis 数据库可以配置安全保护的，所以任何客户端在连接执行命令时需要进行身份验证。为了确保 Redis 的安全，需要在配置文件设置密码。
 
**示例**
 
下面给出的例子显示的步骤是用来确保 Redis 实例的安全。
 
```
127.0.0.1:6379> CONFIG get requirepass
1) "requirepass"
2) ""
```
 
默认情况下此属性是空的，这意味着此实例没有设置密码。可以通过执行以下命令来修改设置此属性
 
```
127.0.0.1:6379> CONFIG set requirepass "yiibaipass"
OK
127.0.0.1:6379> CONFIG get requirepass
1) "requirepass"
2) "yiibaipass"
```
 
如果客户端运行命令无需验证设置密码，那么（错误）NOAUTH 需要验证。错误将返回。因此，客户端需要使用 AUTH 命令来验证自己的身份信息。
 
**语法**
 
AUTH命令的基本语法如下所示：
 
```
127.0.0.1:6379> AUTH password
```
 
## Redis性能测试
 
Redis的基准性能测试是通过同时运行 N 个命令以检查 Redis 性能的工具。
 
**语法**
 
Redis的基准测试的基本语法如下所示：
 
```
redis-benchmark [option] [option value]
```
 
**示例**
 
下面给出的示例是通过调用 100000 个（次）命令来检查 Redis。
 
```
redis-benchmark -n 100000
 
PING_INLINE: 141043.72 requests per second
PING_BULK: 142857.14 requests per second
SET: 141442.72 requests per second
GET: 145348.83 requests per second
INCR: 137362.64 requests per second
LPUSH: 145348.83 requests per second
LPOP: 146198.83 requests per second
SADD: 146198.83 requests per second
SPOP: 149253.73 requests per second
LPUSH (needed to benchmark LRANGE): 148588.42 requests per second
LRANGE_100 (first 100 elements): 58411.21 requests per second
LRANGE_300 (first 300 elements): 21195.42 requests per second
LRANGE_500 (first 450 elements): 14539.11 requests per second
LRANGE_600 (first 600 elements): 10504.20 requests per second
MSET (10 keys): 93283.58 requests per second
```
 
## Redis客户端连接
 
如果启用了Redis 的接受配置监听，客户端可在TCP端口上与Unix套接字连接。以下操作执行后新的客户端连接被服务器接受：
 
- 客户端套接字在非阻塞状态，因为 Redis 使用复用和非阻塞I/O；
- TCP_NODELAY选项设定以确保不会在连接时延迟；
- 创建一个可读的文件事件，以便 Redis 能够尽快收集客户端查询作为新的数据可被套接字读取；
 
### 客户端最大连接数量
 
在Redis的配置文件（redis.conf）有一个属性 maxclients ，它描述了可以连接到 Redis 的客户的最大数量。命令的基本语法是：
 
```
config get maxclients
 
1) "maxclients"
2) "10000"
```
 
默认情况下此属性设置为 10000（取决于OS的文件标识符限制最大数量），但可以修改这个属性。
 
**示例**
 
在下面给出的例子我们已经设置客户端最大连接数量为 100000，在之后启动服务器：
 
```
redis-server --maxclients 100000
```
 
## Redis管道
 
Redis是一个TCP服务器，支持请求/响应协议。在 redis 中一个请求完成以下步骤：
 
- 客户端发送一个查询给服务器，并从套接字中读取，通常服务器的响应是在一个封闭的方式；
- 服务器处理命令并将响应返回给客户端；
 
### 管道的含义
 
管道的基本含义是：客户端可以发送多个请求给服务器，而不等待全部响应，最后在单个步骤中读取所有响应。
 
**示例**
 
要检查 Redis 管道只需要启动 Redis 实例，并在终端输入以下命令。
 
```
$(echo -en "PING\r\n SET tutorial redis\r\nGET tutorial\r\nINCR visitor\r\nINCR visitor\r\nINCR visitor\r\n"; sleep 10) | nc localhost 6379
 
+PONG
+OK
redis
:1
:2
:3
```
 
在上面的例子所示，了解使用 PING 命令连接 Redis，之后我们在 Redis 设定一个名为 tutorial 字符串值，之后拿到这个键对应的值并增加访问人数的三倍。在结果中，我们可以看到所有的命令都提交给 Redis 一次，Redis是给单步输出所有命令。
 
### 通道的好处
 
这种技术的好处是显着提高协议的性能。管道localhost 获得至少达到百倍的网络连接速度。
 
## Redis分区
 
分区是将数据分割成多个 Redis 实例，使每个实例将只包含键子集的过程。
 
### 分区的好处
 
- 它允许更大的数据库，使用多台计算机的内存总和。如果不分区，只是一台计算机有限的内存可以支持的数据存储；
- 它允许按比例在多内核和多个计算机计算，以及网络带宽向多台计算机和网络适配器；
 
### 分区的劣势
 
- 涉及多个键的操作通常不支持。例如，如果它们被存储在被映射到不同的 Redis 实例键，则不能在两个集合之间执行交集；
- 涉及多个键时，Redis事务无法使用；
- 分区粒度是一个键，所以它不可能使用一个键和一个非常大的有序集合分享一个数据集；
- 当使用分区，数据处理比较复杂，比如要处理多个RDB/AOF文件，使数据备份需要从多个实例和主机聚集持久性文件；
- 添加和删除的容量可能会很复杂。例如：Redis的Cluster支持数据在运行时添加和删除节点是透明平衡的，但其他系统，如客户端的分区和代理服务器不支持此功能
 
### 分区类型
 
Redis 提供有两种类型的分区。假设我们有四个 redis 实例：R0，R1，R2，R3，分别表示用户用户如：user:1, user:2, ...等等
 
### 范围分区
 
范围分区被映射对象指定 Redis 实例在一个范围内完成。
 
在我们的例子中，用户从ID为 0 至 ID10000 将进入实例 R0，而用户 ID 10001到ID 20000 将进入实例 R1 等等。
 
### 散列分区
 
在这种类型的分区是一个散列函数（例如，模数函数）用于将键转换为数字数据，然后存储在不同的 redis 实例。