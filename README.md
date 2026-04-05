# OpenDesign

设计审查技能集合，用于分析和梳理产品设计、系统设计文档，输出标准化的审查文档。

## 概述

本项目是一个 **Claude Code 插件市场**，包含 3 个插件、共 31 个设计审查 skill：

| 插件 | Skill 数量 | 说明 |
|------|-----------|------|
| product-design-review | 13 | 产品设计审查 (需求、场景、交互、可用性) |
| system-design-review | 17 | 系统设计审查 (架构、数据、安全、性能、兼容性、任务拆分) |
| code-design | 1 | 代码设计分析 (执行效率、性能优化) |

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
│   │           └── references/
│   │
│   └── code-design/            # 代码设计分析插件
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── code-execution-efficiency/
│               └── SKILL.md
│
└── docs/                       # 输出文档目录
    ├── product-design/[项目名]/
    └── system-design/[项目名]/
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

代码执行效率分析：

- 调用链路分析
- SQL 性能分析
- 接口性能分析
- 日志分析
- 优化方案输出

**使用示例：**
```
用户: "这个接口慢，帮我分析下"
→ 执行完整的性能分析流程
```

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

每个 skill 接收以下输入：
- HTML 文件夹 (设计稿导出)
- ZIP 压缩包
- Word/PDF 文档
- 代码库目录
- 纯文本描述

## 输出格式

所有 skill 输出标准化的 Markdown 文档，包含：
- 结构化的表格
- 清晰的层级
- 缺失项标注 `[待补充]`
- 信息完整性检查清单

## 贡献

欢迎提交 Issue 和 Pull Request。

## License

MIT
