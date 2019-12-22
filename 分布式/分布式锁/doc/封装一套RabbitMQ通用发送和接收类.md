### **一、 发送消息类**

```
/**
 * 消息发送封装类
 * 
 * 需要发送消息的模块注入这个类就可以实现消息发送,推荐使用直接发送Bean的方式发送mq消息
 */
@Component
@EnableAsync
public class RabbitMqMessageSender {
 
    private static Logger logger = LoggerFactory.getLogger(RabbitMqMessageSender.class);
 
    @Autowired
    private ConnectionFactory connectFactory;
 
    private Connection connection;
 
    @PostConstruct
    public void postConstruct() throws Exception {
        connection = connectFactory.newConnection();
    }
 
    /**
     * 发送消息方法主体，默认异步发送消息
     *
     * @param objectJson
     * @return
     */
    @Async
    public void send(String taskQueueName, String objectJson) {
 
        Channel channel = null;
        try {
            channel = connection.createChannel();
            channel.queueDeclare(taskQueueName, true, false, false, null);
            channel.basicPublish("", taskQueueName, MessageProperties.PERSISTENT_TEXT_PLAIN, SafeEncoder.encode(objectJson));
        } catch (Exception e) {
            logger.error("消息发送失败", e);
        } finally {
            closeChannel(channel);
        }
    }
 
    @Async
    public Object sendDelayMessage(String taskQueueName, String objectJson, long delayTimeInSecond) {
        Channel channel = null;
        try{
            channel = connection.createChannel();
            byte[] messageBodyBytes = objectJson.getBytes("UTF-8");
            Map<String, Object> headers = new HashMap<String, Object>();
            headers.put("x-delay", 1000 * delayTimeInSecond);
            AMQP.BasicProperties.Builder props = new AMQP.BasicProperties.Builder().headers(headers);
            channel.queueDeclare(taskQueueName, true, false, false, null);
            channel.basicPublish(RabbitMqConstant.DELAY_EXCHANGE_NAME, taskQueueName, props.build(), messageBodyBytes);
        }catch (Exception e){
            logger.error("消息发送失败", e);
        } finally {
            closeChannel(channel);
        }
        return null;
    }
 
    private void closeChannel(Channel channel) {
 
        if (channel != null) {
            try {
                channel.close();
            } catch (Exception e) {
                logger.error("关闭channel失败", e);
            }
        }
    }
 
    /**
     * 发送消息方法，可以直接传Bean
     *
     * @param taskQueueName
     * @param data
     * @param <T>
     * @return
     */
    public <T> void send(String taskQueueName, T data) {
        String objectJson = "";
        //如果是基本类型，直接处理
        if (data.getClass().isPrimitive()) {
            objectJson = data.toString();
            send(taskQueueName, objectJson);
        } else {
            try {
                objectJson = JsonHelper.OM.writeValueAsString(data);
                send(taskQueueName, objectJson);
            } catch (JsonProcessingException e) {
                logger.error("对象转json失败", e);
            }
        }
    }
 
    /**
     * 发送延迟消息方法，可以直接传Bean
     *
     * @param data
     * @param <T>
     * @return
     */
    public <T> void sendDelayMessage(String routingKey,  T data, long delayTimeInSecond) {
        logger.info("TraceId_Elisa_rabbitMQ queueName {} uid {} delayTimeInSecond {}",routingKey, JSON.toJSONString(data),delayTimeInSecond);
        String objectJson = "";
        //如果是基本类型，直接处理
        if (data.getClass().isPrimitive()) {
            objectJson = data.toString();
            sendDelayMessage(routingKey,objectJson, delayTimeInSecond);
        } else {
            try {
                objectJson = JsonHelper.OM.writeValueAsString(data);
                sendDelayMessage(routingKey,objectJson, delayTimeInSecond);
            } catch (JsonProcessingException e) {
                logger.error("对象转json失败", e);
            }
        }
    }
}
```

### **二、消息接收类**

