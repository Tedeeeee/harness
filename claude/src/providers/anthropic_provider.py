"""
Anthropic (Claude) 프로바이더

기존 Anthropic API 호출을 프로바이더 인터페이스로 감싼다.
메시지 형식이 이미 Anthropic 기준이므로 변환 없이 그대로 전달한다.
"""

import anthropic
from src.providers.base import Provider, LLMResponse, TextBlock, ToolUseBlock, Usage


class AnthropicProvider(Provider):
    """Anthropic Claude API 프로바이더"""

    def __init__(self, api_key: str):
        self.client = anthropic.Anthropic(api_key=api_key)

    def call(self, model, max_tokens, system, messages, tools, on_text=None):
        """Claude API 호출 (스트리밍 지원)"""

        if on_text:
            return self._stream_call(model, max_tokens, system, messages, tools, on_text)
        else:
            return self._sync_call(model, max_tokens, system, messages, tools)

    def _sync_call(self, model, max_tokens, system, messages, tools, on_text=None):
        """동기 호출 (스트리밍 없이)"""
        response = self.client.messages.create(
            model=model,
            max_tokens=max_tokens,
            system=system,
            messages=messages,
            tools=tools,
        )
        return self._to_llm_response(response)

    def _stream_call(self, model, max_tokens, system, messages, tools, on_text):
        """스트리밍 호출 (텍스트를 실시간으로 콜백)"""
        is_first = True

        with self.client.messages.stream(
            model=model,
            max_tokens=max_tokens,
            system=system,
            messages=messages,
            tools=tools,
        ) as stream:
            # 텍스트가 올 때마다 콜백 호출
            for event in stream:
                if hasattr(event, "type") and event.type == "content_block_start":
                    if event.content_block.type == "text":
                        on_text("", is_first)
                        is_first = False
                elif hasattr(event, "type") and event.type == "content_block_delta":
                    if hasattr(event.delta, "text"):
                        on_text(event.delta.text, False)

            final = stream.get_final_message()

        return self._to_llm_response(final)

    def _to_llm_response(self, response) -> LLMResponse:
        """Anthropic 응답을 정규화된 LLMResponse로 변환"""
        content = []
        for block in response.content:
            if block.type == "text":
                content.append(TextBlock(text=block.text))
            elif block.type == "tool_use":
                content.append(ToolUseBlock(
                    id=block.id,
                    name=block.name,
                    input=block.input,
                ))

        usage = Usage(
            input_tokens=response.usage.input_tokens,
            output_tokens=response.usage.output_tokens,
        )

        return LLMResponse(content=content, usage=usage)
