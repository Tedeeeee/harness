from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class ToolResult:
    """도구 실행 결과"""
    content: str          # 결과 내용
    is_error: bool = False  # 에러 여부


class Tool(ABC):
    """모든 도구가 지켜야 하는 규격 (콘센트 규격)"""

    name: str          # 도구 이름 — "bash", "file_read" 등
    description: str   # 도구 설명 — LLM이 읽고 언제 쓸지 판단
    input_schema: dict # 사용법 — LLM이 올바른 형식으로 호출하도록

    @abstractmethod
    def execute(self, tool_input: dict) -> ToolResult:
        """도구를 실행하고 결과를 반환한다."""
        pass

    def to_api_schema(self) -> dict:
        """Claude API에 보낼 도구 스키마 형태로 변환한다."""
        return {
            "name": self.name,
            "description": self.description,
            "input_schema": self.input_schema,
        }
