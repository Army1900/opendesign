# 文档读取工具

## 支持的文档类型

| 文档类型 | 读取方式 | 脚本路径 |
|----------|----------|----------|
| PDF | `scripts/read-pdf.py` | 支持全文读取和指定页码范围 |
| Word (.docx) | `scripts/read-word.py` | 支持全文读取 |
| Markdown | 直接使用 Read 工具 | - |
| HTML | 直接使用 Read 工具 | - |
| 设计稿 | 导出为 HTML 后使用 Read 工具 | - |

## 使用方法

```bash
# 读取 Word 文档
python scripts/read-word.py design.docx

# 读取 PDF 文档
python scripts/read-pdf.py design.pdf

# 指定页码范围
python scripts/read-pdf.py design.pdf --pages 1-10

# 输出到文件
python scripts/read-word.py design.docx -o output.md
```

## 代码扫描策略

用于验证和补充设计文档中的描述。

### 依赖文件

| 语言/框架 | 文件 | 识别内容 |
|-----------|------|----------|
| Java/Maven | pom.xml | dependencies, properties |
| Java/Gradle | build.gradle | dependencies |
| Node.js | package.json | dependencies |
| Python | requirements.txt / pyproject.toml | dependencies |
| Go | go.mod | require |
| .NET | *.csproj | PackageReference |

### 配置文件

| 文件模式 | 识别内容 |
|----------|----------|
| application*.yml / application*.properties | Spring配置 |
| bootstrap*.yml | Spring Cloud配置 |
| docker-compose*.yml | 容器编排 |
| Dockerfile | 容器构建 |
