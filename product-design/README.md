# Product Design Skills

产品设计审查技能集合，## 概述

本目录包含 13 个产品设计审查 skill，用于分析和梳理设计稿，输出标准化的审查文档。

## 使用方式

每个 skill 接收 HTML 文件夹/压缩包/文档作为输入，输出标准化的 Markdown 审查文档。

## Skill 列表

| Skill | 用途 | 输出文件 |
|-------|------|----------|
| requirement-background | 需求背景分析 | 需求背景.md |
| scenario-design-usage | 使用场景分析 | 使用场景.md |
| scenario-design-onboarding | 新手引导分析 | 新手引导.md |
| scenario-design-edge-case | 边缘场景分析 | 边缘场景.md |
| scenario-design-context | 上下文场景分析 | 上下文场景.md |
| information-architecture-sitemap | 站点地图分析 | 站点地图.md |
| information-architecture-navigation | 导航结构分析 | 导航结构.md |
| information-architecture-content-hierarchy | 内容层级分析 | 内容层级.md |
| interaction-wireframe | 线框图分析 | 线框图分析.md |
| interaction-user-flow | 用户流程分析 | 用户流程.md |
| interaction-micro-interaction | 微交互分析 | 微交互.md |
| interaction-state-design | 状态设计分析 | 状态设计.md |
| usability-feedback | 提示反馈分析 | 提示反馈.md |

## 输出路径

所有 skill 的输出文档统一存放在：

```
docs/product-design/[项目名]/[输出文档].md
```

## 示例

```bash
# 使用需求背景 skill
claude

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
├── ... (其他 skill 目录)
└── usability-feedback/
    └── SKILL.md

docs/
└── product-design/
    └── [项目名]/
        ├── 需求背景.md
        ├── 使用场景.md
        └── ... (其他输出文档)
```
