# 技术栈分析指南

针对不同技术栈的性能分析关注点。

---

## 通用分析方法

当用户使用的框架不在已知列表中时，使用以下通用分析框架：

### 数据库操作（通用）
- 找到 SQL 执行位置
- 检查是否有连接池配置
- 检查事务边界
- 检查是否有批量操作优化

### 外部服务调用（通用）
- 找到超时配置（connect timeout、read timeout）
- 检查是否有重试机制
- 检查连接是否复用（连接池、keep-alive）
- 检查是否同步/异步调用

### 缓存使用（通用）
- 找到缓存读写位置
- 检查 Key 设计（是否合理、是否易冲突）
- 检查过期策略
- 检查缓存穿透/击穿/雪崩防护

### 消息队列（通用）
- 找到生产者/消费者位置
- 检查消费速度 vs 生产速度
- 检查失败消息处理
- 检查是否有积压

---

## 数据库

### MySQL

**配置文件**：`my.cnf` 或 `application.yml`

**关键配置**：
```yaml
# 连接池
spring.datasource.hikari.maximum-pool-size: 50
spring.datasource.hikari.minimum-idle: 10
spring.datasource.hikari.connection-timeout: 30000

# 慢查询
slow_query_log: ON
long_query_time: 1
```

**分析工具**：
```sql
-- 执行计划
EXPLAIN SELECT ...

-- 慢查询日志
SHOW VARIABLES LIKE 'slow_query%';

-- 锁分析
SHOW ENGINE INNODB STATUS;

-- 索引使用
SHOW INDEX FROM table_name;
```

**常见问题**：
| 问题 | 排查 | 解决 |
|-----|------|------|
| 索引失效 | EXPLAIN 看是否走索引 | 改写 SQL 或加索引 |
| 连接池满 | SHOW PROCESSLIST | 增大连接池或优化慢查询 |
| 锁等待 | SHOW ENGINE INNODB STATUS | 缩小事务范围 |

### PostgreSQL

**配置文件**：`postgresql.conf`

**分析工具**：
```sql
-- 执行计划
EXPLAIN ANALYZE SELECT ...

-- 查看锁
SELECT * FROM pg_locks;

-- 连接数
SELECT count(*) FROM pg_stat_activity;
```

**常见问题**：
| 问题 | 排查 | 解决 |
|-----|------|------|
| Seq Scan | EXPLAIN ANALYZE | 加索引 |
| 连接数过多 | pg_stat_activity | 配置 pgbouncer |
| VACUUM 未执行 | pg_stat_user_tables | 定期 VACUUM |

### MyBatis / MyBatis-Plus

**配置文件**：`mybatis-config.xml` 或 `application.yml`

**关键配置**：
```yaml
mybatis:
  configuration:
    log-impl: org.apache.ibatis.logging.slf4j.Slf4jImpl
  mapper-locations: classpath:mapper/**/*.xml
```

**检查点**：
| 检查项 | 文件位置 | 问题 |
|--------|----------|------|
| SELECT * | mapper XML | 返回冗余字段 |
| 动态 SQL | mapper XML | 可能导致索引失效 |
| N+1 问题 | resultmap 配置 | 关联查询多次 |
| 插件性能 | Interceptor | 拦截器开销 |

**代码位置**：
- SQL 定义：`mapper/*.xml`
- 接口定义：`mapper/*.java`
- 调用位置：`service/*.java`

### JPA / Hibernate

**配置文件**：`application.yml`

**关键配置**：
```yaml
spring:
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true
```

**检查点**：
| 检查项 | 代码位置 | 问题 |
|--------|----------|------|
| N+1 问题 | @OneToMany fetch | 懒加载多次查询 |
| 全量加载 | FetchType.EAGER | 不必要的数据加载 |
| 二级缓存 | @Cacheable | 缓存配置 |
| 批量操作 | batch_size | 未启用批量 |

---

## 缓存

### Redis

**配置文件**：`redis.conf` 或 `application.yml`

**关键配置**：
```yaml
spring:
  redis:
    host: localhost
    port: 6379
    lettuce:
      pool:
        max-active: 50
        max-idle: 20
    timeout: 3000
```

**分析命令**：
```bash
# 慢日志
SLOWLOG GET 10

# 大 Key
MEMORY USAGE key
STRLEN key
HLEN key

# 热点 Key
MONITOR  # 谨慎使用，有性能开销

# 信息
INFO memory
INFO stats
```

**检查点**：
| 检查项 | 排查命令 | 问题 |
|--------|----------|------|
| 大 Key | MEMORY USAGE | 序列化慢、阻塞 |
| 连接池 | INFO clients | 连接数不足 |
| 内存 | INFO memory | 内存不足 |

### Spring Cache

**配置位置**：`@EnableCaching` + 缓存注解

**检查点**：
```java
// Key 生成是否合理
@Cacheable(value = "user", key = "#id")  // OK
@Cacheable(value = "user")  // 可能 key 冲突

// 过期时间
@Cacheable(value = "user", key = "#id")  // 需要 TTL 配置

// 缓存穿透防护
if (user == null) {
    cache.put(key, NULL_VALUE);  // 空值缓存
}
```

---

## 服务调用

### Feign

**配置文件**：`application.yml`

**关键配置**：
```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
  httpclient:
    enabled: true  # 启用连接池
    max-connections: 200
    max-connections-per-route: 50
```

**检查点**：
| 检查项 | 配置/代码 | 问题 |
|--------|----------|------|
| 超时配置 | feign.client.config | 无超时或超时过长 |
| 连接池 | feign.httpclient | 连接池未启用或过小 |
| 重试 | Retryer | 重试策略不合理 |
| 日志 | Logger.Level | 日志级别过高 |

