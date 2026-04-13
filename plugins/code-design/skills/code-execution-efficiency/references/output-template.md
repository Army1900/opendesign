# 输出文档结构模板

性能分析报告的完整结构示例。

## 报告结构

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

| # | 问题 | 位置 | 影响 | 引入时间 | 风险 |
|---|------|------|------|----------|------|
| 1 | 循环内数据库调用 | OrderService:45 | N+1 问题，800ms | 2024-01-15 (a1b2c3d) | 🔴 高 |
| 2 | 同步 RPC 调用 | OrderService:58 | 累加延迟 500ms | 2023-11-20 (e4f5g6h) | 🟡 中 |

## 3. 详细分析

### 问题 1: 循环内数据库调用

**代码位置**: `OrderService.java:45`

**问题追溯**:
- 引入提交: `a1b2c3d` (2024-01-15)
- 提交信息: "feat: 支持订单批量创建"
- 作者: zhangsan
- 说明: 该功能最初为单条订单设计，后续扩展批量时未重构为批量查询

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
