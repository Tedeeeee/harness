from pathlib import Path

MAX_MEMORY_LINES = 200
MAX_MEMORY_BYTES = 25_000


def get_memory_dir(cwd: str) -> Path:
    """프로젝트별 메모리 디렉토리 경로"""
    slug = cwd.replace("/", "-").replace("\\", "-").strip("-")
    return Path.home() / ".claude-harness" / "projects" / slug / "memory"


def load_memory(cwd: str) -> str:
    """MEMORY.md를 읽어서 시스템 프롬프트에 넣을 텍스트를 만든다."""
    memory_dir = get_memory_dir(cwd)
    memory_dir.mkdir(parents=True, exist_ok=True)

    entrypoint = memory_dir / "MEMORY.md"
    if not entrypoint.exists():
        entrypoint.write_text("", encoding="utf-8")
        return ""

    raw = entrypoint.read_text(encoding="utf-8")
    if not raw.strip():
        return ""

    # 너무 길면 자르기
    lines = raw.splitlines()
    if len(lines) > MAX_MEMORY_LINES or len(raw.encode()) > MAX_MEMORY_BYTES:
        raw = "\n".join(lines[:MAX_MEMORY_LINES])
        raw += "\n[경고: MEMORY.md가 너무 길어 잘렸습니다]"

    return f"# Memory\n{raw}"


def get_memory_instructions(cwd: str) -> str:
    """LLM에게 메모리 저장 방법을 알려주는 지침"""
    memory_dir = get_memory_dir(cwd)
    return f"""# Memory Instructions
사용자가 무언가를 "기억해줘", "기억해", "remember" 라고 하면,
file_write 도구를 사용해서 아래 경로의 MEMORY.md에 저장하라.
기존 내용이 있으면 file_read로 먼저 읽고, file_edit로 내용을 추가하라.

메모리 파일 경로: {memory_dir / "MEMORY.md"}
"""


def load_claude_md(cwd: str) -> str:
    """CLAUDE.md 파일을 현재 디렉토리부터 상위까지 탐색해서 합친다."""
    results = []

    # 전역 CLAUDE.md
    global_md = Path.home() / ".claude-harness" / "CLAUDE.md"
    if global_md.exists():
        results.append(global_md.read_text(encoding="utf-8"))

    # 프로젝트 계층 탐색 (현재 → 상위 → ... → 루트)
    path = Path(cwd)
    checked = set()
    while path not in checked:
        checked.add(path)
        claude_md = path / "CLAUDE.md"
        if claude_md.exists():
            results.append(claude_md.read_text(encoding="utf-8"))
        if path.parent == path:
            break
        path = path.parent

    if not results:
        return ""

    return "# Project Rules\n" + "\n\n---\n\n".join(reversed(results))
