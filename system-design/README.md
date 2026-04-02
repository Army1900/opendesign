# System Design Skills

系统设计审查技能集合

## 概述

本目录包含 15 个系统设计审查 skill, 用于分析和梳理架构文档,输出标准化的审查文档。

## 使用方式

每个 skill 接收 HTML 文件夹/压缩包/文档作为输入,输出标准化的 Markdown 审查文档。

## ⚠️ 重要: 技术栈扫描

**在运行其他 skill 之前, 必须先运行 `tech-stack` skill**

`tech-stack` skill 扫描代码库识别技术栈, 是其他 skill 的前置依赖。 依赖它的 skill:
- service-decomposition
- cache-design
- api-design
- security-design
- data-flow
- performance-design
- availability-design

## Skill 列表

### 前置依赖 (必须先运行)
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| tech-stack | 扫描代码识别技术栈 | 技术栈.md |

### 战略层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| system-context | 系统上下文和边界分析 | 系统上下文.md |
| domain-model | 领域模型和子域划分 | 领域模型.md |
| service-decomposition | 服务拆分和边界定义 | 服务拆分.md |

### 服务层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| service-definition | 服务职责和能力定义 | [服务名]-服务定义.md |
| service-contract | 服务契约和接口约定 | 服务契约.md |
| data-flow | 数据流转过程分析 | 数据流程.md |

### 数据层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| entity-design | 实体和值对象设计 | 实体设计.md |
| storage-design | 存储选型和表结构设计 | 存储设计.md |
| cache-design | 缓存策略和失效设计 | 缓存设计.md |

### 通信层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| api-design | API接口规范设计 | API设计.md |
| event-design | 事件和消息队列设计 | 事件设计.md |

### 横切层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| security-design | 认证授权和数据安全 | 安全设计.md |
| performance-design | 性能目标和优化策略 | 性能设计.md |
| availability-design | 高可用和容灾策略 | 可用性设计.md |
| compatibility-design | 兼容性场景和问题处理 | 兼容性设计.md |

### 执行层
| Skill | 说明 | 输出文档 |
|-------|------|----------|
| work-breakdown | 工作项拆分和排期规划 | 工作拆分.md |

## 输出路径

```
docs/system-design/[项目名]/[文档名].md
```

## 目录结构

```
system-design/
├── README.md
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
└── availability-design/SKILL.md
```
