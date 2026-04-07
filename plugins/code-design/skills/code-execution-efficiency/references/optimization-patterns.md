# 优化模式速查

常见性能问题的优化方案，**必须贴合当前项目技术栈**。

---

## 核心原则

### 1. 优先级排序

```
P0 立即修复: 影响用户、可能故障的问题
P1 尽快修复: 显著影响体验的问题
P2 后续优化: 可以改进但非紧急
```

### 2. 方案选择顺序

```
1. 用现有能力（优先）
   - 优先用项目已有组件解决
   - 改动小、风险低、见效快

2. 改配置/参数
   - 连接池、超时、线程数等
   - 无需改代码

3. 改代码逻辑
   - 优化算法、减少调用、并行化
   - 需要测试验证

4. 引入新组件（谨慎）
   - 最后选择，评估 ROI
   - 考虑维护成本
```

### 3. 方案输出格式

```markdown
## 优化方案：[问题名称]

### 问题描述
[位置] [现象] [影响]

### 根因
[为什么会出现这个问题]

### 方案一（推荐）
**改动**：
[具体代码改动，针对当前项目]

**预期收益**：
[量化的收益，如"减少 80% 耗时"]

**成本**：
[改动量、风险、测试范围]

**风险**：
[可能的问题和应对]

### 方案二（备选）
[同上格式]

### 验证方法
1. [如何验证效果]
2. [监控指标]
```

---

## SQL 优化

### 全表扫描 → 加索引

**问题**：`EXPLAIN` 显示 `type=ALL`

**分析**：
```sql
-- 检查执行计划
EXPLAIN SELECT * FROM orders WHERE user_id = 123;
-- type: ALL, key: NULL → 全表扫描
```

**方案**：
```sql
-- 添加索引
CREATE INDEX idx_user_id ON orders(user_id);

-- 复合索引（多条件查询）
CREATE INDEX idx_user_status ON orders(user_id, status);

-- 覆盖索引（避免回表）
CREATE INDEX idx_user_status_amount ON orders(user_id, status, amount);
```

**贴合技术栈**：
- MyBatis: 检查 XML 中是否有函数导致索引失效
- JPA: 检查 `@Query` 注解

### 索引失效 → 改写 SQL

**问题**：有索引但未使用

**常见原因**：
```sql
-- ❌ 使用函数
SELECT * FROM orders WHERE DATE(create_time) = '2024-01-01';

-- ✅ 改写
SELECT * FROM orders 
WHERE create_time >= '2024-01-01' AND create_time < '2024-01-02';

-- ❌ 隐式转换
SELECT * FROM orders WHERE user_id = '123';  -- user_id 是 int

-- ✅ 改写
SELECT * FROM orders WHERE user_id = 123;

-- ❌ 前缀模糊
SELECT * FROM orders WHERE order_no LIKE '%123';

-- ✅ 后缀模糊（走索引）
SELECT * FROM orders WHERE order_no LIKE 'ORD%';
```

### N+1 问题 → 批量查询

**问题**：循环中查询数据库

**改前**：
```java
// OrderService.java:67
for (Order order : orders) {
    OrderDetail detail = orderDetailDao.selectByOrderId(order.getId());
    order.setDetail(detail);
}
```

**改后**：
```java
// 批量查询
List<Long> ids = orders.stream()
    .map(Order::getId)
    .collect(Collectors.toList());

Map<Long, OrderDetail> detailMap = orderDetailDao.batchSelectByOrderIds(ids);

for (Order order : orders) {
    order.setDetail(detailMap.get(order.getId()));
}
```

**贴合技术栈**：
```xml
<!-- MyBatis: IN 查询 -->
<select id="batchSelectByOrderIds" resultType="OrderDetail">
    SELECT * FROM order_detail 
    WHERE order_id IN 
    <foreach collection="ids" item="id" open="(" separator="," close=")">
        #{id}
    </foreach>
</select>
```

### 大 OFFSET → 游标分页

**问题**：`LIMIT 10000, 10`

**改前**：
```sql
SELECT * FROM orders ORDER BY id LIMIT 10000, 10;
-- 需要扫描 10010 行
```

**改后**：
```sql
-- 记录上一页最后一条的 id
SELECT * FROM orders WHERE id > 10000 ORDER BY id LIMIT 10;
-- 只扫描 10 行
```

### 长事务 → 缩小范围

**问题**：事务包含不需要事务的操作

**改前**：
```java
@Transactional
public void createOrder(OrderDTO dto) {
    // 1. 保存订单 (需要事务)
    orderDao.insert(order);
    
    // 2. 调用外部支付 (不需要事务)
    paymentService.pay(payRequest);  // 可能很慢
    
    // 3. 发送通知 (不需要事务)
    notificationService.send(msg);  // 可能失败
}
```

