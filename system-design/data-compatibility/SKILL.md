---
name: system-design-data-compatibility
description: 分析系统的数据格式兼容性设计。当需要梳理"数据协议升级、Schema变更、新老格式共存"时触发。TRIGGER 当用户说"分析下数据兼容性"、"Schema变更怎么设计"、"新老数据格式怎么共存"、"数据迁移策略"时使用。
dependencies:
  - system-design-tech-stack
  - system-design-storage-design
---

# 数据格式兼容性设计 Skill

分析系统在数据格式变更时的兼容性设计， 确保新老格式可以平滑过渡。

## 输出路径

```
docs/system-design/[项目名]/数据兼容性设计.md
```

---

## 核心问题

数据格式变更时的三个核心问题：

```
时间线: ─────────────────────────────────────────►

老格式数据 ────┐
                    │  共存期  │
新格式数据 ─────────┘

问题:
1. 老数据怎么迁移?
2. 新老格式怎么共存?
3. 何时可以删除老格式?
```

---

## 数据存储维度

### 1. 数据库 Schema 变更

| 变更类型 | 风险 | 兼容策略 | 迁移步骤 |
|----------|------|----------|----------|
| **新增字段** | 低 | DEFAULT + Nullable | 1.加字段 2.更新代码 |
| **删除字段** | 高 | 废弃标记 → 代码移除 → 删字段 | 1.代码不读 2.标记废弃 3.删字段 |
| **改名** | 高 | 双写双字段 → 迁移 → 删旧 | 1.加新字段 2.双写 3.迁移 4.删旧 |
| **改类型** | 中 | 扩大类型(小→大) / 转换字段 | 1.加新列 2.转换 3.切读写 4.删旧列 |
| **加索引** | 低 | 在线DDL / 低峰期 | 1.创建索引 |
| **删索引** | 中 | 确认无依赖后 | 1.代码不用 2.删索引 |

### 2. 缓存数据变更

| 变更类型 | 问题 | 兼容策略 |
|----------|------|----------|
| **Key 结构变化** | 老Key失效 | Key版本化: `user:v1:{id}` → `user:v2:{id}` |
| **Value 字段新增** | 反序列化失败 | Optional 字段 + 默认值 |
| **Value 字段删除** | 老代码报错 | 保留字段 + @Deprecated |
| **Value 字段改名** | 字段缺失 | 双字段 + 映射逻辑 |
| **序列化格式变化** | 解析失败 | 后缀区分: `user:v2:{id}:proto` |

### 3. 消息数据变更

| 变更类型 | 问题 | 兼容策略 |
|----------|------|----------|
| **消息字段新增** | 老消费者忽略 | Optional + 默认值 |
| **消息字段删除** | 老消费者报错 | 保留字段 + 废弃标记 |
| **消息格式升级** | 解析失败 | 版本号字段 + 多版本消费 |
| **Topic 结构变化** | 分区/副本变化 | 新旧 Topic 共存 → 迁移 → 删旧 |

### 4. 内存数据变更

| 变更类型 | 场景 | 兼容策略 |
|----------|------|----------|
| **Session 结构变化** | 用户登录态 | 版本号 + 按需刷新 |
| **本地缓存结构变化** | 进程内缓存 | 版本号 + 失效重建 |
| **共享内存结构变化** | 多进程共享 | 双写 + 渐进切换 |

### 5. 定时任务参数变更

| 变更类型 | 问题 | 兼容策略 |
|----------|------|----------|
| **参数新增** | 老任务失败 | 默认值 + 参数校验 |
| **参数删除** | 老任务传参 | 忽略 + 日志告警 |
| **参数格式变化** | 解析失败 | 多格式兼容 + 渐进迁移 |

---

## 兼容策略模式

### 模式 1: 双写双读 (Dual Write)

```
写入: 写老格式 + 写新格式
读取: 先读新格式, 失败则读老格式
迁移: 后台任务迁移老数据到新格式
清理: 确认全部迁移后, 删除老格式
```

**适用场景**: Schema 重命名、格式升级

```java
// 双写示例
public void save(Order order) {
    // 写新格式
    cache.set("order:v2:" + order.getId(), order.toV2());
    // 写老格式 (兼容)
    cache.set("order:v1:" + order.getId(), order.toV1());
}

// 双读示例
public Order get(String orderId) {
    // 先读新格式
    Order order = cache.get("order:v2:" + orderId);
    if (order != null) return order;
    
    // 降级读老格式
    order = cache.get("order:v1:" + orderId);
    if (order != null) {
        // 触发迁移
        migrateToV2(order);
    }
    return order;
}
```

### 模式 2: 版本号字段 (Version Field)

```
消息/数据中嵌入版本号:
{
    "version": 2,
    "data": { ... }
}

消费者按版本解析:
if (version == 1) parseV1(data)
if (version == 2) parseV2(data)
```

**适用场景**: 消息格式、缓存 Value

