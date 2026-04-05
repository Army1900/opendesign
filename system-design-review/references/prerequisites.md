# 前置依赖：技术栈扫描

扫描代码库识别项目使用的技术框架。**这是其他系统设计模块的前置依赖，必须先运行。**

## 输出路径

```
docs/system-design/[项目名]/技术栈.md
```

## 扫描策略

### 1. 依赖文件扫描

| 语言/框架 | 文件 | 识别内容 |
|-----------|------|----------|
| Java/Maven | pom.xml | dependencies, properties |
| Java/Gradle | build.gradle | dependencies |
| Node.js | package.json | dependencies |
| Python | requirements.txt / pyproject.toml | dependencies |
| Go | go.mod | require |
| .NET | *.csproj | PackageReference |

### 2. 配置文件扫描

| 文件模式 | 识别内容 |
|----------|----------|
| application*.yml / application*.properties | Spring配置 |
| bootstrap*.yml | Spring Cloud配置 |
| *.env / .env.* | 环境变量配置 |
| config/*.json | 通用配置 |
| docker-compose*.yml | 容器编排 |
| Dockerfile | 容器构建 |
| *.yaml (k8s) | K8s部署配置 |

### 3. 代码特征扫描

| 扫描目录 | 识别内容 |
|----------|----------|
| src/main/java/**/*.java | 注解、import、类继承 |
| src/main/resources/** | 配置、SQL、模板 |
| config/** | 配置类 |

---

## 框架识别规则

### 服务框架

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Boot | spring-boot-starter | @SpringBootApplication |
| Spring Cloud | spring-cloud-starter | @EnableDiscoveryClient |
| Express | express | const app = express() |
| NestJS | @nestjs/core | @Controller, @Module |
| Django | django | from django import |
| FastAPI | fastapi | from fastapi import |
| Gin | github.com/gin-gonic/gin | gin.New() |

### 服务调用

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Feign | spring-cloud-starter-openfeign | @FeignClient |
| Dubbo | dubbo-spring-boot-starter | @DubboReference |
| gRPC | grpc-netty | extends GeneratedMessageV3 |
| Retrofit | retrofit2 | Retrofit.Builder |
| Axios | axios | axios.create() |
| WebClient | spring-webflux | WebClient.create() |

### 数据库

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| MyBatis | mybatis-spring-boot-starter | @Mapper, *.xml |
| MyBatis-Plus | mybatis-plus-boot-starter | @TableName, BaseMapper |
| JPA/Hibernate | spring-boot-starter-data-jpa | @Entity, JpaRepository |
| Jooq | jooq | DSLContext |
| Sequelize | sequelize | Sequelize, Model |
| Prisma | @prisma/client | PrismaClient |

### 数据库类型

| 数据库 | 连接字符串特征 | 驱动依赖 |
|--------|----------------|----------|
| MySQL | jdbc:mysql:// | mysql-connector-java |
| PostgreSQL | jdbc:postgresql:// | postgresql |
| Oracle | jdbc:oracle:// | ojdbc |
| SQL Server | jdbc:sqlserver:// | mssql-jdbc |
| MongoDB | mongodb:// | mongodb-driver |
| Redis | redis:// | jedis/lettuce |
| Elasticsearch | http://*:9200 | elasticsearch-java |

### 缓存

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Cache | spring-boot-starter-cache | @Cacheable, @CacheEvict |
| Redis (Jedis) | jedis | JedisPool, JedisCluster |
| Redis (Lettuce) | lettuce-core | RedisClient |
| Redisson | redisson | RedissonClient |
| Caffeine | caffeine | Caffeine.newBuilder() |
| Ehcache | ehcache | CacheManager |

### 消息队列

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Kafka | spring-kafka | @KafkaListener, KafkaTemplate |
| RabbitMQ | spring-boot-starter-amqp | @RabbitListener, RabbitTemplate |
| RocketMQ | rocketmq-spring-boot-starter | @RocketMQMessageListener |
| ActiveMQ | spring-boot-starter-activemq | @JmsListener |

### 认证授权

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Spring Security | spring-boot-starter-security | @EnableWebSecurity, SecurityFilterChain |
| Shiro | shiro-spring | SecurityManager |
| JWT | jjwt / java-jwt | JwtBuilder, Jwts |
| OAuth2 | spring-security-oauth2 | @EnableOAuth2Client |
| Sa-Token | sa-token-spring | StpUtil |

### 配置中心

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Nacos | nacos-config-spring-boot-starter | spring.cloud.nacos.config |
| Apollo | apollo-client | @EnableApolloConfig |
| Consul | spring-cloud-starter-consul-config | spring.cloud.consul.config |
| Spring Cloud Config | spring-cloud-config-client | spring.cloud.config.uri |

### 注册中心

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Nacos | nacos-discovery-spring-boot-starter | spring.cloud.nacos.discovery |
| Eureka | spring-cloud-starter-netflix-eureka-client | @EnableDiscoveryClient |
| Consul | spring-cloud-starter-consul-discovery | spring.cloud.consul.discovery |
| Zookeeper | spring-cloud-starter-zookeeper-discovery | spring.cloud.zookeeper.discovery |

### 监控告警

| 框架 | 依赖特征 | 代码特征 |
|------|----------|----------|
| Prometheus | micrometer-registry-prometheus | @Timed, @Counted |
| Skywalking | skywalking-agent | agent配置 |
| Zipkin | spring-cloud-starter-sleuth | @NewSpan |

### 部署

| 类型 | 文件特征 | 识别内容 |
|------|----------|----------|
| Docker | Dockerfile | 基础镜像、构建步骤 |
| Docker Compose | docker-compose*.yml | 服务编排 |
| Kubernetes | *.yaml (含apiVersion) | Deployment, Service, ConfigMap |
| Jenkins | Jenkinsfile | 流水线定义 |
| GitLab CI | .gitlab-ci.yml | 流水线定义 |

---

## 不确定时的确认流程

### 需要确认的情况

| 情况 | 确认问题 |
|------|----------|
| 多个同类框架 | "发现同时使用了 Feign 和 RestTemplate，主要使用哪个？" |
| 版本不明确 | "发现 Spring Boot 依赖但版本不明确，是 2.x 还是 3.x？" |
| 配置缺失 | "发现数据库驱动但未找到连接配置，数据库类型是？" |
| 自研框架 | "发现自研 RPC 框架，请说明这个框架的功能？" |

### 确认方式

1. 先输出初步扫描结果
2. 列出不确定项
3. 逐项询问用户

---

## 输出模板

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
| 认证授权 | [框架] | [版本] | 安全控制 | ✅确定/❓待确认 |
| 配置中心 | [框架] | [版本] | 配置管理 | ✅确定/❓待确认 |
| 注册中心 | [框架] | [版本] | 服务发现 | ✅确定/❓待确认 |
| 部署方式 | [方式] | - | 运行环境 | ✅确定/❓待确认 |

---

## 3. 详细说明

[各组件详细配置和用途]

---

## 4. 服务清单

| 服务名 | 技术栈 | 依赖服务 | 配置文件 |
|--------|--------|----------|----------|
| [服务1] | [栈] | [依赖] | [路径] |

---

## 5. 待确认项

| 编号 | 类型 | 问题 | 代码位置 | 用户回答 |
|------|------|------|----------|----------|
| 1 | [类型] | [问题描述] | [位置] | [待填写] |

---

## 6. 信息完整性检查

- [ ] 编程语言确定
- [ ] 服务框架确定
- [ ] 数据库类型确定
- [ ] 主要依赖确定
- [ ] 部署方式确定
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
