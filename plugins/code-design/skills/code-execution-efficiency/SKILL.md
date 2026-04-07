---
name: code-execution-efficiency
description: |
  分析代码执行效率和性能问题。当用户提到：接口慢、方法执行慢、SQL慢、性能问题、高并发问题、
  需要优化性能、分析调用链、排查超时、数据库性能、日志分析性能等场景时触发此 skill。
  Trigger phrases: "分析性能", "这个接口慢", "SQL太慢", "高并发", "性能瓶颈",
  "调用链分析", "执行效率", "优化速度", "超时问题", "数据库慢查询"
---

# 代码执行效率分析

全链路分析代码性能问题，**必须结合代码**，**方案必须贴合项目**。

---

## 核心原则

### 1. 代码驱动分析

```
❌ 错误：空谈理论
"这个 SQL 可能有问题，建议加索引"
→ 没看代码，不知道调用上下文

✅ 正确：基于代码分析
1. 读取代码，找到调用位置
2. 追踪调用链（入口 → Service → DAO → SQL）
3. 结合上下文分析（循环？事务？并发？）
4. 针对性给出方案
```

### 2. 方案贴合项目

```
❌ 天马行空：
"建议引入 Kafka 做异步解耦"
→ 项目没有 MQ，引入成本巨大

✅ 贴合实际：
1. 先看项目有什么：Spring Boot + Redis + MySQL
2. 用现有能力：Redis 队列 + 线程池
3. 或者：先优化为并行调用，不引入新组件
```

### 3. 全链路视角

性能问题是系统性的，不能单点分析：

```
分析 SQL：
  - 不只看 SQL 本身
  - 还要看调用上下文（循环？N+1？）
  - 还要看事务范围（锁持有时间？）
  - 还要看并发场景（热点？竞争？）
  - 还要看缓存（缓存命中率？）
```

---

## 输入优先级

```
优先级 1: 入口代码路径（必须）
         - 没有代码无法分析
         - 示例: "分析 OrderService.createOrder 方法"
         
优先级 2: 性能问题描述
         - 响应时间、QPS、错误率
         - 示例: "响应 2s，QPS 100"
         
优先级 3: 相关配置路径
         - 连接池、缓存、超时配置
         - 示例: "配置在 application.yml"
         
优先级 4: 日志/监控
         - 问题时间段日志
         - 监控截图/数据
```

---

## 输出规范

### 输出路径

```
docs/performance/[分析对象]/性能分析报告.md
```

### 文档结构

```markdown
# [入口方法/接口] 性能分析报告

> 分析时间：YYYY-MM-DD HH:mm
> 技术栈：[Spring Boot 3 + MyBatis + MySQL 8 + Redis]
> 分析对象：[类名.方法名 或 API 路径]

---

## 1. 调用链路

```
[入口] OrderController.createOrder()
    │
    ├── [Service] OrderService.createOrder()  ◄── 总耗时: 1500ms
    │       │
    │       ├── [校验] validateOrder()        ◄── 50ms
    │       │
    │       ├── [DB] INSERT orders            ◄── 100ms
    │       │
    │       ├── [循环] for items              ◄── 800ms ⚠️
    │       │       └── [DB] INSERT item      ◄── 80ms * 10
    │       │
    │       └── [RPC] PaymentService.pay()    ◄── 500ms
    │
    └── [返回] Response
```

## 2. 问题清单

| # | 问题 | 位置 | 影响 | 风险 |
|---|------|------|------|------|
| 1 | 循环内数据库调用 | OrderService:45 | N+1 问题，800ms | 🔴 高 |
| 2 | 同步 RPC 调用 | OrderService:58 | 累加延迟 500ms | 🟡 中 |

## 3. 详细分析

### 问题 1: 循环内数据库调用

**代码位置**: `OrderService.java:45`

**代码片段**:
```java
for (OrderItem item : items) {
    orderItemDao.insert(item);  // 循环内单条插入
}
```

**分析**:
- 10 个 item，每个 80ms，总计 800ms
- 循环内数据库调用，N+1 模式
- 每次都是独立的数据库交互

**检查项匹配**:
- [x] 循环内数据库调用 → 🔴 高风险

### 问题 2: 同步 RPC 调用

...

## 4. 优化方案

### 方案 1: 批量插入（推荐）

**改动**:
```java
// 改动前
for (OrderItem item : items) {
    orderItemDao.insert(item);
}

// 改动后 - MyBatis 批量插入
orderItemDao.batchInsert(items);
```

**Mapper.xml**:
```xml
<insert id="batchInsert">
    INSERT INTO order_item (order_id, product_id, quantity)
    VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.orderId}, #{item.productId}, #{item.quantity})
    </foreach>
