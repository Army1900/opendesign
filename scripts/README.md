# 文档读取脚本

用于读取 Word 和 PDF 格式的设计文档。

## 安装依赖

```bash
pip install python-docx PyMuPDF
```

## read-word.py - 读取 Word 文档

```bash
# 直接输出到终端
python scripts/read-word.py design.docx

# 输出到文件
python scripts/read-word.py design.docx -o output.md

# 指定格式
python scripts/read-word.py design.docx --format markdown
```

## read-pdf.py - 读取 PDF 文档

```bash
# 直接输出到终端
python scripts/read-pdf.py design.pdf

# 输出到文件
python scripts/read-pdf.py design.pdf -o output.md

# 指定页码范围
python scripts/read-pdf.py design.pdf --pages 1-10
```

## 在 Skill 中的使用方式

方式一：由 Claude 调用脚本
```bash
# Claude 执行
python scripts/read-word.py /path/to/design.docx
```

方式二：用户手动转换后提供
```bash
# 用户先转换
python scripts/read-word.py design.docx -o design.md

# 然后告诉 Claude
"设计文档在 design.md"
```
