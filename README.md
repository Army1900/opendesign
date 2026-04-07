# OpenDesign

设计审查技能集合，基于**已有设计文档**和**项目代码**进行设计梳理和审查，输出标准化的审查报告。

## 概述

本项目包含 3 个设计审查插件：

| 插件 | Skill | 说明 |
|------|-------|------|
| product-design | product-design-review | 产品设计审查 (需求、场景、交互、可用性) |
| system-design | system-design-review | 系统设计审查 (架构、数据、安全、性能、兼容性) |
| code-design | code-execution-efficiency | 代码性能分析 (执行效率、调用链、优化方案) |

## 快速安装

### 方式一：使用安装脚本（推荐）

运行脚本将 skills 链接到 OpenCode 用户级目录：

```bash
# Mac / Linux
./install-skills.sh

# Windows
install-skills.bat
```

**目标路径**：
- Mac/Linux: `~/.config/opencode/skill/`
- Windows: `%USERPROFILE%\.config\opencode\skill\`

### 方式二：手动链接

```bash
# Mac / Linux
ln -s $(pwd)/plugins/product-design/skills/product-design-review ~/.config/opencode/skill/
ln -s $(pwd)/plugins/system-design/skills/system-design-review ~/.config/opencode/skill/
ln -s $(pwd)/plugins/code-design/skills/code-execution-efficiency ~/.config/opencode/skill/

# Windows (以管理员身份运行)
mklink /D "%USERPROFILE%\.config\opencode\skill\product-design-review" "%CD%\plugins\product-design\skills\product-design-review"
mklink /D "%USERPROFILE%\.config\opencode\skill\system-design-review" "%CD%\plugins\system-design\skills\system-design-review"
mklink /D "%USERPROFILE%\.config\opencode\skill\code-execution-efficiency" "%CD%\plugins\code-design\skills\code-execution-efficiency"
```

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
├── system-design/[项目名]/系统设计审查报告.md
└── performance/[入口名]/性能分析报告.md
```

## 项目结构

```
opendesign/
├── install-skills.sh           # Mac/Linux 安装脚本
├── install-skills.bat          # Windows 安装脚本
│
├── plugins/
│   ├── product-design/         # 产品设计审查
│   │   └── skills/
│   │       └── product-design-review/
│   │           ├── SKILL.md
│   │           └── references/
│   │
│   ├── system-design/          # 系统设计审查
│   │   └── skills/
│   │       └── system-design-review/
│   │           ├── SKILL.md
│   │           ├── scripts/    # 文档读取脚本
│   │           │   ├── read-word.py
│   │           │   └── read-pdf.py
│   │           └── references/
│   │
│   └── code-design/            # 代码性能分析
│       └── skills/
│           └── code-execution-efficiency/
│               ├── SKILL.md
│               └── references/
│                   ├── checklists.md
│                   ├── tech-stack-guides.md
│                   └── optimization-patterns.md
│
└── docs/                       # 输出文档目录
```

## 插件详情

### product-design

产品设计审查，支持渐进式审查：

```
Phase 1: 需求分析 → 需求背景
Phase 2: 场景设计 → 使用场景、新手引导、边缘场景、上下文场景
Phase 3: 信息架构 → 站点地图、导航结构、内容层级
Phase 4: 交互设计 → 线框图、用户流程、微交互、状态设计
Phase 5: 可用性   → 提示反馈
```

**触发词**：`审查产品设计`、`梳理设计稿`、`设计评审`

### system-design

系统设计审查，支持渐进式审查：

```
Phase 0: 前置扫描 → 技术栈扫描 (必须首先运行)
Phase 1: 战略层  → 系统上下文、领域模型、服务拆分
Phase 2: 服务层  → 服务定义、服务契约、数据流程
Phase 3: 数据层  → 实体设计、存储设计、缓存设计
Phase 4: 通信层  → API设计、事件设计
Phase 5: 横切层  → 安全设计、性能设计、可用性设计、数据兼容性
Phase 6: 执行层  → 工作拆分
```

**触发词**：`审查系统设计`、`分析架构`、`架构评审`

### code-design

代码性能分析，**必须结合代码**，**方案必须贴合项目**：

**核心原则**：
- 代码驱动：没有代码无法分析
- 全链路视角：不只看单点，要看调用上下文
- 方案贴合：用项目已有组件，不天马行空

**分析维度**：
```
1. 代码层：循环调用、并发锁、内存对象
2. 数据层：SQL 执行计划、事务范围、连接池
3. 缓存层：穿透/击穿/雪崩、大Key、命中率
4. 外部服务：超时重试、熔断降级、连接复用
```

**触发词**：`这个接口慢`、`分析性能`、`SQL太慢`、`高并发`

## 贡献

欢迎提交 Issue 和 Pull Request。

## License

MIT
