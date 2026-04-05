---
name: system-design-review
description: 系统设计审查的统一入口。当用户提供架构文档、代码库并希望进行系统设计分析时触发。TRIGGER 当用户说"帮我审查系统设计"、"分析下架构设计"、"梳理下系统架构"、"架构评审"时使用。支持选择性分析（只做某个维度）或完整审查（按流程逐步执行）。
---

# 系统设计审查 Skill

统一的系统设计审查入口，整合技术栈扫描、战略设计、服务设计、数据设计、通信设计、横切设计和执行规划等多个审查维度。

## ⚠️ 重要：前置依赖

**在运行其他模块之前，必须先运行技术栈扫描模块**

技术栈扫描识别项目使用的框架和中间件，是其他模块的前置依赖。

## 审查流程

系统设计审查按以下顺序进行：

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

## 使用方式

### 方式一：完整审查

用户说"帮我审查系统设计"时，按顺序执行所有模块：

1. 先执行技术栈扫描（必须）
2. 根据分析结果，询问用户是否继续下一阶段
3. 逐步完成所有审查模块

### 方式二：选择性审查

用户指定特定维度时，只执行对应模块：

| 用户说... | 执行模块 | 前置依赖 |
|-----------|----------|----------|
| "扫描技术栈"、"用了什么框架" | 技术栈扫描 | 无 |
| "系统边界"、"系统上下文" | 系统上下文 | 技术栈 |
| "领域模型"、"DDD模型" | 领域模型 | 技术栈 |
| "服务拆分"、"微服务划分" | 服务拆分 | 技术栈+领域模型 |
| "服务定义"、"服务职责" | 服务定义 | 技术栈 |
| "服务契约"、"接口约定" | 服务契约 | 技术栈 |
| "数据流程"、"数据流向" | 数据流程 | 技术栈 |
| "实体设计"、"数据模型" | 实体设计 | 技术栈 |
| "存储设计"、"数据库设计" | 存储设计 | 技术栈 |
| "缓存设计"、"缓存策略" | 缓存设计 | 技术栈 |
| "API设计"、"接口规范" | API设计 | 技术栈 |
| "事件设计"、"消息设计" | 事件设计 | 技术栈 |
| "安全设计"、"安全机制" | 安全设计 | 技术栈 |
| "性能设计"、"性能指标" | 性能设计 | 技术栈 |
| "可用性设计"、"高可用" | 可用性设计 | 技术栈 |
| "数据兼容性"、"Schema变更" | 数据兼容性 | 技术栈+存储设计 |
| "工作拆分"、"任务分解" | 工作拆分 | 技术栈+服务拆分 |

## 输入处理

### 接收输入

用户可能提供：
- 代码库目录
- 架构设计文档
- 配置文件
- 纯文本描述

### 代码扫描策略

#### 依赖文件
| 语言/框架 | 文件 | 识别内容 |
|-----------|------|----------|
| Java/Maven | pom.xml | dependencies, properties |
| Java/Gradle | build.gradle | dependencies |
| Node.js | package.json | dependencies |
| Python | requirements.txt / pyproject.toml | dependencies |
| Go | go.mod | require |
| .NET | *.csproj | PackageReference |

#### 配置文件
| 文件模式 | 识别内容 |
|----------|----------|
| application*.yml / application*.properties | Spring配置 |
| bootstrap*.yml | Spring Cloud配置 |
| docker-compose*.yml | 容器编排 |
| Dockerfile | 容器构建 |

## 输出规范

### 输出路径

所有审查文档统一存放在：

```
docs/system-design/[项目名]/[输出文档].md
```

### 文档格式

每个输出文档包含：
- 文档生成时间
- 数据来源
- 分析内容
- 信息完整性检查（标注缺失项）

## 执行流程

### 第一步：确定审查范围

询问用户：
1. **项目名称**：用于创建输出目录
2. **审查范围**：完整审查还是选择性审查
3. **如果选择性审查**：需要哪些维度

### 第二步：执行分析

根据用户选择，按需读取 references 目录下的模块指南：