**改后**：
```java
public void createOrder(OrderDTO dto) {
    // 1. 保存订单 (事务)
    Long orderId = saveOrder(order);
    
    // 2. 异步支付 (事务外)
    CompletableFuture.runAsync(() -> {
        paymentService.pay(payRequest);
    });
    
    // 3. 异步通知 (事务外)
    eventPublisher.publish(new OrderCreatedEvent(orderId));
}

@Transactional
public Long saveOrder(Order order) {
    orderDao.insert(order);
    return order.getId();
}
```

---

## 缓存优化

### 缓存穿透 → 空值缓存

**问题**：查询不存在的数据，绕过缓存直接打 DB

**方案**：
```java
public User getUser(Long id) {
    String key = "user:" + id;
    User user = redis.get(key);
    
    if (user != null) {
        return user;
    }
    
    user = userDao.selectById(id);
    
    if (user != null) {
        redis.set(key, user, 3600);
    } else {
        // 空值缓存，短过期
        redis.set(key, "NULL", 60);
    }
    
    return user;
}
```

### 缓存击穿 → 分布式锁

**问题**：热点 key 过期，大量请求同时重建

**方案**：
```java
public User getUser(Long id) {
    String key = "user:" + id;
    User user = redis.get(key);
    
    if (user != null) {
        return user;
    }
    
    // 分布式锁，防止并发重建
    String lockKey = "lock:user:" + id;
    boolean locked = redis.setNx(lockKey, "1", 10);
    
    if (locked) {
        try {
            user = userDao.selectById(id);
            redis.set(key, user, 3600);
        } finally {
            redis.del(lockKey);
        }
    } else {
        // 等待重试
        Thread.sleep(100);
        return getUser(id);
    }
    
    return user;
}
```

**贴合技术栈**：
```java
// Spring Boot + Redisson
@Autowired
private RedissonClient redisson;

public User getUser(Long id) {
    RLock lock = redisson.getLock("lock:user:" + id);
    try {
        lock.lock(10, TimeUnit.SECONDS);
        // ...
    } finally {
        lock.unlock();
    }
}
```

### 缓存雪崩 → 过期时间随机

**问题**：大量 key 同时过期

**方案**：
```java
// 过期时间加随机值
int baseExpire = 3600;
int randomExpire = ThreadLocalRandom.current().nextInt(600);
redis.set(key, user, baseExpire + randomExpire);
```

### 大 Key → 拆分

**问题**：单个 value 过大（>10KB）

**方案**：
```java
// ❌ 大 Hash
redis.hset("user:detail:123", "profile", largeJson);
redis.hset("user:detail:123", "settings", largeJson2);

// ✅ 拆分
redis.set("user:profile:123", profileJson);
redis.set("user:settings:123", settingsJson);
```

---

## 并发优化

### 串行 → 并行

**问题**：多个独立操作串行执行

**改前**：
```java
public OrderVO getOrderVO(Long orderId) {
    Order order = orderService.getOrder(orderId);      // 100ms
    User user = userService.getUser(order.getUserId()); // 50ms
    List<Item> items = itemService.getItems(orderId);   // 80ms
    // 总计: 230ms
}
```

**改后**：
```java
// Spring Boot + CompletableFuture
public OrderVO getOrderVO(Long orderId) {
    CompletableFuture<Order> orderFuture = CompletableFuture.supplyAsync(
        () -> orderService.getOrder(orderId));
    
    CompletableFuture<User> userFuture = orderFuture.thenApplyAsync(
        order -> userService.getUser(order.getUserId()));
    
    CompletableFuture<List<Item>> itemsFuture = CompletableFuture.supplyAsync(
        () -> itemService.getItems(orderId));
    
    CompletableFuture.allOf(userFuture, itemsFuture).join();
    
    // 总计: max(100, 50, 80) = 100ms
}
```

**贴合技术栈**：
```java
// 配置异步线程池
@Configuration
public class AsyncConfig {
    @Bean
    public Executor asyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(50);
        executor.setQueueCapacity(100);
        return executor;
    }
}
```

### 锁粒度过粗 → 细化

**问题**：大范围加锁

**改前**：
```java
public void process() {
    synchronized (this) {
        // 操作 A (快)
        doA();
        // 操作 B (慢)
        doB();
        // 操作 C (快)
        doC();
    }
}
```

**改后**：
```java
public void process() {
    doA();  // 无需锁
    
    synchronized (this) {
        doB();  // 只锁必要的
    }
    
    doC();  // 无需锁
}
```

