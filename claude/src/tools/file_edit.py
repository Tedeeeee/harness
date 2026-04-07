from pathlib import Path
from src.tools.base import Tool, ToolResult


class FileEditTool(Tool):
    """파일의 특정 부분을 찾아서 수정하는 도구 (Ctrl+H 찾기 및 바꾸기)"""

    name = "file_edit"
    description = "Edit a file by replacing old_str with new_str. old_str must be unique in the file."
    input_schema = {
        "type": "object",
        "properties": {
            "file_path": {"type": "string", "description": "Path to the file to edit"},
            "old_str": {"type": "string", "description": "Exact string to find"},
            "new_str": {"type": "string", "description": "Replacement string"},
        },
        "required": ["file_path", "old_str", "new_str"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        path = Path(tool_input["file_path"])
        old_str = tool_input["old_str"]
        new_str = tool_input["new_str"]

        if not path.exists():
            return ToolResult(content=f"File not found: {path}", is_error=True)

        # 같은 내용으로 바꾸면 의미 없음
        if old_str == new_str:
            return ToolResult(content="old_str and new_str are identical", is_error=True)

        try:
            content = path.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            return ToolResult(content=str(e), is_error=True)

        # old_str이 몇 번 나오는지 확인
        count = content.count(old_str)

        if count == 0:
            return ToolResult(
                content=f"Cannot find string in {path}:\n{old_str[:200]}",
                is_error=True,
            )
        if count > 1:
            return ToolResult(
                content=f"Found {count} matches — provide more context to make it unique",
                is_error=True,
            )

        # 딱 1번만 나오면 안전하게 교체
        new_content = content.replace(old_str, new_str, 1)
        path.write_text(new_content, encoding="utf-8")
        return ToolResult(content=f"파일 수정 완료: {path}")
