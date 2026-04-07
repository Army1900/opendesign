# OpenDesign

设计审查技能集合，基于**已有设计文档**和**项目代码**进行设计梳理和审查，输出标准化的审查报告。

## 概述

本项目是一个 **Claude Code 插件市场**，包含 3 个插件、共 31 个设计审查 skill：

| 插件 | Skill 数量 | 说明 |
|------|-----------|------|
| product-design-review | 13 | 产品设计审查 (需求、场景、交互、可用性) |
| system-design-review | 17 | 系统设计审查 (架构、数据、安全、性能、兼容性、任务拆分) |
| code-design | 1 | 代码设计分析 (执行效率、性能优化) |

## 核心原则

### 输入优先级

```
1. 首先阅读已有的设计文档（Word/PDF/MD/设计稿）
2. 然后结合项目代码实现进行验证和补充
3. 输出：对现有设计的"梳理 + 审查 + 补充建议"
```

**不要从零开始设计**，而是基于现有材料进行梳理和审查。

### 输出格式

所有审查输出为**单一结构化文档**：

```
docs/
├── product-design/[项目名]/产品设计审查报告.md
└── system-design/[项目名]/系统设计审查报告.md
```

### 文档读取

支持多种格式的文档读取，脚本位于各 skill 的 `scripts/` 目录：

| 文档类型 | 读取脚本 |
|----------|----------|
| Word (.docx) | `scripts/read-word.py` |
| PDF | `scripts/read-pdf.py` |
| Markdown | 直接使用 Read 工具 |
| HTML | 直接使用 Read 工具 |
| 设计稿 | 导出为 HTML 后使用 Read 工具 |

## 安装

### 方式一：添加插件市场

```bash
# 添加市场
claude plugin marketplace add OpenDesign/opendesign

# 查看可用插件
claude plugin marketplace list

# 安装插件
claude plugin install product-design-review@opendesign
claude plugin install system-design-review@opendesign
claude plugin install code-design@opendesign
```

### 方式二：本地开发安装

```bash
# 克隆仓库
git clone git@github.com:OpenDesign/opendesign.git

# 添加本地市场
claude plugin marketplace add ./opendesign

# 安装插件
claude plugin install product-design-review@opendesign
```

## 插件结构

```
opendesign/
├── .claude-plugin/
│   └── marketplace.json        # 市场定义文件
│
├── plugins/
│   ├── product-design-review/  # 产品设计审查插件
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       └── product-design-review/
│   │           ├── SKILL.md
│   │           └── references/
│   │
│   ├── system-design-review/   # 系统设计审查插件
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       └── system-design-review/
│   │           ├── SKILL.md
│   │           ├── scripts/    # 文档读取脚本
│   │           │   ├── read-word.py
│   │           │   └── read-pdf.py
│   │           └── references/
│   │
│   └── code-design/            # 代码设计分析插件
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── code-execution-efficiency/
│               ├── SKILL.md
│               └── references/
│                   ├── checklists.md           # 性能检查项清单
│                   ├── tech-stack-guides.md    # 技术栈分析指南
│                   └── optimization-patterns.md # 优化模式速查
│
└── docs/                       # 输出文档目录
    ├── product-design/[项目名]/产品设计审查报告.md
    ├── system-design/[项目名]/系统设计审查报告.md
    └── performance/[入口名]/性能分析报告.md
```

## 插件详情

### product-design-review

产品设计审查统一入口，支持渐进式审查：

```
Phase 1: 需求分析
└── 需求背景分析

Phase 2: 场景设计
├── 使用场景
├── 新手引导
├── 边缘场景
└── 上下文场景

Phase 3: 信息架构
├── 站点地图
├── 导航结构
└── 内容层级

Phase 4: 交互设计
├── 线框图分析
├── 用户流程
├── 微交互
└── 状态设计

Phase 5: 可用性
└── 提示反馈
```

**使用示例：**
```
用户: "帮我审查这个产品设计"
→ 执行完整审查流程

用户: "梳理下这个设计的导航结构"
→ 只执行导航结构分析
```

### system-design-review

系统设计审查统一入口，支持渐进式审查：

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

**使用示例：**
```
用户: "帮我审查系统设计"
→ 执行完整审查流程

用户: "扫描下技术栈"
→ 只执行技术栈扫描

用户: "分析下缓存设计"
→ 只执行缓存设计分析
```

### code-design

代码执行效率分析，**必须结合代码**，**方案必须贴合项目**：

**核心原则**：
- 代码驱动：没有代码无法分析，先读取代码再给方案
- 全链路视角：不只看单点，要看调用上下文（N+1、事务、并发）
- 方案贴合：用项目已有组件解决，不天马行空

**分析维度**：
```
1. 代码层：循环调用、并发锁、内存对象
2. 数据层：SQL 执行计划、事务范围、连接池
3. 缓存层：穿透/击穿/雪崩、大 Key、命中率
4. 外部服务：超时重试、熔断降级、连接复用
```

**使用示例：**
```
用户: "这个接口慢，帮我分析下"
      "代码在 src/main/java/.../OrderController.java"

→ 读取代码 → 追踪调用链 → 识别瓶颈 → 给出贴合项目的方案（带代码示例）
```

**输出文档**：`docs/performance/[入口名]/性能分析报告.md`

## Skill 依赖关系

### product-design-review (无依赖)

所有模块可独立运行。

### system-design-review

```
tech-stack (前置依赖 - 必须首先运行)
    ├── service-decomposition
    ├── cache-design
    ├── api-design
    ├── security-design
    ├── data-flow
    ├── performance-design
    └── availability-design

无依赖的模块:
    - system-context
    - domain-model
    - service-definition
    - service-contract
    - entity-design
    - storage-design
    - event-design
```

## 输入格式

每个 skill 接收以下输入（按优先级排序）：

1. **设计文档**（优先）：Word/PDF/Markdown 格式的设计文档
2. **设计稿/原型**：HTML 文件夹、图片、Figma 导出
3. **代码库目录**：用于验证设计实现
4. **纯文本描述**：用户口述的需求和设计思路

## 输出格式

所有 skill 输出**单一结构化的 Markdown 文档**，包含：
- 文档头部：生成时间、数据来源、审查范围
- 结构化的章节内容
- 缺失项标注 `[待补充]`
- 附录 A：待补充项清单
- 附录 B：设计与实现一致性检查

## 贡献

欢迎提交 Issue 和 Pull Request。

## License

MIT
