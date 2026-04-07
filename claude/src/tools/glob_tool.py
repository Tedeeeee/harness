from pathlib import Path
from src.tools.base import Tool, ToolResult

MAX_RESULTS = 100


class GlobTool(Tool):
    """파일 이름 패턴으로 검색하는 도구 (도서관 카드 목록)"""

    name = "glob"
    description = "Find files matching a glob pattern (e.g. **/*.py). Max 100 results."
    input_schema = {
        "type": "object",
        "properties": {
            "pattern": {"type": "string", "description": "Glob pattern (e.g. **/*.py)"},
            "path": {"type": "string", "description": "Search root directory (default: current dir)"},
        },
        "required": ["pattern"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        root = Path(tool_input.get("path") or ".")

        if not root.exists():
            return ToolResult(content=f"Directory not found: {root}", is_error=True)

        matches = list(root.glob(tool_input["pattern"]))
        truncated = len(matches) > MAX_RESULTS
        matches = matches[:MAX_RESULTS]

        filenames = [str(m.relative_to(root)) for m in matches]
        result = "\n".join(filenames)

        if truncated:
            result += "\n... (results truncated to 100)"

        return ToolResult(content=result or "No matches found")
