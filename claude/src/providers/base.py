"""
프로바이더 추상화 레이어

모든 LLM 프로바이더(Anthropic, Gemini 등)가 지켜야 하는 규격.
query_engine은 이 규격만 보고 동작하므로,
프로바이더를 바꿔도 query_engine 코드는 수정할 필요가 없다.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field


# --- 응답 데이터 구조 (모든 프로바이더가 이 형식으로 반환) ---

@dataclass
class TextBlock:
    """텍스트 응답 블록"""
    type: str = "text"
    text: str = ""


@dataclass
class ToolUseBlock:
    """도구 호출 요청 블록"""
    type: str = "tool_use"
    id: str = ""
    name: str = ""
    input: dict = field(default_factory=dict)


@dataclass
class Usage:
    """토큰 사용량"""
    input_tokens: int = 0
    output_tokens: int = 0


@dataclass
class LLMResponse:
    """LLM 응답 (모든 프로바이더가 이 형식으로 반환)"""
    content: list = field(default_factory=list)  # TextBlock 또는 ToolUseBlock 리스트
    usage: Usage = field(default_factory=Usage)


# --- 프로바이더 인터페이스 ---

class Provider(ABC):
    """모든 LLM 프로바이더가 지켜야 하는 규격 (콘센트 규격)"""

    @abstractmethod
    def call(
        self,
        model: str,
        max_tokens: int,
        system: str,
        messages: list,
        tools: list,
        on_text=None,
    ) -> LLMResponse:
        """
        LLM을 호출하고 응답을 반환한다.

        Args:
            model: 모델 이름
            max_tokens: 최대 토큰 수
            system: 시스템 프롬프트
            messages: 대화 이력 (정규화된 형식)
            tools: 도구 스키마 리스트
            on_text: 텍스트 스트리밍 콜백 (None이면 스트리밍 안 함)
                     호출 시그니처: on_text(chunk: str, is_first: bool)

        Returns:
            LLMResponse: 정규화된 응답
        """
        pass
