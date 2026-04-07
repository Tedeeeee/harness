import os
import subprocess
from src.memory import load_memory, load_claude_md, get_memory_instructions


def get_system_context() -> str:
    """시스템 프롬프트를 만든다 (지침서 작성)"""
    cwd = os.getcwd()
    parts = [
        "You are a helpful coding assistant.",
        f"Working directory: {cwd}",
    ]

    # git 정보 수집 (git repo가 아니면 무시)
    try:
        branch = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            text=True, stderr=subprocess.DEVNULL
        ).strip()
        parts.append(f"Git branch: {branch}")

        status = subprocess.check_output(
            ["git", "status", "--short"],
            text=True, stderr=subprocess.DEVNULL
        ).strip()
        if status:
            parts.append(f"Git status:\n{status[:2000]}")
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    # 메모리 지침 (저장 방법 안내)
    parts.append(get_memory_instructions(cwd))

    # 메모리 주입 (이전 세션에서 기억해둔 것)
    memory = load_memory(cwd)
    if memory:
        parts.append(memory)

    # CLAUDE.md 주입 (프로젝트 규칙)
    claude_md = load_claude_md(cwd)
    if claude_md:
        parts.append(claude_md)

    return "\n\n".join(parts)
