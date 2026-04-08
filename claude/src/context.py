import os
import subprocess
from pathlib import Path
from src.memory import load_memory, load_claude_md, get_memory_instructions

# 프롬프트 파일이 있는 폴더
PROMPTS_DIR = Path(__file__).parent / "prompts"

# 사용 가능한 모드와 대응하는 프롬프트 파일
MODES = {
    "coding": "coding.md",
    "brainstorm": "brainstorm.md",
    "plan": "plan.md",
}

# 현재 활성 모드 (기본: coding)
_current_mode = "coding"


def set_mode(mode: str) -> bool:
    """모드를 전환한다. 성공하면 True."""
    global _current_mode
    if mode in MODES:
        _current_mode = mode
        return True
    return False


def get_mode() -> str:
    """현재 모드를 반환한다."""
    return _current_mode


def get_available_modes() -> list[str]:
    """사용 가능한 모드 목록을 반환한다."""
    return list(MODES.keys())


def _load_prompt(filename: str) -> str:
    """프롬프트 파일을 읽어서 반환한다."""
    path = PROMPTS_DIR / filename
    if path.exists():
        return path.read_text(encoding="utf-8").strip()
    return ""


def get_system_context() -> str:
    """시스템 프롬프트를 만든다 (지침서 작성)"""
    cwd = os.getcwd()
    parts = []

    # ① 기본 프롬프트 (항상 로드)
    base = _load_prompt("base.md")
    if base:
        parts.append(base)

    # ② 현재 모드 프롬프트 (모드에 따라 다르게 로드)
    mode_file = MODES.get(_current_mode, "coding.md")
    mode_prompt = _load_prompt(mode_file)
    if mode_prompt:
        parts.append(mode_prompt)

    # ③ 환경 정보
    parts.append(f"Working directory: {cwd}")

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

    # ④ 메모리 지침 (저장 방법 안내)
    parts.append(get_memory_instructions(cwd))

    # ⑤ 메모리 주입 (이전 세션에서 기억해둔 것)
    memory = load_memory(cwd)
    if memory:
        parts.append(memory)

    # ⑥ CLAUDE.md 주입 (프로젝트 규칙)
    claude_md = load_claude_md(cwd)
    if claude_md:
        parts.append(claude_md)

    return "\n\n".join(parts)