| 模块 | 参考文件 | 用途 |
|------|----------|------|
| 技术栈扫描 | [prerequisites.md](references/prerequisites.md) | 扫描代码识别技术栈 |
| 系统上下文 | [strategy.md](references/strategy.md#系统上下文) | 分析系统边界 |
| 领域模型 | [strategy.md](references/strategy.md#领域模型) | DDD领域划分 |
| 服务拆分 | [strategy.md](references/strategy.md#服务拆分) | 微服务边界 |
| 服务定义 | [service.md](references/service.md#服务定义) | 服务职责定义 |
| 服务契约 | [service.md](references/service.md#服务契约) | 接口约定 |
| 数据流程 | [service.md](references/service.md#数据流程) | 数据流转分析 |
| 实体设计 | [data.md](references/data.md#实体设计) | 数据模型设计 |
| 存储设计 | [data.md](references/data.md#存储设计) | 数据库方案 |
| 缓存设计 | [data.md](references/data.md#缓存设计) | 缓存策略 |
| API设计 | [communication.md](references/communication.md#API设计) | 接口规范 |
| 事件设计 | [communication.md](references/communication.md#事件设计) | 消息设计 |
| 安全设计 | [crosscutting.md](references/crosscutting.md#安全设计) | 安全机制 |
| 性能设计 | [crosscutting.md](references/crosscutting.md#性能设计) | 性能优化 |
| 可用性设计 | [crosscutting.md](references/crosscutting.md#可用性设计) | 高可用策略 |
| 数据兼容性 | [crosscutting.md](references/crosscutting.md#数据兼容性) | Schema变更 |
| 工作拆分 | [execution.md](references/execution.md) | 任务分解 |

### 第三步：输出文档

1. 按模板输出分析结果
2. 标注 `[待补充]` 的信息
3. 在文档末尾列出缺失项

## 完整审查流程

当用户选择完整审查时，按以下顺序执行：

### Phase 0: 前置扫描
1. 读取 [prerequisites.md](references/prerequisites.md)
2. 执行技术栈扫描
3. 输出 `docs/system-design/[项目名]/技术栈.md`
4. **必须完成后才能继续**

### Phase 1: 战略层
1. 读取 [strategy.md](references/strategy.md)
2. 依次执行：
   - 系统上下文分析 → `系统上下文.md`
   - 领域模型分析 → `领域模型.md`
   - 服务拆分分析 → `服务拆分.md`
3. 询问用户是否继续

### Phase 2: 服务层
1. 读取 [service.md](references/service.md)
2. 依次执行：
   - 服务定义分析 → `[服务名]-服务定义.md`
   - 服务契约分析 → `服务契约.md`
   - 数据流程分析 → `数据流程.md`
3. 询问用户是否继续

### Phase 3: 数据层
1. 读取 [data.md](references/data.md)
2. 依次执行：
   - 实体设计分析 → `实体设计.md`
   - 存储设计分析 → `存储设计.md`
   - 缓存设计分析 → `缓存设计.md`
3. 询问用户是否继续

### Phase 4: 通信层
1. 读取 [communication.md](references/communication.md)
2. 依次执行：
   - API设计分析 → `API设计.md`
   - 事件设计分析 → `事件设计.md`
3. 询问用户是否继续

### Phase 5: 横切层
1. 读取 [crosscutting.md](references/crosscutting.md)
2. 依次执行：
   - 安全设计分析 → `安全设计.md`
   - 性能设计分析 → `性能设计.md`
   - 可用性设计分析 → `可用性设计.md`
   - 数据兼容性分析 → `数据兼容性设计.md`
3. 询问用户是否继续

### Phase 6: 执行层
1. 读取 [execution.md](references/execution.md)
2. 执行工作拆分
3. 输出 `工作拆分.md`

## 快捷触发词

| 触发词 | 执行动作 |
|--------|----------|
| "完整审查" / "全面分析" | 执行所有模块 |
| "快速审查" / "概览" | 只执行技术栈+系统上下文+服务拆分 |
| "架构分析" | 执行 Phase 0-2 |
| "数据架构" | 执行 Phase 3 |
| "技术架构" | 执行 Phase 0-4 |
| "技术栈扫描" | 只执行技术栈扫描 |
