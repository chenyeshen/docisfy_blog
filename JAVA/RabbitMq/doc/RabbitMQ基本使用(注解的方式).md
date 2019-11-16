# **RabbitMQ 基本使用（注解的方式）**

> RabbitMQ 可以采用基于注解的方式来创建队列，如下：

### **1. 手动在 RabbitMQ 管理界面创建 myQueue队列**

```
    1. 发送者代码：

```

```
 @Autowired
    private AmqpTemplate amqpTemplate;

    public void send(){
        String msg = "mqsender send ..." + new Date();
        amqpTemplate.convertAndSend("myQueue", msg);
    }

```

```
     2. 接收者代码

```

```
    /** * 需要手动在39...50:15672/ 下的RabbitMQ management 界面下创建一个队列 myQueue * @param msg */
    @RabbitListener(queues = "myQueue")
    public void receive(String msg){
        log.info("mqReceive = {}" , msg );
    }
```

### **2. 通过注解自动创建 myQueue 队列**

```
    1. 发送方程序和上面一样

    2. 接收方程序如下：

```

```
    /** * * @param msg */
    @RabbitListener(queuesToDeclare = @Queue("myQueue"))
    public void receive(String msg){
        log.info("mqReceive = {}" , msg );
    }
```

### **3. 自动创建，queue 和 exchange 绑定**

```
     1. 发送方程序不变

     2. 接收方程序如下：

```

```
     // 3. 自动创建，queue 和 exchange 绑定
    @RabbitListener(bindings = @QueueBinding(
            value = @Queue("myQueue"),
            exchange = @Exchange("myExchange")
    ))
    public void receive(String msg){
        log.info("mqReceive = {}" , msg );
    }
```

### **4. 实战模拟消息分组**

```
    1. 发送方：

```

```
    /** * 模拟消息分组 发送方 */
    public void sendOrder(){
        String msg = "mqsender send ..." + new Date();
        // 参数：交换机，路由key, 消息
        amqpTemplate.convertAndSend("myOrder","computer", msg);
    }

```

```
    2. 接收方：

```

```
/**----------- 模拟消息分组 --------------------*/
    /** * 数码供应商服务 接收消息 * 消息发到交换机，交换机根据不同的key 发送到不同的队列 */
    @RabbitListener(bindings = @QueueBinding(
            exchange = @Exchange("myOrder"),
            key = "computer",
            value = @Queue("computerOrder")
    ))
    public void receiveComputer(String msg){
        log.info(" receiveComputer service = {}" , msg );
    }
    /** * 水果供应商服务 接收消息 */
    @RabbitListener(bindings = @QueueBinding(
            value = @Queue("fruitOrder"),
            key = "fruit",
            exchange = @Exchange("myOrder")
    ))
    public void receiveFruit(String msg){
        log.info(" receiveFruit service = {}" , msg );
    }
```

```
    3. 测试用例

    @Autowired
    private MQSender sender;

    @Test
    public void sendOrderTest() {
        sender.sendOrder();
    }
    4. 结果： 
    消息发送到交换机，交换机通过路由key 发送到对应的队列。
    因此computerOrder队列得到了消息，进而receiveComputer()接收到了消息。
```