### 连接池不足 → 调整配置

**问题**：连接池耗尽

**方案**：
```yaml
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 50      # 增大
      minimum-idle: 10
      connection-timeout: 30000  # 获取超时
      idle-timeout: 600000
      max-lifetime: 1800000
      
  redis:
    lettuce:
      pool:
        max-active: 50           # 增大
        max-idle: 20
        min-idle: 10
```

**计算公式**：
```
连接数 = (核心数 * 2) + 有效磁盘数
         或
连接数 = 并发峰值 * 平均查询时间 (秒)

示例: 200 QPS * 0.02s = 4 个连接 (理论最小)
实际建议: 留有余量，设为 20-50
```

---

## 外部调用优化

### 无超时 → 配置超时

**问题**：调用无 timeout 配置

**方案**：
```yaml
# Feign
feign:
  client:
    config:
      default:
        connectTimeout: 3000
        readTimeout: 5000
        
# Dubbo
dubbo:
  consumer:
    timeout: 5000
    
# RestTemplate
RestTemplate restTemplate = new RestTemplate();
restTemplate.setRequestFactory(
    new SimpleClientHttpRequestFactory() {{
        setConnectTimeout(3000);
        setReadTimeout(5000);
    }});
```

### 同步调用 → 异步调用

**问题**：可异步的同步调用

**改前**：
```java
public void createOrder(OrderDTO dto) {
    orderDao.insert(order);
    // 同步等待通知完成
    notificationService.send(msg);  // 100ms
}
```

**改后**：
```java
// 方式1: 线程池异步
@Autowired
private AsyncTaskExecutor asyncExecutor;

public void createOrder(OrderDTO dto) {
    orderDao.insert(order);
    asyncExecutor.execute(() -> notificationService.send(msg));
}

// 方式2: 消息队列
@Autowired
private RocketMQTemplate rocketMQTemplate;

public void createOrder(OrderDTO dto) {
    orderDao.insert(order);
    rocketMQTemplate.asyncSend("notification", msg, new SendCallback() {
        @Override
        public void onSuccess(SendResult result) {}
        @Override
        public void onException(Throwable e) {}
    });
}
```

### 无熔断 → 加熔断

**问题**：下游故障时持续调用

**方案**：
```java
// Resilience4j
@CircuitBreaker(name = "payment", fallbackMethod = "fallback")
public PaymentResult pay(PaymentRequest request) {
    return paymentClient.pay(request);
}

public PaymentResult fallback(PaymentRequest request, Throwable t) {
    // 降级处理
    return PaymentResult.pending();
}
```

**配置**：
```yaml
resilience4j:
  circuitbreaker:
    instances:
      payment:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 10s
```

---

## 内存优化

### 大对象 → 流式处理

**问题**：一次性加载大量数据到内存

**改前**：
```java
List<Order> orders = orderDao.selectAll();  // 可能有百万条
for (Order order : orders) {
    process(order);
}
```

**改后**：
```java
// MyBatis 流式查询
@Select("SELECT * FROM orders")
@Options(resultSetType = ResultSetType.FORWARD_ONLY, fetchSize = 1000)
@ResultType(Order.class)
void selectAll(ResultHandler<Order> handler);

// 使用
orderDao.selectAll(context -> {
    Order order = context.getResultObject();
    process(order);
});
```

### 频繁 GC → 对象复用

**问题**：频繁创建销毁对象

**方案**：
```java
// 使用对象池
private final ObjectPool<ExpensiveObject> pool = new GenericObjectPool<>(
    new ExpensiveObjectFactory());

public void process() {
    ExpensiveObject obj = null;
    try {
        obj = pool.borrowObject();
        obj.doSomething();
    } finally {
        if (obj != null) {
            pool.returnObject(obj);
        }
    }
}
```

---

## 验证方法

### 压测验证

```bash
# JMeter / ab / wrk
ab -n 10000 -c 100 http://localhost:8080/api/order/123

# 对比优化前后
# 优化前: 500ms p99
# 优化后: 100ms p99
```

### 监控指标

```markdown
优化前后对比：

| 指标 | 优化前 | 优化后 | 改善 |
|-----|--------|--------|------|
| P99 响应时间 | 500ms | 100ms | 80% |
| QPS | 100 | 500 | 400% |
| DB 连接数 | 50 | 20 | 60% |
| GC 频率 | 10/min | 2/min | 80% |
```

### 日志验证

```java
// 添加耗时日志
long start = System.currentTimeMillis();
// ... 操作 ...
log.info("操作耗时: {}ms", System.currentTimeMillis() - start);
```
