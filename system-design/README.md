# System Design Skills

系统设计审查技能集合。

## 概述

本目录包含系统设计审查 skill，用于分析和梳理架构文档，输出标准化的审查文档。

> **推荐使用**：使用 `system-design-review` 统一入口，支持渐进式审查和模块化选择。

## ⚠️ 重要: 技术栈扫描

**在运行其他 skill 之前，必须先运行 `tech-stack` skill**

`tech-stack` skill 扫描代码库识别技术栈，是其他 skill 的前置依赖。

## 使用方式

### 推荐方式：统一入口

使用 `system-design-review` skill：

- **完整审查**：按流程逐步执行所有模块
- **选择性审查**：只执行特定维度分析

### 独立 skill（兼容旧版）

每个独立 skill 接收代码库/架构文档作为输入，输出标准化的 Markdown 审查文档。

## Skill 结构

### 统一入口（推荐）
| Skill | 用途 |
|-------|------|
| system-design-review | 系统设计审查统一入口 |

### 独立模块（可单独使用或通过统一入口调用）

#### 前置依赖
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| tech-stack | 扫描代码识别技术栈 | 技术栈.md |

#### 战略层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| system-context | 系统上下文和边界分析 | 系统上下文.md |
| domain-model | 领域模型和子域划分 | 领域模型.md |
| service-decomposition | 服务拆分和边界定义 | 服务拆分.md |

#### 服务层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| service-definition | 服务职责和能力定义 | [服务名]-服务定义.md |
| service-contract | 服务契约和接口约定 | 服务契约.md |
| data-flow | 数据流转过程分析 | 数据流程.md |

#### 数据层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| entity-design | 实体和值对象设计 | 实体设计.md |
| storage-design | 存储选型和表结构设计 | 存储设计.md |
| cache-design | 缓存策略和失效设计 | 缓存设计.md |

#### 通信层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| api-design | API接口规范设计 | API设计.md |
| event-design | 事件和消息队列设计 | 事件设计.md |

#### 横切层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| security-design | 认证授权和数据安全 | 安全设计.md |
| performance-design | 性能目标和优化策略 | 性能设计.md |
| availability-design | 高可用和容灾策略 | 可用性设计.md |
| data-compatibility | 数据格式兼容性设计 | 数据兼容性设计.md |

#### 执行层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| work-breakdown | 工作项拆分和排期规划 | 工作拆分.md |

## 输出路径

所有 skill 的输出文档统一存放在：

```
docs/system-design/[项目名]/[文档名].md
```

## 审查流程

完整的系统设计审查按以下顺序进行：

```
Phase 0: 前置扫描
└── 技术栈扫描 ← 必须首先运行

Phase 1: 战略层
├── 系统上下文
├── 领域模型
└── 服务拆分

Phase 2: 服务层
├── 服务定义
├── 服务契约
└── 数据流程

Phase 3: 数据层
├── 实体设计
├── 存储设计
└── 缓存设计

Phase 4: 通信层
├── API设计
└── 事件设计

Phase 5: 横切层
├── 安全设计
├── 性能设计
├── 可用性设计
└── 数据兼容性

Phase 6: 执行层
└── 工作拆分
```

## 示例

### 使用统一入口

```bash
# 完整审查
claude
用户: "帮我审查系统设计"
项目: /project/ecommerce-service/

# 选择性审查
用户: "分析下这个系统的缓存设计"
用户: "梳理下服务拆分"
```

### 使用独立 skill

```bash
# 使用技术栈 skill
用户提供目录： /project/ecommerce-service/
输出位置: docs/system-design/ecommerce-service/技术栈.md
```

## 目录结构

```
system-design/
├── README.md
├── tech-stack/SKILL.md
├── system-context/SKILL.md
├── domain-model/SKILL.md
├── service-decomposition/SKILL.md
├── service-definition/SKILL.md
├── service-contract/SKILL.md
├── data-flow/SKILL.md
├── entity-design/SKILL.md
├── storage-design/SKILL.md
├── cache-design/SKILL.md
├── api-design/SKILL.md
├── event-design/SKILL.md
├── security-design/SKILL.md
├── performance-design/SKILL.md
├── availability-design/SKILL.md
├── data-compatibility/SKILL.md
└── work-breakdown/SKILL.md

system-design-review/           # 统一入口（推荐）
├── SKILL.md                    # 主入口文件
└── references/                 # 引用模块
    ├── prerequisites.md        # 前置扫描（技术栈）
    ├── strategy.md             # 战略层
    ├── service.md              # 服务层
    ├── data.md                 # 数据层
    ├── communication.md        # 通信层
    ├── crosscutting.md         # 横切层
    └── execution.md            # 执行层

docs/
└── system-design/
    └── [项目名]/
        ├── 技术栈.md
        ├── 系统上下文.md
        └── ... (其他输出文档)
```
