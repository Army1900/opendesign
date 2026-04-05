---
name: product-design-review
description: 产品设计审查的统一入口。当用户提供设计稿、原型文件、HTML文件夹并希望进行设计分析时触发。 TRIGGER 当用户说"帮我审查这个设计"、"分析下这个产品设计"、"梳理设计稿"、"设计评审"、"产品走查"时使用。支持选择性分析（只做某个维度）或完整审查（按流程逐步执行）。
---

# 产品设计审查 Skill

统一的产品设计审查入口，整合需求分析、场景设计、信息架构、交互设计、可用性检查等多个审查维度。

## 审查流程

产品设计审查按以下顺序进行，每个阶段可根据需要跳过：

```
1. 需求分析 → 理解项目背景
2. 场景设计 → 分析使用场景
3. 信息架构 → 梳理内容结构
4. 交互设计 → 宣查交互体验
5. 可用性   → 检查提示反馈
```

## 使用方式

### 方式一：完整审查

用户说"帮我审查这个设计"时，按顺序执行所有模块：

1. 先执行需求背景分析
2. 根据分析结果，询问用户是否继续下一阶段
3. 逐步完成所有审查模块

### 方式二：选择性审查

用户指定特定维度时，只执行对应模块：

| 用户说... | 执行模块 |
|-----------|----------|
| "分析需求背景"、"这个设计解决什么问题" | 需求背景 |
| "梳理使用场景"、"用户怎么用" | 使用场景 |
| "新手怎么上手"、"onboarding" | 新手引导 |
| "边缘场景"、"异常情况" | 边缘场景 |
| "不同环境怎么用" | 上下文场景 |
| "站点地图"、"内容结构" | 站点地图 |
| "导航结构"、"导航清晰吗" | 导航结构 |
| "信息层级"、"视觉层级" | 内容层级 |
| "线框图"、"布局分析" | 线框图分析 |
| "用户流程"、"操作路径" | 用户流程 |
| "微交互"、"交互细节" | 微交互 |
| "状态设计"、"状态完整吗" | 状态设计 |
| "提示反馈"、"提示设计" | 提示反馈 |

## 输入处理

### 接收输入

用户可能提供：
- HTML 文件夹（设计稿导出）
- ZIP 压缩包
- Word/PDF 文档
- 纯文本描述

### HTML 文件夹扫描

```
/design/xxx/
├── index.html        # 入口文件
├── pages/            # 页面文件夹
├── components/       # 组件文件夹
└── assets/           # 资源文件
```

### 信息提取

| 信息类型 | 提取位置 | 提取方式 |
|----------|----------|----------|
| 页面标题 | `<title>` 或 `<h1>` | 文本内容 |
| 功能模块 | 页面区块划分 | DOM 结构 |
| 交互元素 | 按钮、链接、表单 | 元素识别 |
| 文案内容 | 文本节点 | 文本提取 |

## 输出规范

### 输出路径

所有审查文档统一存放在：

```
docs/product-design/[项目名]/[输出文档].md
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

### 第二步: 执行分析

根据用户选择，按需读取 references 目录下的模块指南：

| 模块 | 参考文件 | 用途 |
|------|----------|------|
| 需求背景 | [requirements.md](references/requirements.md) | 分析项目背景和需求 |
| 使用场景 | [scenarios.md](references/scenarios.md) | 分析核心使用场景 |
| 新手引导 | [scenarios.md](references/scenarios.md#新手引导) | 分析新用户引导 |
| 边缘场景 | [scenarios.md](references/scenarios.md#边缘场景) | 分析异常情况处理 |
| 上下文场景 | [scenarios.md](references/scenarios.md#上下文场景) | 分析环境适配 |
| 站点地图 | [information-architecture.md](references/information-architecture.md) | 梳理内容结构 |
| 导航结构 | [information-architecture.md](references/information-architecture.md#导航结构) | 分析导航设计 |
| 内容层级 | [information-architecture.md](references/information-architecture.md#内容层级) | 分析信息优先级 |
| 线框图 | [interaction.md](references/interaction.md) | 分析页面布局 |
| 用户流程 | [interaction.md](references/interaction.md#用户流程) | 梳理操作路径 |
| 微交互 | [interaction.md](references/interaction.md#微交互) | 分析交互细节 |
| 状态设计 | [interaction.md](references/interaction.md#状态设计) | 检查状态覆盖 |
| 提示反馈 | [usability.md](references/usability.md) | 检查提示机制 |

### 第三步: 输出文档

1. 按模板输出分析结果
2. 标注 `[待补充]` 的信息
3. 在文档末尾列出缺失项

## 完整审查流程

当用户选择完整审查时，按以下顺序执行：

### Phase 1: 需求分析
1. 读取 [requirements.md](references/requirements.md)
2. 执行需求背景分析
3. 输出 `docs/product-design/[项目名]/需求背景.md`
4. 询问用户是否继续

### Phase 2: 场景设计
1. 读取 [scenarios.md](references/scenarios.md)
2. 依次执行：
   - 使用场景分析 → `使用场景.md`
   - 新手引导分析 → `新手引导.md`
   - 边缘场景分析 → `边缘场景.md`
   - 上下文场景分析 → `上下文场景.md`
3. 询问用户是否继续

### Phase 3: 信息架构
1. 读取 [information-architecture.md](references/information-architecture.md)
2. 依次执行：
   - 站点地图分析 → `站点地图.md`
   - 导航结构分析 → `导航结构.md`
   - 内容层级分析 → `内容层级.md`
3. 询问用户是否继续

### Phase 4: 交互设计
1. 读取 [interaction.md](references/interaction.md)
2. 依次执行：
   - 线框图分析 → `线框图分析.md`
   - 用户流程分析 → `用户流程.md`
   - 微交互分析 → `微交互.md`
   - 状态设计分析 → `状态设计.md`
3. 询问用户是否继续

### Phase 5: 可用性
1. 读取 [usability.md](references/usability.md)
2. 执行提示反馈分析
3. 输出 `提示反馈.md`

## 快捷触发词

| 触发词 | 执行动作 |
|--------|----------|
| "完整审查" / "全面分析" | 执行所有模块 |
| "快速审查" / "概览" | 只执行需求背景+站点地图 |
| "场景分析" | 执行 Phase 2 所有模块 |
| "架构分析" | 执行 Phase 3 所有模块 |
| "交互分析" | 执行 Phase 4 所有模块 |
