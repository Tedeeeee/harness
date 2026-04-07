from pathlib import Path
from src.tools.base import Tool, ToolResult


class FileWriteTool(Tool):
    """파일을 쓰는 도구 (새 파일 생성 또는 전체 덮어쓰기)"""

    name = "file_write"
    description = "Write entire file contents. Creates parent directories if needed. Overwrites if exists."
    input_schema = {
        "type": "object",
        "properties": {
            "file_path": {"type": "string", "description": "Path to the file to write"},
            "file_contents": {"type": "string", "description": "The content to write"},
        },
        "required": ["file_path", "file_contents"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        path = Path(tool_input["file_path"])

        try:
            # 부모 디렉토리가 없으면 자동 생성
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(tool_input["file_contents"], encoding="utf-8")
            lines = len(tool_input["file_contents"].splitlines())
            return ToolResult(content=f"파일 작성 완료: {path} ({lines}줄)")
        except Exception as e:
            return ToolResult(content=str(e), is_error=True)
