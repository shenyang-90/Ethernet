#!/usr/bin/env python3
"""
ethernet_orchestrator.py - Ethernet IP 项目自动化编排器

功能:
1. 扫描项目任务状态
2. 自动推进 PAD 阶段任务（协议分析 → Arch Spec → Interface Spec → Clock/Reset → 微架构）
3. 更新 Dashboard
4. 自动 git commit/push 状态更新

Usage:
    python3 ethernet_orchestrator.py --scan    # 扫描当前状态
    python3 ethernet_orchestrator.py --step     # 执行下一步
    python3 ethernet_orchestrator.py --watch    # 持续监控

Author: AI Yang
"""

import json
import argparse
import subprocess
from pathlib import Path
from datetime import datetime

PROJECT_ROOT = Path("/root/.openclaw/workspace/sandbox/ethernet")
TASKS_DIR = PROJECT_ROOT / "ProjectMgmt" / "Phases" / "PAD" / "Tasks"
DOCS_DIR = PROJECT_ROOT / "Docs" / "Arch"

def run_cmd(cmd, cwd=None):
    """运行命令并返回输出"""
    try:
        result = subprocess.run(cmd, shell=True, cwd=cwd or PROJECT_ROOT, capture_output=True, text=True, timeout=30)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def scan_tasks():
    """扫描所有任务状态"""
    tasks = {}
    for task_file in sorted(TASKS_DIR.glob("*.md")):
        content = task_file.read_text()
        # 提取JSON部分
        if "```json" in content:
            json_str = content.split("```json")[1].split("```")[0].strip()
            try:
                data = json.loads(json_str)
                tasks[data.get("task_id", "UNKNOWN")] = {
                    "file": task_file,
                    "data": data,
                    "title": data.get("title", ""),
                    "status": data.get("status", "UNKNOWN"),
                    "assigned_to": data.get("assigned_to", ""),
                    "priority": data.get("priority", "P3"),
                }
            except json.JSONDecodeError:
                pass
    return tasks

def update_task_status(task_id, new_status, note=""):
    """更新任务状态"""
    tasks = scan_tasks()
    if task_id not in tasks:
        print(f"[ERROR] Task {task_id} not found")
        return False
    
    task = tasks[task_id]
    task_file = task["file"]
    content = task_file.read_text()
    
    # 替换状态
    old_status = f'"status": "{task["status"]}"'
    new_status_str = f'"status": "{new_status}"'
    
    if old_status in content:
        content = content.replace(old_status, new_status_str, 1)
        
        # 添加状态历史
        if "status_history" not in content:
            # 在JSON末尾添加status_history
            history_entry = f'    "status_history": [\n      {{ "date": "{datetime.now().strftime("%Y-%m-%d")}", "status": "{new_status}", "note": "{note}" }}\n    ]'
            content = content.replace('"ai_assist": true,', history_entry + ',\n    "ai_assist": true,')
        
        task_file.write_text(content)
        
        # git commit
        ok, out, err = run_cmd(f"git add {task_file.relative_to(PROJECT_ROOT)} && git commit -m '{task_id}: {new_status} - {note}'", cwd=PROJECT_ROOT)
        if ok:
            print(f"[OK] {task_id} → {new_status} ({note})")
            return True
        else:
            print(f"[WARN] Commit failed: {err}")
            return False
    else:
        print(f"[ERROR] Could not find status field in {task_id}")
        return False

def check_dependencies(task_id, tasks):
    """检查任务依赖是否满足"""
    task = tasks.get(task_id, {}).get("data", {})
    deps = task.get("dependencies", {})
    pre_tasks = deps.get("pre_tasks", [])
    
    for pre in pre_tasks:
        if pre in tasks:
            if tasks[pre]["status"] not in ["COMPLETED", "APPROVED"]:
                print(f"[DEP] {task_id} blocked by {pre} ({tasks[pre]['status']})")
                return False
        else:
            print(f"[DEP] {task_id} blocked by unknown {pre}")
            return False
    
    return True

def get_next_action(tasks):
    """决定下一步该做什么"""
    # 按优先级排序 PENDING/ASSIGNED 任务
    actionable = []
    for tid, t in tasks.items():
        if t["status"] in ["PENDING", "ASSIGNED"]:
            if check_dependencies(tid, tasks):
                actionable.append(t)
    
    if not actionable:
        return None
    
    # 按优先级排序
    priority_map = {"P0": 0, "P1": 1, "P2": 2, "P3": 3}
    actionable.sort(key=lambda x: priority_map.get(x["priority"], 99))
    
    best = actionable[0]
    best["task_id"] = best["data"]["task_id"]  # 确保有 task_id
    return best

