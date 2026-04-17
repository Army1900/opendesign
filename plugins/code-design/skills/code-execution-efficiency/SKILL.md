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

## 核心原则

### 代码驱动分析

先读代码再分析，从入口追踪调用链（入口 → Service → DAO → SQL），结合上下文（循环？事务？并发？）给出针对性方案，禁止不看代码空谈理论。

### 方案贴合项目

先看项目有什么技术栈，用现有能力解决问题。项目用 Spring Boot + Redis + MySQL 就用 Redis 队列 + 线程池，不要建议引入 Kafka。

### 全链路视角

分析 SQL 不只看 SQL 本身，还要看调用上下文（循环？N+1？）、事务范围（锁持有时间？）、并发场景（热点？竞争？）、缓存（命中率？）。

## 输入优先级

```
1. 入口代码路径（必须）—— 没有代码无法分析
2. 性能问题描述 —— 响应时间、QPS、错误率
3. 相关配置路径 —— 连接池、缓存、超时配置
4. 日志/监控 —— 问题时间段日志、监控数据
```

## 执行流程

1. **确认技术栈**：读取项目配置文件。自定义配置模板见 [technology-stack-template.md](references/technology-stack-template.md)
   - 优先读取：CLAUDE.md 技术栈章节 → `.claude/performance-tech-stack.md` → application.yml / pom.xml → 询问用户
2. **读取代码**：从入口开始，逐层追踪调用链
3. **绘制调用链**：标注每层耗时，识别瓶颈点
4. **收集 SQL 上下文**（当涉及 SQL 分析时触发）：
   - 如果用户直接提供了 SQL，或调用链中发现了 SQL 语句，**必须要求用户提供以下信息**才能继续分析：
     - **表结构（DDL）**：`SHOW CREATE TABLE` 输出或建表语句，用于判断索引、字段类型、分区等信息
     - **数据量**：各表的行数（`SELECT COUNT(*)` 或近似值），以及增长趋势（如日增多少）
   - 将收集到的表结构和数据量记录到分析报告中，作为后续索引优化、执行计划分析的依据
5. **检查项匹配**：对照 [checklists.md](references/checklists.md) 逐项检查
6. **追溯问题引入**：对问题代码执行 git blame 定位引入时间，方法见 [git-blame-guide.md](references/git-blame-guide.md)
7. **输出方案**：贴合技术栈，带代码示例，量化收益，评估成本

## 输出规范

路径：`docs/performance/[分析对象]/性能分析报告.md`

每个问题包含：调用链路 → 问题清单（含引入时间）→ 详细分析 → 优化方案（推荐+备选）→ 验证方法 → 检查项结果 → 优化优先级。

完整报告模板和示例见 [output-template.md](references/output-template.md)

## 使用示例

| 用户输入 | 分析路径 |
|----------|----------|
| "/api/order/create 响应2秒，代码在 OrderController.java" | 读取代码 → 追踪调用链 → 识别瓶颈 → 输出方案 |
| "UserService.batchImport 处理10万条数据很慢" | 读取代码 → 分析批处理逻辑 → 检查内存和IO → 输出方案 |
| "SELECT * FROM orders WHERE DATE(create_time)='2024-01-01' 慢" | 分析SQL → 找调用代码 → 看上下文 → 输出索引+代码改动 |
| "InventoryService.deduct 高并发超卖" | 读取代码 → 分析锁机制 → 检查竞态条件 → 输出并发方案 |

## References

| 参考 | 用途 |
|------|------|
| [checklists.md](references/checklists.md) | 检查项清单（代码层/数据层/缓存层/外部服务） |
| [tech-stack-guides.md](references/tech-stack-guides.md) | 技术栈分析指南（MySQL/Redis/Feign 等） |
| [optimization-patterns.md](references/optimization-patterns.md) | 优化模式速查（SQL/缓存/并发/异步） |
| [output-template.md](references/output-template.md) | 完整报告模板和示例 |
| [git-blame-guide.md](references/git-blame-guide.md) | 问题引入时间追溯方法 |
| [technology-stack-template.md](references/technology-stack-template.md) | 技术栈信息收集模板 |

## 注意事项

1. **必须有代码**：没有代码无法分析，先问用户要代码路径
2. **全链路视角**：不只看单点，要看调用上下文
3. **方案贴合**：用现有组件，不天马行空
4. **给出代码**：优化方案要带针对当前项目的代码示例
5. **量化收益**：每个方案说明预期收益
6. **评估成本**：说明改动量和风险
7. **SQL 分析必须有表结构和数据量**：涉及 SQL 性能分析时，必须先拿到表 DDL 和数据量，禁止在没有表结构信息的情况下给出索引优化建议
