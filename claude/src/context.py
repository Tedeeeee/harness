import os
import subprocess


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
        pass  # git repo가 아니거나 git이 없음

    return "\n".join(parts)
