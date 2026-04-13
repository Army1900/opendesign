# 文档读取工具

## 支持的文档类型

| 文档类型 | 读取方式 | 脚本路径 |
|----------|----------|----------|
| PDF | `scripts/read-pdf.py` | 支持全文读取和指定页码范围 |
| Word (.docx) | `scripts/read-word.py` | 支持全文读取 |
| Markdown | 直接使用 Read 工具 | - |
| HTML | 直接使用 Read 工具 | - |

## 使用方法

### 读取 PDF

```bash
# 读取完整 PDF
python scripts/read-pdf.py design.pdf

# 指定页码范围
python scripts/read-pdf.py design.pdf --pages 1-10

# 输出到文件
python scripts/read-pdf.py design.pdf -o output.md
```

### 读取 Word

```bash
python scripts/read-word.py prd.docx
```

## 依赖安装

```bash
pip install PyMuPDF python-docx
```

## HTML 文件夹扫描

设计稿导出的 HTML 文件夹结构：

```
/design/xxx/
├── index.html        # 入口文件
├── pages/            # 页面文件夹
├── components/       # 组件文件夹
└── assets/           # 资源文件
```

信息提取方式：

| 信息类型 | 提取位置 | 提取方式 |
|----------|----------|----------|
| 页面标题 | `<title>` 或 `<h1>` | 文本内容 |
| 功能模块 | 页面区块划分 | DOM 结构 |
| 交互元素 | 按钮、链接、表单 | 元素识别 |
| 文案内容 | 文本节点 | 文本提取 |