```java
// 版本化消息
public class OrderMessage {
    private int version = 2;  // 当前版本
    private OrderDataV2 data;
}

// 多版本消费
@KafkaListener
public void consume(String message) {
    JsonNode json = objectMapper.readTree(message);
    int version = json.get("version").asInt();
    
    switch (version) {
        case 1: handleV1(json.get("data"));
        case 2: handleV2(json.get("data"));
    }
}
```

### 模式 3: 渐进式迁移 (Progressive Migration)

```
阶段1: 新代码可读新老格式
阶段2: 新代码写入新格式 (可选双写)
阶段3: 后台任务迁移老数据
阶段4: 验证迁移完成
阶段5: 新代码不再处理老格式
阶段6: 删除老格式数据
```

**适用场景**: 大规模数据迁移

```
-- 阶段1: 代码可读新老格式
SELECT id, name,       -- 老字段
       name AS name_v2  -- 新字段
FROM users;

-- 阶段3: 后台迁移
UPDATE users SET name_v2 = name WHERE name_v2 IS NULL;

-- 阶段5: 代码只读新格式
SELECT id, name_v2 FROM users;

-- 阶段6: 删除老字段
ALTER TABLE users DROP COLUMN name;
```

### 模式 4: Feature Flag (功能开关)

```
写入: 按开关决定写新格式还是老格式
读取: 按开关决定读新格式还是老格式
迁移: 调整开关比例, 灰度切换
```

**适用场景**: 灰度发布、A/B测试

```java
// Feature Flag 控制
public void save(Order order) {
    if (featureFlag.isOn("order-format-v2")) {
        cache.set("order:v2:" + order.getId(), order.toV2());
    } else {
        cache.set("order:v1:" + order.getId(), order.toV1());
    }
}

// 灰度切换
// 开关配置: order-format-v2: 10% → 50% → 100%
```

---

## 输出模板

```markdown
# 数据兼容性设计文档

> 文档生成时间：YYYY-MM-DD
> 数据来源：[文件名]

---

## 1. 数据格式变更清单

### 1.1 变更总览
| 编号 | 存储 | 变更类型 | 影响范围 | 优先级 | 状态 |
|------|------|----------|----------|--------|------|
| 1 | MySQL | 新增字段 | 订单表 | P0 | 规划中 |
| 2 | Redis | 字段重命名 | 用户缓存 | P1 | 规划中 |
| 3 | Kafka | 消息格式升级 | 订单事件 | P0 | 规划中 |

### 1.2 变更详情
| 编号 | 当前格式 | 目标格式 | 兼容策略 |
|------|----------|----------|----------|
| 1 | name: string | name: string, nickname: string | Optional + 默认值 |
| 2 | {userName} | {username} | 双写双字段 |
| 3 | v1事件格式 | v2事件格式 | 版本号字段 |

---

## 2. 数据库 Schema 变更

### 2.1 变更清单
| 表名 | 变更 | 兼容策略 | 迁移SQL |
|------|------|----------|---------|
| orders | 新增 nickname | DEFAULT NULL | `ALTER TABLE orders ADD nickname VARCHAR(50) DEFAULT NULL` |
| users | 重命名 name→username | 双写双字段 | 见迁移脚本 |

### 2.2 迁移计划
| 阶段 | 操作 | 代码变更 | 验证 |
|------|------|----------|------|
| 1 | 加新字段 | 可读新老 | ✓ |
| 2 | 双写 | 写新+写旧 | ✓ |
| 3 | 迁移数据 | 后台任务 | ✓ |
| 4 | 切换读 | 只读新 | ✓ |
| 5 | 删旧字段 | 移除旧逻辑 | 待执行 |

### 2.3 回滚方案
| 阶段 | 回滚操作 |
|------|----------|
| 加字段后 | `ALTER TABLE DROP COLUMN` |
| 双写后 | 关闭新字段写入 |
| 切换读后 | 切回读老字段 |
| 删字段后 | 从备份恢复 |

---

## 3. 缓存数据变更

### 3.1 Key 结构变更
| 场景 | 老Key | 新Key | 策略 |
|------|-------|-------|------|
| 用户信息 | user:{id} | user:v2:{id} | 版本化Key |

### 3.2 Value 结构变更
| 场景 | 老格式 | 新格式 | 兼容方式 |
|------|--------|--------|----------|
| 用户信息 | {name} | {username} | 双字段 + 映射 |

### 3.3 读写策略
```java
// 写: 双写
public void setUserInfo(User user) {
    cache.set("user:v1:" + user.getId(), user.toV1());
    cache.set("user:v2:" + user.getId(), user.toV2());
}