```
/**
 * MQ消费者注册中心
 */
@Component
public class MqConsumerRegister {
 
	private static Logger logger = LoggerFactory.getLogger(MqConsumerRegister.class);
 
	@Autowired
	private ConnectionFactory connectFactory;
 
	private Connection connection;
 
	private ExecutorService es = newFixedThreadPoolWithQueueSize(32, 1024);
 
	@PostConstruct
	public void init() throws Exception {
		connection = connectFactory.newConnection();
 
	}
 
	public void addNormalCounsumer(String taskName, MessageHandler handler, boolean isAutoAck, int qos) {
		try {
			Channel channel = connection.createChannel();
			channel.queueDeclare(taskName, true, false, false, null);
 
			channel.basicQos(qos);
			Consumer consumer = new DefaultConsumer(channel) {
				@Override
				public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties,
						byte[] body) throws IOException {
					String message = new String(body, "UTF-8");
					try {
						handler.handle(this.getChannel(), message, envelope.getDeliveryTag(), isAutoAck);
					} catch (RejectedExecutionException e) {
						if (!isAutoAck) {
							channel.basicReject(envelope.getDeliveryTag(), true);
						}
						logger.info("Mq message handle queue full");
					} catch (Exception e) {
						logger.error("mq consume message error", e);
					}
				}
 
				@Override
				public void handleShutdownSignal(String consumerTag, ShutdownSignalException sig) {
					logger.error("consumer:" + consumerTag + "被关闭", sig);
				}
			};
			channel.basicConsume(taskName, isAutoAck, consumer);
		} catch (Exception e) {
			logger.error("mq consumer registe error", e);
		} finally {
 
		}
	}
 
	public void addDelayConsumer(String doneQueueName, String routingkey, MessageHandler handler, boolean autoAck,
			int qos) {
		try {
			// 声明延迟队列的exchange
			Channel channel = connection.createChannel();
			Map<String, Object> args = new HashMap<String, Object>();
			args.put("x-delayed-type", "direct");
			channel.exchangeDeclare(RabbitMqConstant.DELAY_EXCHANGE_NAME, "x-delayed-message", true, false, args);
			// 声明队列
			channel.queueDeclare(doneQueueName, true, false, false, null);
			// 绑定队列
			channel.queueBind(doneQueueName, RabbitMqConstant.DELAY_EXCHANGE_NAME, doneQueueName);
			channel.basicQos(qos);
			Consumer consumer = new DefaultConsumer(channel) {
				@Override
				public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties,
						byte[] body) throws IOException {
					String message = new String(body, "UTF-8");
					try {
						handler.handle(this.getChannel(), message, envelope.getDeliveryTag(), autoAck);
					} catch (RejectedExecutionException e) {
						if (!autoAck) {
							// 只有没有开启ack时，才能重新入队列
							channel.basicReject(envelope.getDeliveryTag(), true);
						}
						logger.info("Mq delay message handle queue full");
					} catch (Exception e) {
						logger.error("mq consumer message error", e);
					}
				}
 
				@Override
				public void handleShutdownSignal(String consumerTag, ShutdownSignalException sig) {
					logger.error("consumer:" + consumerTag + "被关闭", sig);
				}
 
			};
			channel.basicConsume(doneQueueName, autoAck, consumer);
		} catch (Exception e) {
			logger.error("mq consumer register error", e);
		}
	}
 
	/**
	 * 队列满了后
	 *
	 * @param task
	 */
	public void submitTask(Runnable task) {
		RejectedExecutionException ex = null;
		for (int i = 0; i < 2; i++) {
			try {
				es.submit(task);
				return;
			} catch (RejectedExecutionException e) {
				ex = e;
				SleepHepler.sleep(50, TimeUnit.MILLISECONDS);
			}
		}
		throw ex;
	}
 
	public static ExecutorService newFixedThreadPoolWithQueueSize(int poolSize, int queueLen) {
		return new ThreadPoolExecutor(poolSize, poolSize, 0L, TimeUnit.MILLISECONDS,
				new LinkedBlockingQueue<Runnable>(queueLen));
	}
 
	public void requeue(Channel channel, long deliveryTag) {
		try {
			channel.basicReject(deliveryTag, true);
		} catch (IOException e1) {
			logger.error("消息重新排队失败", e1);
		}
	}
 
	public static interface MessageHandler {
 
		void handle(Channel channel, String message, long deliveryTag, boolean autoAck);
	}
 
}
```