### Dubbo

**配置文件**：`dubbo.properties` 或 `application.yml`

**关键配置**：
```yaml
dubbo:
  protocol:
    threads: 200  # 服务线程池
  consumer:
    timeout: 5000
    retries: 2
  provider:
    executes: 100  # 并发执行限制
```

**检查点**：
| 检查项 | 配置 | 问题 |
|--------|------|------|
| 线程池 | dubbo.protocol.threads | 线程数过小 |
| 超时 | dubbo.consumer.timeout | 超时配置不当 |
| 重试 | dubbo.consumer.retries | 重试放大请求 |
| 负载均衡 | loadbalance | 负载不均 |

### gRPC

**配置位置**：代码配置

**关键配置**：
```java
ManagedChannel channel = ManagedChannelBuilder.forAddress(host, port)
    .usePlaintext()
    .keepAliveTime(30, TimeUnit.SECONDS)
    .keepAliveTimeout(10, TimeUnit.SECONDS)
    .maxInboundMessageSize(10 * 1024 * 1024)
    .build();
```

**检查点**：
| 检查项 | 问题 |
|--------|------|
| Channel 复用 | 是否单例 |
| 拦截器开销 | 拦截器是否耗时 |
| 流式调用 | 是否适合用流 |

---

## 消息队列

### Kafka

**配置文件**：`application.yml` 或 `producer/consumer.properties`

**关键配置**：
```yaml
# Producer
spring.kafka.producer.batch-size: 16384
spring.kafka.producer.linger-ms: 5
spring.kafka.producer.buffer-memory: 33554432

# Consumer
spring.kafka.consumer.max-poll-records: 500
spring.kafka.consumer.auto-offset-reset: earliest
```

**分析命令**：
```bash
# 消费 Lag
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group my-group

# 分区信息
kafka-topics.sh --describe --topic my-topic
```

**检查点**：
| 检查项 | 问题 |
|--------|------|
| 分区数 | 分区不足限制并发 |
| 消费 Lag | 生产快于消费 |
| offset 提交 | 提交频率影响性能 |

### RocketMQ

**配置文件**：`application.yml`

**关键配置**：
```yaml
rocketmq:
  consumer:
    consume-thread-min: 20
    consume-thread-max: 64
  producer:
    retry-times-when-send-failed: 2
```

**检查点**：
| 检查项 | 问题 |
|--------|------|
| 消费线程 | 线程数不足 |
| 消息堆积 | broker 端查看 |
| 顺序消费 | 顺序消费限制并发 |

### RabbitMQ

**配置文件**：`application.yml`

**关键配置**：
```yaml
spring:
  rabbitmq:
    listener:
      simple:
        prefetch: 10
        concurrency: 5
        max-concurrency: 10
```

**检查点**：
| 检查项 | 问题 |
|--------|------|
| prefetch | 过大导致消息积压 |
| 消费者数量 | 并发不足 |
| ACK 模式 | 自动 ACK 可能丢消息 |

---

## 定时任务

### XXL-Job

**配置文件**：`application.yml`

**检查点**：
| 检查项 | 问题 |
|--------|------|
| 分片广播 | 大任务是否分片 |
| 超时配置 | 任务超时未配置 |
| 执行器数量 | 执行器不足 |
| 失败重试 | 重试策略 |

### Spring @Scheduled

**配置位置**：代码注解

**检查点**：
```java
// 默认单线程
@Scheduled(fixedRate = 5000)  // 多个任务串行

// 需要配置线程池
@EnableAsync
@Scheduled(fixedRate = 5000)
@Async
public void task() {}
```

---

## 框架层

### Spring Boot

**配置文件**：`application.yml`

**关键配置**：
```yaml
server:
  tomcat:
    threads:
      max: 200
      min-spare: 10
    accept-count: 100

spring:
  mvc:
    async:
      request-timeout: 30000
```

**Actuator 端点**：
```bash
# 性能指标
/actuator/metrics
/actuator/metrics/http.server.requests
/actuator/metrics/jvm.memory.used

# 线程 dump
/actuator/threaddump
```

**检查点**：
| 检查项 | 问题 |
|--------|------|
| Bean 初始化 | 是否有慢初始化 |
| 线程池配置 | tomcat threads |
| 连接池 | 数据库/Redis/HTTP 连接池 |

### Tomcat / Undertow

**配置文件**：`application.yml`

**Tomcat 配置**：
```yaml
server:
  tomcat:
    threads:
      max: 200
      min-spare: 10
    accept-count: 100
    max-connections: 10000
```

**Undertow 配置**：
```yaml
server:
  undertow:
    threads:
      io: 16
      worker: 200
    buffer-size: 1024
```

---

## 扩展支持

如果用户使用的框架不在列表中：

### 方式一：更新项目配置文件

在 `.claude/performance-tech-stack.md` 中添加：

```markdown
## [框架名称]

### 关键配置
- 配置文件: [路径]
- 关键配置项:
  - [配置项1]: [说明]
  - [配置项2]: [说明]

### 常见问题
| 问题 | 排查方法 | 解决方案 |
|-----|---------|---------|
| [问题1] | [方法] | [方案] |
```

### 方式二：询问关键信息

```
我注意到你们使用的是 [框架名]，我暂时没有该框架的详细分析指南。

为了更好地分析，请告诉我：
1. [框架名] 的数据库连接池怎么配置的？
2. 调用超时是怎么设置的？
3. 有没有监控端点可以查看运行时状态？
```