// 读: 先新后旧
public User getUserInfo(String userId) {
    User user = cache.get("user:v2:" + userId);
    if (user != null) return user;
    
    UserInfoV1 v1 = cache.get("user:v1:" + userId);
    if (v1 != null) {
        user = v1.toV2();
        cache.set("user:v2:" + userId, user);
        return user;
    }
    return null;
}
```

### 3.4 清理计划
| 阶段 | 操作 | 触发条件 |
|------|------|----------|
| 双写期 | 写新老格式 | - |
| 切换期 | 只写新格式 | 新格式覆盖率>95% |
| 清理期 | 删除老Key | 新格式覆盖率=100% |

---

## 4. 消息数据变更

### 4.1 消息格式
| Topic | 版本 | 格式 | 消费策略 |
|-------|------|------|----------|
| order-events | v1 | {orderId, status} | 多版本消费 |
| order-events | v2 | {version, orderId, status, timestamp} | 多版本消费 |

### 4.2 消费者兼容
```java
@KafkaListener(topics = "order-events")
public void consume(String message) {
    JsonNode json = objectMapper.readTree(message);
    
    if (json.has("version")) {
        handleV2(json);  // 新格式
    } else {
        handleV1(json);  // 老格式
    }
}

private void handleV2(JsonNode json) {
    String orderId = json.get("orderId").asText();
    String status = json.get("status").asText();
    // 处理新格式
}

private void handleV1(JsonNode json) {
    String orderId = json.get("orderId").asText();
    String status = json.get("status").asText();
    // 转换后处理
    OrderEventV2 event = new OrderEventV2(orderId, status, null);
    handleV2(event);
}
```

### 4.3 生产者兼容
| 阶段 | 生产策略 | 消费者要求 |
|------|----------|------------|
| 过渡期 | 双写新老Topic | 支持双Topic |
| 切换期 | 只写新Topic | 支持新格式 |
| 清理期 | 删除老Topic | - |

---

## 5. 迁移任务清单

### 5.1 迁移脚本
| 编号 | 任务 | SQL/代码 | 状态 |
|------|------|----------|------|
| 1 | 迁移用户数据 | `UPDATE users SET username = name WHERE username IS NULL` | 待执行 |
| 2 | 迁移缓存数据 | 见迁移脚本 | 待执行 |
| 3 | 迁移消息数据 | 消费老Topic, 写新Topic | 待执行 |

### 5.2 验证脚本
| 编号 | 验证项 | 检查SQL/代码 | 通过标准 |
|------|--------|--------------|----------|
| 1 | 数据一致性 | `SELECT COUNT(*) FROM users WHERE username IS NULL` | = 0 |
| 2 | 缓存覆盖率 | `SCAN user:v2:* COUNT` | > 95% |

---

## 6. 时间线

```
Week 1: 加字段 + 代码可读新老
Week 2: 代码双写
Week 3: 后台迁移任务
Week 4: 验证迁移完成
Week 5: 切换只读新格式
Week 6: 删除老格式
```

---

## 7. 回滚预案

| 时间点 | 问题 | 回滚操作 |
|--------|------|----------|
| 加字段后 | 字段设计错误 | DROP COLUMN |
| 双写后 | 性能问题 | 关闭新字段写入 |
| 切换后 | 业务异常 | 切回老格式读取 |
| 删除后 | 遗漏依赖 | 从备份恢复字段 |

---

## 8. 信息完整性检查

**待确认项**：[列出所有待补充项目]
```

---

## 执行要求

### 1. 前置输入
- `技术栈.md` - 了解数据库/缓存/消息类型
- `存储设计.md` - 了解表结构和索引

### 2. 识别数据格式变更

| 检查位置 | 识别内容 |
|----------|----------|
| 实体类 | 字段增删改、类型变化 |
| DTO/VO | 字段映射逻辑 |
| 迁移脚本 | 历史变更记录 |
| 消息类 | 字段版本号 |

### 3. 输出位置
将生成的文档保存到 `docs/system-design/[项目名]/数据兼容性设计.md`

---

## 使用示例

### 输入
```
用户: "帮我分析下这个系统的数据兼容性设计"
项目: /project/order-service/
代码变更: User 实体 name → username
```

### 流程
1. 读取 `docs/system-design/order-service/技术栈.md`
2. 读取 `docs/system-design/order-service/存储设计.md`
3. 扫描 User 实体变更
4. 分析影响范围（数据库、缓存、消息）
5. 设计兼容策略
6. 输出到 `docs/system-design/order-service/数据兼容性设计.md`
```

### 输出
生成文件: `docs/system-design/order-service/数据兼容性设计.md`
包含: 变更清单、兼容策略、迁移计划、回滚预案
```

---

## 代码扫描规则

### 数据库变更识别
```java
// 识别字段变更
@Column(name = "username")  // 新字段名
@Column(name = "name", deprecated = true)  // 老字段标记废弃
```

### 缓存变更识别
```java
// 识别 Key 格式变化
String keyV1 = "user:" + userId;  // 老格式
String keyV2 = "user:v2:" + userId;  // 新格式

// 识别 Value 结构变化
@JsonIgnore  // 老字段不再序列化
@JsonProperty("username")  // 新字段名
```

### 消息变更识别
```java
// 识别版本号字段
private int version = 2;

// 识别兼容逻辑
if (json.has("version") && json.get("version").asInt() == 1) {
    // 兼容老格式
}
```
