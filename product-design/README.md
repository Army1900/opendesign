# Product Design Skills

产品设计审查技能集合。

## 概述

本目录包含产品设计审查 skill，用于分析和梳理设计稿，输出标准化的审查文档。

> **推荐使用**：使用 `product-design-review` 统一入口，支持渐进式审查和模块化选择。

## 使用方式

### 推荐方式：统一入口

使用 `product-design-review` skill：

- **完整审查**：按流程逐步执行所有模块
- **选择性审查**：只执行特定维度分析

### 独立 skill（兼容旧版）

每个独立 skill 接收 HTML 文件夹/压缩包/文档作为输入，输出标准化的 Markdown 审查文档。

## Skill 结构

### 统一入口
| Skill | 用途 |
|-------|------|
| product-design-review | 产品设计审查统一入口 |

### 独立模块（可单独使用或通过统一入口调用）

#### 需求分析
| Skill | 用途 | 输出文件 |
|-------|------|----------|
| requirement-background | 需求背景分析 | 需求背景.md |

#### 场景设计
| Skill | 用途 | 输出文件 |
|-------|------|----------|
| scenario-design-usage | 使用场景分析 | 使用场景.md |
| scenario-design-onboarding | 新手引导分析 | 新手引导.md |
| scenario-design-edge-case | 边缘场景分析 | 边缘场景.md |
| scenario-design-context | 上下文场景分析 | 上下文场景.md |

#### 信息架构
| Skill | 用途 | 输出文件 |
|-------|------|----------|
| information-architecture-sitemap | 站点地图分析 | 站点地图.md |
| information-architecture-navigation | 导航结构分析 | 导航结构.md |
| information-architecture-content-hierarchy | 内容层级分析 | 内容层级.md |

#### 交互设计
| Skill | 用途 | 输出文件 |
|-------|------|----------|
| interaction-wireframe | 线框图分析 | 线框图分析.md |
| interaction-user-flow | 用户流程分析 | 用户流程.md |
| interaction-micro-interaction | 微交互分析 | 微交互.md |
| interaction-state-design | 状态设计分析 | 状态设计.md |

#### 可用性
| Skill | 用途 | 输出文件 |
|-------|------|----------|
| usability-feedback | 提示反馈分析 | 提示反馈.md |

## 输出路径

所有 skill 的输出文档统一存放在：

```
docs/product-design/[项目名]/[输出文档].md
```

## 审查流程

完整的产品设计审查按以下顺序进行：

```
Phase 1: 需求分析
├── 需求背景

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

## 示例

### 使用统一入口

```bash
# 完整审查
claude
用户: "帮我审查这个设计"
文件: design-v1.0.zip

# 选择性审查
用户: "分析下这个设计的导航结构"
用户: "梳理下使用场景"
```

### 使用独立 skill

```bash
# 使用需求背景 skill
用户提供文件： design-v1.0.zip
输出位置: docs/product-design/my-project/需求背景.md
```

## 目录结构

```
product-design/
├── README.md
├── requirement-background/
│   └── SKILL.md
├── scenario-design-usage/
│   └── SKILL.md
├── ... (其他独立 skill 目录)

product-design-review/          # 统一入口（推荐）
├── SKILL.md                    # 主入口文件
└── references/                 # 引用模块
    ├── requirements.md         # 需求分析
    ├── scenarios.md            # 场景设计
    ├── information-architecture.md  # 信息架构
    ├── interaction.md          # 交互设计
    └── usability.md            # 可用性

docs/
└── product-design/
    └── [项目名]/
        ├── 需求背景.md
        ├── 使用场景.md
        └── ... (其他输出文档)
```
