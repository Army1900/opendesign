#!/usr/bin/env python3
"""
PDF 文档读取脚本

用法:
    python read-pdf.py <file.pdf>
    python read-pdf.py <file.pdf> --output output.txt
    python read-pdf.py <file.pdf> --pages 1-10
"""

import sys
import argparse
from pathlib import Path


def read_pdf(file_path: str, start_page: int = None, end_page: int = None) -> str:
    """读取 PDF 文档内容"""
    try:
        import fitz  # PyMuPDF
    except ImportError:
        print("错误: 需要安装 PyMuPDF")
        print("运行: pip install PyMuPDF")
        sys.exit(1)

    doc = fitz.open(file_path)
    result = [f"# {Path(file_path).stem}\n"]

    total_pages = len(doc)
    start = (start_page or 1) - 1  # 转为 0-indexed
    end = end_page or total_pages

    for page_num in range(start, min(end, total_pages)):
        page = doc[page_num]
        text = page.get_text()
        if text.strip():
            result.append(f"\n## 第 {page_num + 1} 页\n")
            result.append(text)

    doc.close()
    return "\n".join(result)


def main():
    parser = argparse.ArgumentParser(description="读取 PDF 文档")
    parser.add_argument("file", help="PDF 文件路径")
    parser.add_argument("--output", "-o", help="输出文件路径")
    parser.add_argument("--pages", "-p", help="页码范围 (如: 1-10)")

    args = parser.parse_args()

    if not Path(args.file).exists():
        print(f"错误: 文件不存在: {args.file}")
        sys.exit(1)

    start_page, end_page = None, None
    if args.pages:
        try:
            parts = args.pages.split("-")
            start_page = int(parts[0])
            end_page = int(parts[1]) if len(parts) > 1 else None
        except ValueError:
            print(f"错误: 无效的页码范围: {args.pages}")
            sys.exit(1)

    content = read_pdf(args.file, start_page, end_page)

    if args.output:
        Path(args.output).write_text(content, encoding="utf-8")
        print(f"已输出到: {args.output}")
    else:
        print(content)


if __name__ == "__main__":
    main()
