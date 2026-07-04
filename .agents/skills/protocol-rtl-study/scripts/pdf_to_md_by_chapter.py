#!/usr/bin/env python3
"""
使用 PyMuPDF 将 PDF 按章节拆分为独立的 Markdown 文件。

支持三种模式：
1. 有 PDF 书签（TOC）→ 按 level 1 书签拆分
2. 无书签但有 "Table of contents" 文本目录 → 解析文本目录并按页码拆分
3. 两者都没有 → 整个文档转为单个 md 文件

每个 PDF 在同级目录下创建同名文件夹，文件夹内只放 md 文件。
"""

import os
import re
import sys
import unicodedata

try:
    import fitz  # PyMuPDF
except ImportError:
    print("[install] 正在安装 PyMuPDF ...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "PyMuPDF"])
    import fitz


def sanitize_filename(name: str) -> str:
    """清理文件名，移除非法字符。"""
    name = unicodedata.normalize("NFKC", name)
    name = re.sub(r'[\\/:*?"<>|]', "_", name)
    name = name.strip(" .")
    if len(name) > 120:
        name = name[:120]
    return name


def extract_text_toc(doc, max_pages=5):
    """从 "Table of contents" 页面解析文本目录。"""
    toc_items = []
    lines_buffer = []
    in_toc = False

    for page_num in range(min(max_pages, len(doc))):
        text = doc[page_num].get_text()
        lines = [line.rstrip() for line in text.split('\n')]

        for line in lines:
            stripped = line.strip()
            if not stripped:
                continue

            # 检测目录开始
            if re.search(r'Table of contents', stripped, re.IGNORECASE):
                in_toc = True
                continue

            if not in_toc:
                continue

            # 跳过页眉页脚常见模式
            if any(p in stripped for p in [
                'Reference manual', 'v1.1', 'v1.0', '2025-', '2024-',
                'User manual', 'Page '
            ]):
                continue
            # 跳过过短的纯设备名/版本行
            if len(stripped) < 5 and not stripped.isdigit():
                continue

            lines_buffer.append(stripped)

    # 解析缓冲的行
    pending_chapter_num = None
    for line in lines_buffer:
        # 如果当前行是纯数字（章节号），暂存
        if re.match(r'^\d+$', line) or re.match(r'^[A-Z]$', line):
            pending_chapter_num = line
            continue

        # 尝试匹配 "标题 ... 页码"
        # 点号可能是 " . " 或连续的 "."
        cleaned = re.sub(r'\s+\.\s+', ' ', line)  # 把 " . . " 换成空格
        cleaned = re.sub(r'\.+', ' ', cleaned)   # 把 "...." 换成空格
        cleaned = re.sub(r'\s+', ' ', cleaned).strip()

        match = re.match(r'^(.+?)\s+(\d+)$', cleaned)
        if match:
            title = match.group(1).strip()
            page = int(match.group(2))

            # 过滤掉目录本身
            if re.search(r'Table of contents', title, re.IGNORECASE):
                continue
            if len(title) < 3:
                continue

            if pending_chapter_num:
                title = f"{pending_chapter_num} {title}"
                pending_chapter_num = None

            toc_items.append((title, page))
        else:
            # 没匹配到页码，可能是多行标题的一部分？暂不考虑
            pending_chapter_num = None

    return toc_items


def extract_by_toc(doc, toc_items, output_dir):
    """根据目录条目拆分 PDF。"""
    total_pages = len(doc)

    for idx, (title, start_page) in enumerate(toc_items):
        start_idx = max(0, start_page - 1)

        if idx + 1 < len(toc_items):
            end_idx = toc_items[idx + 1][1] - 1
        else:
            end_idx = total_pages

        texts = []
        for page_num in range(start_idx, min(end_idx, total_pages)):
            page = doc[page_num]
            text = page.get_text()
            if text.strip():
                texts.append(text)

        if not texts:
            continue

        md_content = f"# {title}\n\n" + "\n\n".join(texts)
        safe_title = sanitize_filename(title)
        file_name = f"{idx + 1:03d}_{safe_title}.md"
        file_path = os.path.join(output_dir, file_name)

        with open(file_path, "w", encoding="utf-8") as f:
            f.write(md_content)

        print(f"[done] {title} -> {file_name} ({end_idx - start_idx} pages)")

    return len(toc_items)


def extract_whole(doc, output_dir, base_name):
    """整本转成一个 Markdown 文件。"""
    texts = []
    for page in doc:
        text = page.get_text()
        if text.strip():
            texts.append(text)

    md_content = f"# {base_name}\n\n" + "\n\n".join(texts)
    file_path = os.path.join(output_dir, f"{base_name}.md")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(md_content)

    print(f"[done] 整本输出 -> {file_path} ({len(doc)} pages)")
    return 1


def process_pdf(pdf_path: str):
    """处理单个 PDF。"""
    pdf_path = os.path.abspath(pdf_path)
    if not os.path.isfile(pdf_path):
        print(f"[error] 文件不存在: {pdf_path}")
        return

    base_name = os.path.splitext(os.path.basename(pdf_path))[0]
    parent_dir = os.path.dirname(pdf_path)
    output_dir = os.path.join(parent_dir, base_name)
    os.makedirs(output_dir, exist_ok=True)

    doc = fitz.open(pdf_path)

    # 尝试 1：PDF 书签
    toc = doc.get_toc()
    level1_items = [(title, page) for lvl, title, page in toc if lvl == 1]

    if level1_items:
        print(f"[info] 检测到 {len(level1_items)} 个 level 1 书签，按书签拆分...")
        count = extract_by_toc(doc, level1_items, output_dir)
    else:
        # 尝试 2：文本目录
        text_toc = extract_text_toc(doc)
        if text_toc:
            print(f"[info] 未检测到书签，从 Contents 页面解析到 {len(text_toc)} 个章节，按目录拆分...")
            count = extract_by_toc(doc, text_toc, output_dir)
        else:
            # 回退：整本输出
            print(f"[warning] 未检测到书签或文本目录，整本输出...")
            count = extract_whole(doc, output_dir, base_name)

    doc.close()
    print(f"\n[finish] 共生成 {count} 个文件，输出目录: {output_dir}")


def main():
    if len(sys.argv) < 2:
        pdf_path = os.path.expanduser("~/Documents/reference/ethernet/8023-2022.pdf")
        if os.path.isfile(pdf_path):
            process_pdf(pdf_path)
        else:
            print("用法: python3 pdf_to_md_by_chapter.py <pdf_path> [pdf_path2 ...]")
    else:
        for pdf_path in sys.argv[1:]:
            process_pdf(pdf_path)


if __name__ == "__main__":
    main()