```
/**
 * RabbitMQ 消息接收类，定义了除业务逻辑之外的消息处理逻辑
 * 
 * 每个消息接收者接收一个queue的消息
 * 
 * 通过构造函数传入taskQueueName，handler的不同： 不同的消息可以有不同的处理业务逻辑； 同一种消息也可以有不同的处理业务逻辑；
 *
 */
public class RabbitMqMessageReceiver {
 
	private static Logger logger = LoggerFactory.getLogger(RabbitMqMessageReceiver.class);
 
	private MqConsumerRegister register;
 
	/**
	 * 队列名称
	 */
	private String taskQueueName;
 
	/**
	 * 消息处理机，只有handleBiz方法
	 */
	private BizHandleable handler;
 
	public RabbitMqMessageReceiver(MqConsumerRegister register, String taskQueueName, BizHandleable handler) {
		this.register = register;
		this.taskQueueName = taskQueueName;
		this.handler = handler;
	}
 
	/**
	 * 正常接收这个队列的消息
	 */
	public void normalReceive() {
		normalReceive(RabbitMqConstant.COMMON_QOS);
	}
 
	/**
	 * 正常接收这个队列的消息
	 *
	 * @param qos
	 *            除对时效要求紧急且为小任务，其他情况请勿将qos设置为0
	 */
	public void normalReceive(int qos) {
		register.addNormalCounsumer(taskQueueName, new RabbitMessageHandler(), false, qos);
	}
 
	/**
	 * 正常接收这个队列的消息
	 */
	public void normalReceiveAutoAck() {
		normalReceiveAutoAck(RabbitMqConstant.COMMON_QOS);
	}
 
	/**
	 * 正常接收这个队列的消息
	 *
	 * @param qos
	 *            除对时效要求紧急且为小任务，其他情况请勿将qos设置为0
	 */
	public void normalReceiveAutoAck(int qos) {
		register.addNormalCounsumer(taskQueueName, new RabbitMessageHandler(), true, qos);
	}
 
	/**
	 * 延迟接收这个队列的消息
	 * <p>
	 * 如果autoAck为true，说明这个消息会自动确认（handle方法的true和false无效），如果需要重试，则需要在代码中执行消息的重试逻辑（重新发送消息等）
	 * <p>
	 * 如果autoAck为false，说明这个消息由业务代码确认，就是handle方法的true或false确认
	 * <p>
	 * 除对时效要求紧急且为小任务，其他情况请勿将qos设置为0
	 */
	public void delayReceive(boolean autoAck, int qos) {
		register.addDelayConsumer(taskQueueName, "", new RabbitMessageHandler(), autoAck, qos);
	}
 
	public class RabbitMessageHandler implements MqConsumerRegister.MessageHandler {
		@Override
		public void handle(final Channel channel, final String message, long deliveryTag, boolean autoAck) {
			register.submitTask(() -> {
				logger.info("Received[{}]:{}", deliveryTag, message);
				try {
					// 处理消息并获取消息处理结果，true表示处理成功，false表示处理失败
					boolean isMessageHandled = handler.handleBiz(message);
					// 如果是自动应答的，不需要进行手动ack，这样会导致消息丢失
					if (!autoAck) {
						// 消息处理成功，进行处理成功后的流程
						if (isMessageHandled) {
							channel.basicAck(deliveryTag, false);
							logger.info("Handle finished[{}]", deliveryTag);
							// 判断是否需要重试
						} else {
							// 消息处理失败，进行处理失败后的流程
							register.requeue(channel, deliveryTag);
							logger.info("消息消费失败，等待自动超时后处理");
						}
					}
				} catch (Exception e) {
					logger.error("消息处理失败", e);
					// 若处理消息中产生了异常，这里采用保守方式，走消息处理失败流程
					if (!autoAck) {
						//只有没有开启ack的,才能重新入队
						register.requeue(channel, deliveryTag);
					}
				}
			});
		}
	}
}
```



```
/**
 * 消息处理接口类,用于业务代码和相关MQ操作解耦
 * 每个消息都有对应不同的handle实现，因此抽象出这个接口
 *
 * handle只写业务方法
 *
 */
public interface BizHandleable {
 
    /**
     * 这里写业务处理逻辑
     * @param message 消息内容
     * @return 若声明消费者时关闭autoAck：返回true表示消息成功消费，返回false表示消息处理失败，会自动重新排队重试
     *          若声明消费者时开启autoAck，所有消息都会自动确认，这个返回值无效
     */
    boolean handleBiz(String message);
 
}
```

### **三、例子**

```
一、发送mq消息：
 
  rabbitMqMessageSender.send(paymentSuccessQueueName, bigOrderId);
 
二、接收mq消息：
 
/**
 * 付款成功通知信息
 */
@Component
public class PaymentSuccessConsumer implements ApplicationListener<ContextRefreshedEvent> {
 
    @Resource
    private BizHandleable paymentSuccessHandler;
 
    @Resource
    private MqConsumerRegister register;
 
    @Value("${payment.paymentSuccessQueueName}")
    private String queueName;
 
    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
            new RabbitMqMessageReceiver(register, queueName, paymentSuccessHandler).delayReceive(false, 30);
    }
}
 
 
 
@Component
public class PaymentSuccessHandler implements BizHandleable {
 
    private static final Logger logger = LoggerFactory.getLogger(PaymentSuccessHandler.class);
 
 
 
    @Override
    public boolean handleBiz(String message) {
        logger.info("接收到支付成功消息，消息内容:{}",message);     
        try {
              
         // 这里处理具体业务
   
        } catch (Exception e) {
            logger.info("消息处理失败", e);
            return true;
        }
    }
```

