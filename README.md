# OpenDesign

设计审查技能集合, 用于分析和梳理产品设计、系统设计文档, 输出标准化的审查文档.

## 概述

本项目包含 **30 个设计审查 skill**, 分为两大类:

| 类别 | Skill 数量 | 说明 |
|------|-----------|------|
| product-design | 13 | 产品设计审查 (需求、场景、交互、可用性) |
| system-design | 17 | 系统设计审查 (架构、数据、安全、性能、兼容性、任务拆分) |

## 目录结构

```
opendesign/
├── product-design/                # 产品设计 skills
│   ├── requirement-background/     # 需求背景
│   ├── scenario-design-usage/     # 使用场景
│   ├── scenario-design-onboarding/# 新手引导
│   ├── scenario-design-edge-case/ # 边缘场景
│   ├── scenario-design-context/   # 上下文场景
│   ├── information-architecture-sitemap/    # 站点地图
│   ├── information-architecture-navigation/ # 导航结构
│   ├── information-architecture-content-hierarchy/ # 内容层级
│   ├── interaction-wireframe/     # 线框图
│   ├── interaction-user-flow/    # 用户流程
│   ├── interaction-micro-interaction/ # 微交互
│   ├── interaction-state-design/ # 状态设计
│   └── usability-feedback/       # 提示反馈
│
├── system-design/                 # 系统设计 skills
│   ├── tech-stack/                # 技术栈扫描 (前置依赖)
│   ├── system-context/            # 系统上下文
│   ├── domain-model/              # 领域模型
│   ├── service-decomposition/     # 服务拆分
│   ├── service-definition/        # 服务定义
│   ├── service-contract/          # 服务契约
│   ├── data-flow/                 # 数据流程
│   ├── entity-design/             # 实体设计
│   ├── storage-design/            # 存储设计
│   ├── cache-design/              # 缓存设计
│   ├── api-design/                # API设计
│   ├── event-design/              # 事件设计
│   ├── security-design/           # 安全设计
│   ├── performance-design/        # 性能设计
│   ├── availability-design/       # 可用性设计
│   ├── compatibility-design/      # 兼容性设计
│   └── work-breakdown/            # 工作拆分
│
└── docs/                          # 输出文档目录
    ├── product-design/[项目名]/
    └── system-design/[项目名]/
```

## 使用方式

### 1. 产品设计审查

当用户提供设计稿或文档时, 触发对应的 skill:

```
用户: "帮我梳理这个设计的需求背景"
→ 触发 requirement-background skill
→ 输出 docs/product-design/[项目名]/需求背景.md
```

### 2. 系统设计审查

**重要**: 先运行 `tech-stack` skill 扫描技术栈

```
第一步: 扫描技术栈
用户: "扫描下技术栈"
→ 触发 tech-stack skill
→ 输出 docs/system-design/[项目名]/技术栈.md

第二步: 运行其他 skill
用户: "分析下缓存设计"
→ 触发 cache-design skill (会读取技术栈.md)
→ 输出 docs/system-design/[项目名]/缓存设计.md
```

## Skill 依赖关系

### product-design (无依赖)

所有 product-design skill 可独立运行.

### system-design

```
tech-stack (前置依赖)
    ├── service-decomposition
    ├── cache-design
    ├── api-design
    ├── security-design
    ├── data-flow
    ├── performance-design
    └── availability-design

无依赖的 skill:
    - system-context
    - domain-model
    - service-definition
    - service-contract
    - entity-design
    - storage-design
    - event-design
```

## 输入格式

每个 skill 接收以下输入:
- HTML 文件夹 (设计稿导出)
- ZIP 压缩包
- Word/PDF 文档
- 纯文本描述

## 输出格式

所有 skill 输出标准化的 Markdown 文档, 包含:
- 结构化的表格
- 清晰的层级
- 缺失项标注 `[待补充]`
- 信息完整性检查清单

## 快速开始

```bash
# 1. 克隆仓库
git clone git@github.com:Army1900/opendesign.git

# 2. 在 Claude Code 中使用
# 直接告诉 Claude 你要做什么, 会自动触发对应 skill
```

## 贡献

欢迎提交 Issue 和 Pull Request.

## License

MIT
