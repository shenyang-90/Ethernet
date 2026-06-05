#!/usr/bin/env python3
"""Convert REWORK task files from plain Markdown to JSON-frontmatter format."""
import os
import re
import json
import glob

TASK_DIR = "/root/.openclaw/workspace/sandbox/ethernet/ProjectMgmt/Phases/PAD/Tasks"

def parse_task_file(path):
    """Parse a REWORK task markdown file and extract metadata."""
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Extract title
    title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else ""

    # Extract metadata fields from bold patterns
    meta = {}

    # Task ID
    m = re.search(r'\*\*任务ID\*\*:\s*(\S+)', content)
    meta["task_id"] = m.group(1) if m else ""

    # Owner
    m = re.search(r'\*\*负责人\*\*:\s*(.+?)(?:\n|$)', content)
    meta["owner"] = m.group(1).strip() if m else ""

    # Status
    m = re.search(r'\*\*状态\*\*:\s*(.+?)(?:\n|$)', content)
    status_text = m.group(1).strip() if m else ""
    # Normalize status
    if "COMPLETED" in status_text or "✅" in status_text:
        meta["status"] = "COMPLETED"
    elif "IN_PROGRESS" in status_text or "进行中" in status_text:
        meta["status"] = "IN_PROGRESS"
    elif "PENDING" in status_text:
        meta["status"] = "PENDING"
    else:
        meta["status"] = status_text

    # Priority
    m = re.search(r'\*\*优先级\*\*:\s*(P[0-4])', content)
    meta["priority"] = m.group(1) if m else "P2"

    # Phase
    m = re.search(r'\*\*所属阶段\*\*:\s*(.+?)(?:\n|$)', content)
    meta["phase"] = m.group(1).strip() if m else "PAD"

    # Dependencies
    m = re.search(r'\*\*前置依赖\*\*:\s*(.+?)(?:\n|$)', content)
    deps_text = m.group(1).strip() if m else "无"
    meta["dependencies"] = [d.strip() for d in deps_text.split(",") if d.strip() and d.strip() != "无"]

    # Blockers
    m = re.search(r'\*\*下游阻塞\*\*:\s*(.+?)(?:\n|$)', content)
    blockers_text = m.group(1).strip() if m else ""
    meta["blockers"] = [b.strip() for b in blockers_text.split(",") if b.strip() and b.strip() != "无"]

    # Progress
    m = re.search(r'\*\*进度\*\*:\s*~?(\d+)%', content)
    meta["progress"] = int(m.group(1)) if m else (100 if meta["status"] == "COMPLETED" else 0)

    # Extract acceptance criteria checkboxes
    acceptance = []
    for line in content.split('\n'):
        m = re.search(r'-\s*\[([xX\s])\]\s*(.+)', line)
        if m:
            acceptance.append({
                "item": m.group(2).strip(),
                "completed": m.group(1).lower() == 'x'
            })
    meta["acceptance_criteria"] = acceptance

    # Extract deliverables from ## 交付物 section
    deliverables = []
    in_deliverables = False
    for line in content.split('\n'):
        if re.match(r'^##\s+交付物', line):
            in_deliverables = True
            continue
        if in_deliverables and re.match(r'^#{2,}\s', line):
            break
        if in_deliverables and line.strip().startswith('`'):
            m = re.search(r'`([^`]+)`', line)
            if m:
                deliverables.append(m.group(1))
    meta["deliverables"] = deliverables

    # Creation/completion dates
    footer = content.split('---')[-1] if '---' in content else ""
    m = re.search(r'创建时间:\s*(\S+)', footer)
    meta["created_at"] = m.group(1) if m else ""
    m = re.search(r'完成时间:\s*(\S+)', footer)
    if m:
        meta["completed_at"] = m.group(1)

    return meta, content


def convert_file(path, meta):
    """Rewrite file with JSON frontmatter."""
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Remove old metadata block (the first block before first ---)
    parts = content.split('---', 1)
    if len(parts) >= 2:
        # Keep everything after first ---
        body = '---' + parts[1]
    else:
        body = content

    # Remove footer metadata line
    lines = body.split('\n')
    cleaned_lines = []
    for line in lines:
        if re.search(r'\*创建时间:', line) and re.search(r'状态:', line):
            continue
        cleaned_lines.append(line)
    body = '\n'.join(cleaned_lines)

    # Build JSON frontmatter
    json_block = json.dumps(meta, ensure_ascii=False, indent=2)

    new_content = f"```json\n{json_block}\n```\n\n{body.strip()}\n"

    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)

    return meta["task_id"], meta["status"]


def main():
    files = sorted(glob.glob(os.path.join(TASK_DIR, "TASK-PAD-REWORK-*.md")))
    print(f"Found {len(files)} REWORK task files")

    for path in files:
        meta, _ = parse_task_file(path)
        task_id, status = convert_file(path, meta)
        print(f"  {task_id} → {status} (progress: {meta.get('progress', 0)}%)")

    print(f"\nAll {len(files)} files converted to JSON-frontmatter format.")


if __name__ == "__main__":
    main()
