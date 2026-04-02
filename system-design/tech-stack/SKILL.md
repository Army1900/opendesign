---
name: system-design-tech-stack
description: 扫描代码库识别技术栈。这是其他系统设计skill的前置依赖,必须先运行此skill确定技术栈。当用户需要分析系统设计时触发。TRIGGER 当用户说"扫描下技术栈"、"分析下用了什么框架"、"梳理下技术架构"时使用。
---

# 技术栈扫描 Skill

扫描代码库识别项目使用的技术框架,输出标准化的技术栈清单。**这是其他系统设计 skill 的前置依赖。**

## 输出路径

```
docs/system-design/[项目名]/技术栈.md
```

## 工作流程

### 1. 扫描代码

按以下顺序扫描代码库:

#### 1.1 依赖文件
| 语言/框架 | 文件 | 识别内容 |
|-----------|------|----------|
| Java/Maven | pom.xml | dependencies, properties |
| Java/Gradle | build.gradle | dependencies |
| Node.js | package.json | dependencies |
| Python | requirements.txt / pyproject.toml | dependencies |
| Go | go.mod | require |
| .NET | *.csproj | PackageReference |

#### 1.2 配置文件
| 文件模式 | 识别内容 |
|----------|----------|
| application*.yml / application*.properties | Spring配置 |
| bootstrap*.yml | Spring Cloud配置 |
| *.env / .env.* | 环境变量配置 |
| config/*.json | 通用配置 |
| docker-compose*.yml | 容器编排 |
| Dockerfile | 容器构建 |
| *.yaml (k8s) | K8s部署配置 |

#### 1.3 代码特征
| 扫描目录 | 识别内容 |
|----------|----------|
| src/main/java/**/*.java | 注解、import、类继承 |
| src/main/resources/** | 配置、SQL、模板 |
| config/** | 配置类 |

---

## 2. 识别框架

### 2.1 服务框架
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Boot | spring-boot-starter | @SpringBootApplication |
| Spring Cloud | spring-cloud-starter | @EnableDiscoveryClient |
| Express | express | const app = express() |
| NestJS | @nestjs/core | @Controller, @Module |
| Django | django | from django import |
| FastAPI | fastapi | from fastapi import |
| Gin | github.com/gin-gonic/gin | gin.New() |

### 2.2 服务调用
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Feign | spring-cloud-starter-openfeign | @FeignClient |
| Dubbo | dubbo-spring-boot-starter | @DubboReference |
| gRPC | grpc-netty | extends GeneratedMessageV3 |
| Retrofit | retrofit2 | Retrofit.Builder |
| Axios | axios | axios.create() |
| WebClient | spring-webflux | WebClient.create() |

### 2.3 数据库
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| MyBatis | mybatis-spring-boot-starter | @Mapper, *.xml |
| MyBatis-Plus | mybatis-plus-boot-starter | @TableName, BaseMapper |
| JPA/Hibernate | spring-boot-starter-data-jpa | @Entity, JpaRepository |
| Jooq | jooq | DSLContext |
| Sequelize | sequelize | Sequelize, Model |
| Prisma | @prisma/client | PrismaClient |
| Mongock | mongock-spring | @ChangeUnit |

### 2.4 数据库类型
| 数据库 | 连接字符串特征 | 驱动依赖 |
|--------|----------------|----------|
| MySQL | jdbc:mysql:// | mysql-connector-java |
| PostgreSQL | jdbc:postgresql:// | postgresql |
| Oracle | jdbc:oracle:// | ojdbc |
| SQL Server | jdbc:sqlserver:// | mssql-jdbc |
| MongoDB | mongodb:// | mongodb-driver |
| Redis | redis:// | jedis/lettuce |
| Elasticsearch | http://*:9200 | elasticsearch-java |

### 2.5 缓存
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Cache | spring-boot-starter-cache | @Cacheable, @CacheEvict |
| Redis (Jedis) | jedis | JedisPool, JedisCluster |
| Redis (Lettuce) | lettuce-core | RedisClient |
| Redisson | redisson | RedissonClient |
| Caffeine | caffeine | Caffeine.newBuilder() |
| Ehcache | ehcache | CacheManager |

### 2.6 消息队列
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Kafka | spring-kafka | @KafkaListener, KafkaTemplate |
| RabbitMQ | spring-boot-starter-amqp | @RabbitListener, RabbitTemplate |
| RocketMQ | rocketmq-spring-boot-starter | @RocketMQMessageListener |
| ActiveMQ | spring-boot-starter-activemq | @JmsListener |

### 2.7 定时任务
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Scheduler | - | @Scheduled |
| XXL-Job | xxl-job-core | @XxlJob |
| Quartz | spring-boot-starter-quartz | @DisallowConcurrentExecution |
| ElasticJob | elasticjob-lite-spring | @ElasticJob |

### 2.8 认证授权
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Security | spring-boot-starter-security | @EnableWebSecurity, SecurityFilterChain |
| Shiro | shiro-spring | SecurityManager |
| JWT | jjwt / java-jwt | JwtBuilder, Jwts |
| OAuth2 | spring-security-oauth2 | @EnableOAuth2Client |
| Sa-Token | sa-token-spring | StpUtil |

### 2.9 加密
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Jasypt | jasypt-spring-boot | @EncryptablePropertySource |
| Bouncy Castle | bcprov-jdk15on | Security.addProvider |
| Hutool加密 | hutool-all | SecureUtil, CryptoUtil |

### 2.10 配置中心
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Nacos | nacos-config-spring-boot-starter | spring.cloud.nacos.config |
| Apollo | apollo-client | @EnableApolloConfig |
| Consul | spring-cloud-starter-consul-config | spring.cloud.consul.config |
| Spring Cloud Config | spring-cloud-config-client | spring.cloud.config.uri |

### 2.11 注册中心
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Nacos | nacos-discovery-spring-boot-starter | spring.cloud.nacos.discovery |
| Eureka | spring-cloud-starter-netflix-eureka-client | @EnableDiscoveryClient |
| Consul | spring-cloud-starter-consul-discovery | spring.cloud.consul.discovery |
| Zookeeper | spring-cloud-starter-zookeeper-discovery | spring.cloud.zookeeper.discovery |

### 2.12 网关
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Cloud Gateway | spring-cloud-starter-gateway | RouteLocator, @GatewayFilter |
| Zuul | spring-cloud-starter-netflix-zuul | @EnableZuulProxy |
| Kong | - | Kong配置文件 |

### 2.13 日志
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Logback | logback-classic | logback-spring.xml |
| Log4j2 | log4j-slf4j-impl | log4j2-spring.xml |
| ELK | - | logstash appender配置 |

### 2.14 监控告警
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Prometheus | micrometer-registry-prometheus | @Timed, @Counted |
| Skywalking | skywalking-agent | agent配置 |
| Zipkin | spring-cloud-starter-sleuth | @NewSpan |
| Pinpoint | - | agent配置 |

### 2.15 分布式事务
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Seata | seata-spring-boot-starter | @GlobalTransactional |
| Saga | spring-cloud-starter-openfeign (未完成) | Saga配置 |

### 2.16 文件存储
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| MinIO | minio-java | MinioClient |
| OSS (阿里云) | aliyun-oss | OSSClient |
| S3 (AWS) | aws-java-sdk-s3 | AmazonS3 |
| FastDFS | fastdfs-client | FastDFS工具类 |

### 2.17 搜索引擎
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Elasticsearch | elasticsearch-java | ElasticsearchClient |
| Solr | solr-solrj | SolrClient |

### 2.18 API文档
| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Swagger/Knife4j | springfox-swagger-ui / knife4j | @Api, @ApiOperation |
| SpringDoc | springdoc-openapi-ui | @OpenAPI, @Operation |

### 2.19 部署
| 类型 | 文件特征 | 识别内容 |
|------|----------|----------|
| Docker | Dockerfile | 基础镜像、构建步骤 |
| Docker Compose | docker-compose*.yml | 服务编排 |
| Kubernetes | *.yaml (含apiVersion) | Deployment, Service, ConfigMap |
| Jenkins | Jenkinsfile | 流水线定义 |
| GitLab CI | .gitlab-ci.yml | 流水线定义 |

---

## 3. 不确定时的确认流程

### 3.1 扫描时发现以下情况需确认

| 情况 | 确认问题 |
|------|----------|
| 多个同类框架 | "发现同时使用了 Feign 和 RestTemplate, 主要使用哪个?" |
| 版本不明确 | "发现 Spring Boot 依赖但版本不明确. 是 2.x 还是 3.x?" |
| 配置缺失 | "发现数据库驱动但未找到连接配置. 数据库类型是?" |
| 自研框架 | "发现自研 RPC 框架. 请说明这个框架的功能?" |
| 框架用途不明 | "发现 XXL-Job 依赖. 用于定时任务还是消息处理?" |

### 3.2 确认方式

1. 先输出初步扫描结果
2. 列出不确定项
3. 逐项询问用户
4. 用户可以:
   - 直接回答
   - 指出代码位置让 AI 查看
   - 提供配置示例

---

## 4. 输出模板

```markdown
# 技术栈扫描报告

> 文档生成时间：YYYY-MM-DD
> 扫描目录：[目录路径]

---

## 1. 项目概述

| 项目 | 内容 |
|------|------|
| **项目名称** | [名称] |
| **编程语言** | Java / Node.js / Python / Go / C# |
| **构建工具** | Maven / Gradle / npm / pip |
| **代码目录** | [目录结构] |

---

## 2. 技术栈总览

| 类型 | 框架/组件 | 版本 | 使用范围 | 状态 |
|------|-----------|------|----------|------|
| 服务框架 | [框架] | [版本] | 全局/部分 | ✅确定/❓待确认 |
| 服务调用 | [框架] | [版本] | 服务间 | ✅确定/❓待确认 |
| 数据库 | [类型] | [版本] | 数据存储 | ✅确定/❓待确认 |
| ORM | [框架] | [版本] | 数据访问 | ✅确定/❓待确认 |
| 缓存 | [框架] | [版本] | 数据缓存 | ✅确定/❓待确认 |
| 消息队列 | [框架] | [版本] | 异步通信 | ✅确定/❓待确认 |
| 定时任务 | [框架] | [版本] | 任务调度 | ✅确定/❓待确认 |
| 认证授权 | [框架] | [版本] | 安全控制 | ✅确定/❓待确认 |
| 配置中心 | [框架] | [版本] | 配置管理 | ✅确定/❓待确认 |
| 注册中心 | [框架] | [版本] | 服务发现 | ✅确定/❓待确认 |
| 日志 | [框架] | [版本] | 日志记录 | ✅确定/❓待确认 |
| 监控 | [框架] | [版本] | 可观测性 | ✅确定/❓待确认 |
| 部署方式 | [方式] | - | 运行环境 | ✅确定/❓待确认 |

---

## 3. 详细说明

### 3.1 服务框架
| 项目 | 内容 |
|------|------|
| **框架** | [框架名] |
| **版本** | [版本号] |
| **配置文件** | [文件路径] |
| **主要用途** | [说明] |
| **关键特性** | [特性列表] |

### 3.2 数据库
| 项目 | 内容 |
|------|------|
| **类型** | MySQL / PostgreSQL / Oracle / MongoDB |
| **连接方式** | 连接池 / 直连 |
| **ORM框架** | [框架名] |
| **配置位置** | [配置项路径] |

### 3.3 缓存
| 项目 | 内容 |
|------|------|
| **类型** | Redis / Memcached / 本地缓存 |
| **客户端** | Jedis / Lettuce / Redisson |
| **使用方式** | 注解式 / 编程式 |
| **主要用途** | [用途说明] |

### 3.4 消息队列
| 项目 | 内容 |
|------|------|
| **类型** | Kafka / RabbitMQ / RocketMQ |
| **使用模式** | 生产者 / 消费者 / 都有 |
| **Topic/Queue** | [列表] |
| **消费语义** | 至少一次 / 精确一次 |

### 3.5 服务调用
| 项目 | 内容 |
|------|------|
| **框架** | Feign / Dubbo / gRPC / REST |
| **调用方式** | 同步 / 异步 |
| **主要调用方** | [服务列表] |
| **被调用方** | [服务列表] |

### 3.6 部署
| 项目 | 内容 |
|------|------|
| **容器化** | Docker / 无 |
| **编排** | K8s / Docker Compose / 无 |
| **CI/CD** | Jenkins / GitLab CI / 无 |
| **环境** | 开发 / 测试 / 预发 / 生产 |

---

## 4. 服务清单

| 服务名 | 技术栈 | 依赖服务 | 配置文件 |
|--------|--------|----------|----------|
| [服务1] | [栈] | [依赖] | [路径] |
| [服务2] | [栈] | [依赖] | [路径] |

---

## 5. 待确认项

| 编号 | 类型 | 问题 | 代码位置 | 用户回答 |
|------|------|------|----------|----------|
| 1 | [类型] | [问题描述] | [位置] | [待填写] |
| 2 | [类型] | [问题描述] | [位置] | [待填写] |

---

## 6. 技术债务

| 项目 | 当前状态 | 建议升级 | 优先级 |
|------|----------|----------|--------|
| [依赖1] | [当前版本] | [建议版本] | 高/中/低 |

---

## 7. 信息完整性检查

- [ ] 编程语言确定
- [ ] 服务框架确定
- [ ] 数据库类型确定
- [ ] 主要依赖确定
- [ ] 部署方式确定

**待确认项**：[数量] 项
```

---

## 执行要求

1. **先扫描依赖文件**：pom.xml / package.json / requirements.txt 等
2. **再扫描配置文件**：application*.yml / bootstrap*.yml 等
3. **扫描代码特征**：注解、import、工具类使用
4. **扫描部署配置**：Dockerfile / k8s yaml
5. **输出初步结果**
6. **列出不确定项，逐个询问用户**
7. **用户确认后更新文档**
8. **输出最终文档到** `docs/system-design/[项目名]/技术栈.md`

---

## 依赖此 Skill 的其他 Skill

以下 skill 运行前应先运行 tech-stack skill:

- service-decomposition (需要知道服务框架类型)
- data-flow (需要知道消息队列类型)
- cache-design (需要知道缓存框架类型)
- api-design (需要知道 API 框架类型)
- security-design (需要知道认证授权框架)
- performance-design (需要知道数据库/缓存类型)
- availability-design (需要知道部署方式)
