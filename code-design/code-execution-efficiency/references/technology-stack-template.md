# 技术栈信息模板

在进行性能分析前，请填写以下信息，帮助更准确地定位问题。

> 提示：不需要全部填写，填写你已知的信息即可。不确定的项可以留空或写"不确定"。

## 方式一：创建项目配置文件（推荐）

在项目根目录创建 `.claude/performance-tech-stack.md` 文件，填入技术栈信息。

**优点**：一次配置，后续分析自动读取，无需重复说明。

**配置文件示例**：

```markdown
# 性能分析技术栈配置

## 基础信息
- 语言: Java 17
- 框架: Spring Boot 3.1
- 项目结构: 微服务

## 数据层
- 数据库: MySQL 8.0
- ORM: MyBatis-Plus 3.5
- 连接池: HikariCP，最大连接数 20

## 缓存
- 类型: Redis 7.0
- 客户端: Redisson
- 部署: 集群 3主3从

## 服务调用
- RPC: Feign
- 服务发现: Nacos

## 消息队列
- 类型: RocketMQ 5.0

## 定时任务
- 框架: XXL-Job 2.4

## 监控
- APM: SkyWalking
- 日志: ELK
```

## 方式二：对话中直接告知

如果不想创建配置文件，可以在对话中直接告诉 Claude 技术栈信息。

---

---

## 1. 基础框架

| 项目 | 你的技术选型 |
|-----|-------------|
| 开发语言及版本 | 例如：Java 17、Python 3.11、Go 1.21 |
| Web 框架 | 例如：Spring Boot 3.x、FastAPI、Gin、ASP.NET Core |
| 项目结构 | 单体应用 / 微服务 / Serverless |
| 构建工具 | Maven / Gradle / pip / go mod / npm |

---

## 2. 数据层

| 项目 | 你的技术选型 |
|-----|-------------|
| 关系型数据库 | MySQL / PostgreSQL / Oracle / SQL Server / 达梦 |
| 数据库版本 | 例如：MySQL 8.0 |
| ORM 框架 | MyBatis / MyBatis-Plus / JPA/Hibernate / SQLAlchemy / GORM |
| 数据库连接池 | HikariCP / Druid / c3p0 / DBCP |
| 连接池配置（如知道） | 最大连接数、最小空闲连接数 |

**是否有分库分表？**
- [ ] 否
- [ ] 是，中间件：ShardingSphere / MyCat / 其他______

**是否有读写分离？**
- [ ] 否
- [ ] 是，方案：______

---

## 3. 缓存层

| 项目 | 你的技术选型 |
|-----|-------------|
| 是否使用缓存 | 否 / 是 |
| 缓存类型 | Redis / Memcached / 本地缓存（Caffeine/Guava） |
| Redis 客户端 | Jedis / Lettuce / Redisson / 其他 |
| 缓存模式 | 单机 / 哨兵 / 集群 |
| 是否有多级缓存 | 否 / 是（本地+分布式） |

**缓存使用方式：**
- [ ] 直接操作缓存 API
- [ ] Spring Cache 注解（@Cacheable 等）
- [ ] 自定义缓存框架

---

## 4. 服务调用（微服务场景）

| 项目 | 你的技术选型 |
|-----|-------------|
| RPC 框架 | Feign / Dubbo / gRPC / Thrift / 原生 HTTP |
| 服务发现 | Nacos / Consul / Eureka / Zookeeper / K8s Service / 无 |
| 负载均衡 | Spring Cloud LoadBalancer / Ribbon / Dubbo 内置 |
| 熔断降级 | Sentinel / Hystrix / Resilience4j / 无 |
| 服务网关 | Spring Cloud Gateway / Zuul / Kong / Nginx / 无 |

---

## 5. 消息队列

| 项目 | 你的技术选型 |
|-----|-------------|
| 是否使用 MQ | 否 / 是 |
| MQ 类型 | Kafka / RocketMQ / RabbitMQ / ActiveMQ / Pulsar |
| 使用场景 | 异步处理 / 削峰填谷 / 解耦 / 延迟任务 |
| 消费模式 | 推模式 / 拉模式 |

---

## 6. 定时任务

| 项目 | 你的技术选型 |
|-----|-------------|
| 是否有定时任务 | 否 / 是 |
| 任务调度框架 | XXL-Job / ElasticJob / Quartz / Spring @Scheduled / Cron |
| 是否分布式 | 否 / 是 |
| 任务执行器数量 | 单机 / 集群（几台） |

---

## 7. 搜索与存储

| 项目 | 你的技术选型 |
|-----|-------------|
| 搜索引擎 | 无 / Elasticsearch / Solr |
| 时序数据库 | 无 / InfluxDB / Prometheus |
| 文档数据库 | 无 / MongoDB |
| 对象存储 | 无 / MinIO / OSS / S3 |

---

## 8. 监控与日志

| 项目 | 你的技术选型 |
|-----|-------------|
| APM 监控 | 无 / SkyWalking / Zipkin / Jaeger / Pinpoint |
| 指标监控 | 无 / Prometheus + Grafana / 自研 |
| 日志收集 | 无 / ELK（Elasticsearch+Logstash+Kibana） |
| 日志框架 | Logback / Log4j2 / JUL / 自定义 |

---

## 9. 容器与部署

| 项目 | 你的技术选型 |
|-----|-------------|
| 部署方式 | 物理机 / 虚拟机 / Docker / Kubernetes |
| 配置管理 | Spring Cloud Config / Nacos Config / Apollo / 配置文件 |
| 容器资源限制 | CPU: ___ 核，内存: ___ GB |

---

## 10. 当前问题场景（必填）

| 项目 | 描述 |
|-----|------|
| 问题接口/方法 | 例如：/api/order/create 或 OrderService.createOrder() |
| 问题现象 | 超时 / 响应慢 / 高 CPU / 高内存 / 报错 |
| 发生时间 | 什么时候开始出现的？是否持续？ |
| 数据量级 | 涉及表的数据量大约多少？ |
| 并发量 | 大约多少 QPS 或并发用户？ |
| 期望指标 | 希望达到的响应时间或吞吐量？ |

---

## 快速填写示例

```
语言: Java 17
框架: Spring Boot 3.1
数据库: MySQL 8.0, MyBatis-Plus, HikariCP
缓存: Redis 7.0, Redisson, 集群模式
MQ: RocketMQ 5.0
定时任务: XXL-Job
RPC: Feign
服务发现: Nacos

问题: /api/order/list 接口响应慢，3秒左右
数据量: orders 表 5000 万，order_items 表 2 亿
并发: 500 QPS
期望: 响应时间 < 500ms
```

---

## 技术栈与性能分析对照表

| 技术栈 | 关键分析点 |
|-------|-----------|
| **Spring Boot** | 自动配置、Bean 初始化、Actuator 端点 |
| **MyBatis** | XML SQL、动态 SQL、结果集映射、插件 |
| **HikariCP** | 连接池大小、超时配置、泄漏检测 |
| **Redis** | 大 Key、热点 Key、连接池、序列化方式 |
| **Feign** | 超时配置、重试策略、连接池、负载均衡 |
| **Dubbo** | 线程模型、序列化、负载均衡、熔断 |
| **Kafka** | 分区数、消费者组、offset 提交、批处理 |
| **RocketMQ** | 消费进度、重试队列、死信队列 |
| **XXL-Job** | 分片策略、任务超时、失败重试 |
| **Elasticsearch** | 索引设计、查询 DSL、分片数量 |
