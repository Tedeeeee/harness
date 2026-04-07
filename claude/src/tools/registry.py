from src.tools.base import Tool


class ToolRegistry:
    """도구 등록소 (식당 메뉴판)"""

    def __init__(self):
        self._tools: dict[str, Tool] = {}

    def register(self, tool: Tool):
        """도구를 등록한다. 이름이 중복되면 에러."""
        if tool.name in self._tools:
            raise ValueError(f"Tool '{tool.name}' already registered")
        self._tools[tool.name] = tool

    def find(self, name: str) -> Tool | None:
        """이름으로 도구를 찾는다."""
        return self._tools.get(name)

    def get_api_schemas(self) -> list[dict]:
        """LLM API에 보낼 도구 스키마 목록을 반환한다."""
        return [t.to_api_schema() for t in self._tools.values()]

    def all(self) -> list[Tool]:
        """등록된 모든 도구를 반환한다."""
        return list(self._tools.values())


def get_tools() -> ToolRegistry:
    """모든 도구를 등록하고 레지스트리를 반환한다."""
    from src.tools.bash import BashTool
    from src.tools.file_read import FileReadTool
    from src.tools.file_write import FileWriteTool
    from src.tools.file_edit import FileEditTool
    from src.tools.glob_tool import GlobTool
    from src.tools.grep_tool import GrepTool
    from src.tools.web_fetch import WebFetchTool

    registry = ToolRegistry()
    registry.register(BashTool())
    registry.register(FileReadTool())
    registry.register(FileWriteTool())
    registry.register(FileEditTool())
    registry.register(GlobTool())
    registry.register(GrepTool())
    registry.register(WebFetchTool())
    return registry
