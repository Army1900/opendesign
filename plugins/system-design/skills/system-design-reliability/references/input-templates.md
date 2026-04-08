# 输入模板

用户按需填写以下模板，对话过程中直接粘贴给 AI。

> **原则**：有则填写，无则跳过。必填项尽量提供完整。

---

## 1. 组网架构 (必填)

### 1.1 简要描述

```
系统名称：
部署环境：[生产/测试/开发]
架构类型：[单体/微服务/前后端分离/...]
```

### 1.2 网络拓扑

请提供以下任一形式：
- 网络拓扑图（可截图）
- 文字描述（示例）：

```
用户 → CDN → Nginx(2台) → Gateway服务(3台) → 业务服务(N台)
                                           ↓
                                    Redis集群(3主3从)
                                           ↓
                                    MySQL主从(1主1从)
```

### 1.3 服务部署

| 服务名 | 部署方式 | 实例数 | 部署位置 |
|--------|----------|--------|----------|
| Gateway | K8s/Docker/物理机 | 3 | 机房A |
| Order-Service | K8s | 5 | 机房A |

---

## 2. 数据库配置 (必填)

### 2.1 数据库基本信息

```
数据库类型：[MySQL/PostgreSQL/Oracle/...]
版本：
部署方式：[单机/主从/集群]
实例数量：
```

### 2.2 配置参数 (my.cnf / postgresql.conf)

```ini
# 请粘贴关键配置参数

# 连接相关
max_connections = 100
wait_timeout = 28800

# 缓冲相关
innodb_buffer_pool_size = 1G
innodb_log_buffer_size = 16M

# 日志相关
slow_query_log = ON
long_query_time = 1

# 复制相关 (如有)
server-id = 1
log_bin = ON
```

### 2.3 数据量级

| 数据库名 | 表数量 | 总数据量 | 日增量 | 最大单表 |
|----------|--------|----------|--------|----------|
| order_db | 50 | 500GB | 2GB | order_record (200GB) |

### 2.4 核心表结构

```
请列出核心表（或提供表结构 DDL）：

表名：order_record
字段数：15
索引：PRIMARY KEY (id), INDEX idx_user_id (user_id), ...
日增量：100万条
查询场景：按用户ID查询、按时间范围查询
```

---

## 3. 缓存配置 (视情况)

### 3.1 Redis 配置

```
部署模式：[单机/主从/哨兵/集群]
版本：
内存容量：
```

```conf
# redis.conf 关键配置
maxmemory 4gb
maxmemory-policy allkeys-lru
timeout 300
save 900 1
appendonly yes
```

### 3.2 缓存使用情况

| 缓存Key前缀 | 用途 | 数据结构 | 预估数量 | TTL |
|--------------|------|----------|----------|-----|
| user:* | 用户信息 | Hash | 100万 | 1小时 |
| session:* | 会话 | String | 10万 | 30分钟 |

---

## 4. 消息队列配置 (视情况)

### 4.1 基本配置

```
消息队列类型：[Kafka/RabbitMQ/RocketMQ/...]
版本：
部署方式：[单机/集群]
集群规模：[N个节点]
```

### 4.2 Topic/Queue 配置

| Topic/Queue | 消费者组 | 消费方式 | 日消息量 | 消费延迟 |
|-------------|----------|----------|----------|----------|
| order-created | order-group | 集群消费 | 100万 | < 1s |

### 4.3 配置参数

```yaml
# Kafka 示例
num.partitions: 3
replication.factor: 2
retention.ms: 604800000
```

---

## 5. 应用配置 (必填)

### 5.1 JVM 配置

```bash
# 启动参数
-Xms2g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

### 5.2 线程池配置

```yaml
# application.yml
thread-pool:
  core-size: 10
  max-size: 50
  queue-capacity: 100
  keep-alive-seconds: 60
```

### 5.3 超时配置

```yaml
# HTTP/服务调用超时
feign:
  connect-timeout: 3000
  read-timeout: 5000

# 数据库超时
datasource:
  connection-timeout: 3000
  socket-timeout: 5000
```

### 5.4 连接池配置

```yaml
# HikariCP
hikari:
  maximum-pool-size: 20
  minimum-idle: 5
  connection-timeout: 30000
  idle-timeout: 600000
```

---

## 6. Nginx 配置 (视情况)

### 6.1 基本配置

```nginx
# nginx.conf 关键配置
worker_processes auto;
worker_connections 10240;

http {
    keepalive_timeout 65;
    client_max_body_size 10m;
    
    upstream backend {
        server 192.168.1.1:8080 weight=1;
        server 192.168.1.2:8080 weight=1;
    }
}
```

---

## 7. 定时任务配置 (必填)

### 7.1 任务清单

| 任务名 | Cron 表达式 | 执行服务 | 预估耗时 | 并发执行 | 备注 |
|--------|-------------|----------|----------|----------|------|
| 数据同步 | 0 0 2 * * ? | sync-service | 30min | 否 | 每天凌晨2点 |
| 统计报表 | 0 0 3 * * ? | report-service | 10min | 否 | 依赖数据同步 |
| 缓存预热 | 0 */5 * * * ? | cache-service | 1min | 是 | 每5分钟 |
| 订单超时取消 | 0 */1 * * * ? | order-service | 30s | 是 | 每分钟 |

### 7.2 任务依赖关系

```
数据同步(2:00) → 统计报表(3:00) → 数据推送(4:00)
```

---

## 8. 监控告警配置 (可选)

### 8.1 监控覆盖

| 监控类型 | 工具 | 覆盖范围 |
|----------|------|----------|
| 基础监控 | Prometheus | CPU/内存/磁盘/网络 |
| 应用监控 | Skywalking | 接口/调用链/异常 |
| 业务监控 | 自研 | 订单量/支付成功率 |

### 8.2 告警规则

| 告警名称 | 指标 | 阈值 | 通知方式 |
|----------|------|------|----------|
| CPU 高 | cpu_usage | > 80% 持续 5min | 钉钉 |
| 内存不足 | memory_usage | > 85% | 钉钉 |
| 接口慢 | p99_latency | > 1s | 钉钉 |

---

## 9. 接口调用量 (可选)

### 9.1 QPS 分布

```
请提供文本数据（可从监控平台导出）：

| 接口 | 日均QPS | 峰值QPS | 峰值时段 |
|------|---------|---------|----------|
| /api/order/create | 500 | 2000 | 10:00-12:00 |
| /api/user/info | 1000 | 5000 | 全天 |
| /api/payment/callback | 100 | 500 | 活动期间 |
```

### 9.2 热点接口 Top 10

```
1. /api/user/info - 日均 1000 QPS
2. /api/order/list - 日均 800 QPS
...
```

---

## 快速填写指南

### 最小配置

如果时间有限，至少提供：

1. ✅ 组网架构简要描述
2. ✅ 数据库类型和版本
3. ✅ 应用 JVM 配置
4. ✅ 定时任务清单

### 完整配置

为了更全面的分析，建议提供所有必填项 + 视情况项。

---

## 注意事项

1. **敏感信息**：密码、密钥等请用 `******` 替代
2. **配置格式**：尽量保持原始格式，便于准确分析
3. **版本信息**：所有组件请标注版本号
4. **生产环境**：请明确标注是生产环境还是测试环境
