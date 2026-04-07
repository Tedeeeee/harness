from pathlib import Path
from src.tools.base import Tool, ToolResult


class FileReadTool(Tool):
    """파일을 읽는 도구 (LLM의 눈)"""

    name = "file_read"
    description = "Read a file. Returns content with line numbers."
    input_schema = {
        "type": "object",
        "properties": {
            "file_path": {"type": "string", "description": "Path to the file to read"},
            "limit": {"type": "integer", "description": "Max lines to read"},
            "offset": {"type": "integer", "description": "Starting line (1-based)"},
        },
        "required": ["file_path"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        path = Path(tool_input["file_path"])

        if not path.exists():
            return ToolResult(content=f"File not found: {path}", is_error=True)

        try:
            lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
        except Exception as e:
            return ToolResult(content=str(e), is_error=True)

        # offset(시작 줄)과 limit(몇 줄) 처리
        offset = (tool_input.get("offset") or 1) - 1
        limit = tool_input.get("limit") or len(lines)
        selected = lines[offset : offset + limit]

        # 줄 번호 붙여서 반환
        numbered = "\n".join(
            f"{str(offset + i + 1).rjust(6)}\t{line}"
            for i, line in enumerate(selected)
        )
        return ToolResult(content=numbered or "(empty file)")