</insert>
```

**预期收益**: 800ms → 50ms，减少 93%

**成本**: 低，改动 2 个文件

**风险**: 无

### 方案 2: 异步支付（备选）

**改动**:
```java
// 改动前
PaymentResult result = paymentService.pay(request);

// 改动后 - 异步调用
CompletableFuture.runAsync(() -> {
    paymentService.pay(request);
}, asyncExecutor);
```

**预期收益**: 减少 500ms 同步等待

**成本**: 中，需要处理异步回调

**风险**: 支付结果需要异步通知

## 5. 验证方法

1. 压测对比: `ab -n 1000 -c 50`
2. 监控指标: P99 响应时间、QPS
3. 日志验证: 耗时日志对比

---

## 附录

### A. 检查项结果

| 检查项 | 位置 | 状态 | 风险 |
|--------|------|------|------|
| 循环内数据库调用 | OrderService:45 | ❌ | 🔴 |
| 同步调用可异步 | OrderService:58 | ⚠️ | 🟡 |

**风险统计**: 🔴 高风险 1 项 | 🟡 中风险 1 项

### B. 优化优先级

| 优先级 | 方案 | 预期收益 | 成本 |
|--------|------|----------|------|
| P0 | 批量插入 | 750ms | 低 |
| P1 | 异步支付 | 500ms | 中 |
```

---

## 执行流程

```
┌─────────────────┐
│  接收输入       │ ◄── 入口代码路径 + 问题描述
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  确认技术栈     │ ◄── 读取项目配置文件
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  读取代码       │ ◄── 从入口开始，逐层追踪
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  绘制调用链     │ ◄── 标注每层耗时
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  检查项匹配     │ ◄── 对照 checklists.md
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  输出方案       │ ◄── 贴合技术栈，带代码示例
└─────────────────┘
```

---

## References

分析过程中按需读取：

| 参考 | 用途 |
|------|------|
| [checklists.md](references/checklists.md) | 检查项清单（代码层/数据层/缓存层/外部服务） |
| [tech-stack-guides.md](references/tech-stack-guides.md) | 技术栈分析指南（MySQL/Redis/Feign 等） |
| [optimization-patterns.md](references/optimization-patterns.md) | 优化模式速查（SQL/缓存/并发/异步） |

---

## 使用示例

### 示例 1: 分析接口

```
用户: /api/order/create 这个接口响应要 2 秒，帮我分析
      代码在 src/main/java/com/example/controller/OrderController.java
```

→ 读取代码 → 追踪调用链 → 识别瓶颈 → 输出方案

### 示例 2: 分析方法

```
用户: UserService.batchImport 这个方法在处理大量数据时很慢
      代码路径: src/main/java/com/example/service/UserService.java
      数据量: 10 万条
```

→ 读取代码 → 分析批处理逻辑 → 检查内存和 IO → 输出方案

### 示例 3: 分析 SQL

```
用户: 这个 SQL 慢，帮我看看
      SELECT * FROM orders WHERE DATE(create_time) = '2024-01-01'
      表里有 100 万条数据
```

→ 分析 SQL → 找到调用代码 → 看上下文 → 输出方案（带索引 + 代码改动）

### 示例 4: 高并发问题

```
用户: 库存扣减在高并发下有问题，会超卖
      代码: InventoryService.deduct
```

→ 读取代码 → 分析锁机制 → 检查竞态条件 → 输出贴合项目的并发方案

---

## 技术栈信息收集

在分析前，先了解项目技术栈：

### 配置文件优先级

```
1. CLAUDE.md 中的技术栈章节
2. .claude/performance-tech-stack.md
3. application.yml / pom.xml / build.gradle
4. 询问用户
```

### 自定义配置模板

用户可在 `.claude/performance-tech-stack.md` 中配置：

```markdown
# 性能分析技术栈

## 基础框架
- 语言: Java 17
- 框架: Spring Boot 3.1

## 数据层
- 数据库: MySQL 8.0
- ORM: MyBatis-Plus 3.5
- 连接池: HikariCP (max: 50)

## 缓存
- Redis 7.0 + Redisson

## 服务调用
- RPC: Feign
- 超时: 5s

## 消息队列
- RocketMQ 5.0
```

---

## 注意事项

1. **必须有代码**：没有代码无法分析，先问用户要代码路径
2. **全链路视角**：不只看单点，要看调用上下文
3. **方案贴合**：用现有组件，不天马行空
4. **给出代码**：优化方案要带针对当前项目的代码示例
5. **量化收益**：每个方案说明预期收益
6. **评估成本**：说明改动量和风险