def generate_dashboard(tasks):
    """生成 Dashboard"""
    dashboard_path = PROJECT_ROOT / "ProjectMgmt" / "Dashboard.md"
    
    # 统计
    total = len(tasks)
    completed = sum(1 for t in tasks.values() if t["status"] == "COMPLETED")
    assigned = sum(1 for t in tasks.values() if t["status"] == "ASSIGNED")
    pending = sum(1 for t in tasks.values() if t["status"] == "PENDING")
    
    # 当前阶段
    current_phase = "PAD"
    
    content = f"""# Dashboard: Ethernet IP

> **项目**: IP_20260502_001  
> **阶段**: {current_phase}  
> **更新时间**: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  
> **自动更新**: `make dashboard`

---

## 进度概览

| 指标 | 数值 |
|------|------|
| 总任务 | {total} |
| 已完成 | {completed} ({completed/total*100:.0f}%) |
| 已分配 | {assigned} |
| 待处理 | {pending} |

## 当前阶段: {current_phase}

| 任务ID | 任务 | 负责人 | 状态 | 优先级 |
|--------|------|--------|------|--------|
"""
    
    for tid, t in sorted(tasks.items(), key=lambda x: x[1]["priority"]):
        status_icon = {"COMPLETED": "✅", "ASSIGNED": "🟡", "PENDING": "⬜", "RUNNING": "🔵"}.get(t["status"], "❓")
        content += f"| {tid} | {t['title'][:40]} | {t['assigned_to']} | {status_icon} {t['status']} | {t['priority']} |\n"
    
    content += """
## 下一步行动

"""
    
    next_action = get_next_action(tasks)
    if next_action:
        content += f"- **{next_action['task_id']}**: {next_action['title']} → 分配给 {next_action['assigned_to']}\n"
    else:
        content += "- 所有依赖满足的任务已完成或已分配\n"
    
    content += f"""
---

*自动生成: ethernet_orchestrator.py*
"""
    
    dashboard_path.write_text(content)
    
    # git commit
    ok, _, _ = run_cmd("git add ProjectMgmt/Dashboard.md && git commit -m 'auto: update dashboard' || true", cwd=PROJECT_ROOT)
    
    print(f"[DASHBOARD] Generated: {dashboard_path}")
    return dashboard_path

def main():
    parser = argparse.ArgumentParser(description="Ethernet IP Project Orchestrator")
    parser.add_argument("--scan", action="store_true", help="扫描当前状态")
    parser.add_argument("--step", action="store_true", help="执行下一步")
    parser.add_argument("--dashboard", action="store_true", help="更新Dashboard")
    parser.add_argument("--watch", action="store_true", help="持续监控")
    parser.add_argument("--interval", type=int, default=60, help="监控间隔(秒)")
    args = parser.parse_args()
    
    if args.scan or (not any([args.step, args.dashboard, args.watch])):
        print("=== 任务状态扫描 ===")
        tasks = scan_tasks()
        for tid, t in sorted(tasks.items()):
            icon = {"COMPLETED": "✅", "ASSIGNED": "🟡", "PENDING": "⬜"}.get(t["status"], "❓")
            print(f"  {icon} {tid}: {t['status']:12} | {t['priority']} | {t['assigned_to']:20} | {t['title'][:50]}")
        
        next_action = get_next_action(tasks)
        if next_action:
            print(f"\n[下一步] {next_action['task_id']}: {next_action['title']}")
        else:
            print("\n[下一步] 无")
    
    if args.dashboard:
        tasks = scan_tasks()
        generate_dashboard(tasks)
    
    if args.step:
        tasks = scan_tasks()
        next_action = get_next_action(tasks)
        if next_action:
            print(f"[STEP] 执行: {next_action['task_id']}")
            # 这里会触发对应的Agent执行
            # 实际执行由上层编排器（当前AI session）完成
            print(f"       → 分配给: {next_action['assigned_to']}")
            print(f"       → 需要: AI session 执行")
        else:
            print("[STEP] 无待执行任务（或依赖未满足）")
    
    if args.watch:
        import time
        print(f"[WATCH] 开始监控，间隔 {args.interval} 秒...")
        try:
            while True:
                tasks = scan_tasks()
                next_action = get_next_action(tasks)
                if next_action:
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] NEXT: {next_action['task_id']} ({next_action['assigned_to']})")
                else:
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] IDLE")
                time.sleep(args.interval)
        except KeyboardInterrupt:
            print("\n[WATCH] 停止")

if __name__ == "__main__":
    main()
