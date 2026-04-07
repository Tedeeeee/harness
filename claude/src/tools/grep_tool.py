import re
from pathlib import Path
from src.tools.base import Tool, ToolResult

MAX_RESULTS = 100


class GrepTool(Tool):
    """파일 내용을 정규식으로 검색하는 도구 (도서관 색인)"""

    name = "grep"
    description = "Search file contents with regex pattern. Returns matching files or lines."
    input_schema = {
        "type": "object",
        "properties": {
            "pattern": {"type": "string", "description": "Regex pattern to search for"},
            "path": {"type": "string", "description": "Directory to search in (default: current dir)"},
            "glob": {"type": "string", "description": "File filter e.g. '*.py'"},
        },
        "required": ["pattern"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        root = Path(tool_input.get("path") or ".")
        file_glob = tool_input.get("glob", "**/*")

        if not root.exists():
            return ToolResult(content=f"Directory not found: {root}", is_error=True)

        try:
            regex = re.compile(tool_input["pattern"])
        except re.error as e:
            return ToolResult(content=f"Invalid regex: {e}", is_error=True)

        # 파일을 순회하며 매칭되는 줄 찾기
        results = []
        for filepath in root.glob(file_glob):
            if not filepath.is_file():
                continue
            try:
                content = filepath.read_text(encoding="utf-8", errors="replace")
                for i, line in enumerate(content.splitlines(), 1):
                    if regex.search(line):
                        rel_path = filepath.relative_to(root)
                        results.append(f"{rel_path}:{i}: {line.strip()}")
                        if len(results) >= MAX_RESULTS:
                            break
            except Exception:
                continue

            if len(results) >= MAX_RESULTS:
                break

        output = "\n".join(results)
        if len(results) >= MAX_RESULTS:
            output += "\n... (results truncated to 100)"

        return ToolResult(content=output or "No matches found")
