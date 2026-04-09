"""
OpenAI (GPT) 프로바이더

OpenAI API 형식을 정규화된 형식으로 변환한다.
주요 차이점:
  - system prompt가 messages 안에 {"role": "system"}으로 들어감
  - 도구 스키마가 {"type": "function", "function": {...}} 형태
  - 도구 호출이 message.tool_calls 안에 있음
  - 도구 결과가 {"role": "tool", "tool_call_id": ...} 형태
"""

import json
import openai
from src.providers.base import Provider, LLMResponse, TextBlock, ToolUseBlock, Usage


class OpenAIProvider(Provider):
    """OpenAI GPT API 프로바이더"""

    def __init__(self, api_key: str, base_url: str = None):
        # base_url이 있으면 vLLM 같은 커스텀 엔드포인트에 연결
        self.client = openai.OpenAI(api_key=api_key, base_url=base_url)

    def call(self, model, max_tokens, system, messages, tools, on_text=None):
        """OpenAI API 호출"""

        # 메시지 변환 (정규화 형식 → OpenAI 형식)
        openai_messages = self._convert_messages(system, messages)

        # 도구 변환 (Anthropic 형식 → OpenAI 형식)
        openai_tools = self._convert_tools(tools)

        if on_text:
            return self._stream_call(model, max_tokens, openai_messages, openai_tools, on_text)
        else:
            return self._sync_call(model, max_tokens, openai_messages, openai_tools)

    def _sync_call(self, model, max_tokens, messages, tools):
        """동기 호출"""
        kwargs = {
            "model": model,
            "max_tokens": max_tokens,
            "messages": messages,
        }
        if tools:
            kwargs["tools"] = tools

        response = self.client.chat.completions.create(**kwargs)
        return self._to_llm_response(response)

    def _stream_call(self, model, max_tokens, messages, tools, on_text):
        """스트리밍 호출"""
        kwargs = {
            "model": model,
            "max_tokens": max_tokens,
            "messages": messages,
            "stream": True,
        }
        if tools:
            kwargs["tools"] = tools

        # 스트리밍으로 텍스트 실시간 출력하면서 전체 응답 조립
        is_first = True
        full_text = ""
        tool_calls_data = {}  # index → {id, name, arguments_str}
        usage_data = {"input": 0, "output": 0}

        stream = self.client.chat.completions.create(**kwargs)
        for chunk in stream:
            delta = chunk.choices[0].delta if chunk.choices else None
            if not delta:
                continue

            # 텍스트 스트리밍
            if delta.content:
                on_text(delta.content, is_first)
                is_first = False
                full_text += delta.content

            # 도구 호출 스트리밍 (조각씩 옴)
            if delta.tool_calls:
                for tc in delta.tool_calls:
                    idx = tc.index
                    if idx not in tool_calls_data:
                        tool_calls_data[idx] = {
                            "id": tc.id or "",
                            "name": tc.function.name or "" if tc.function else "",
                            "arguments": "",
                        }
                    if tc.id:
                        tool_calls_data[idx]["id"] = tc.id
                    if tc.function and tc.function.name:
                        tool_calls_data[idx]["name"] = tc.function.name
                    if tc.function and tc.function.arguments:
                        tool_calls_data[idx]["arguments"] += tc.function.arguments

            # 사용량 (마지막 청크에 있음)
            if hasattr(chunk, "usage") and chunk.usage:
                usage_data["input"] = chunk.usage.prompt_tokens
                usage_data["output"] = chunk.usage.completion_tokens

        # 최종 응답 조립
        content = []
        if full_text:
            content.append(TextBlock(text=full_text))

        for idx in sorted(tool_calls_data.keys()):
            tc = tool_calls_data[idx]
            try:
                args = json.loads(tc["arguments"]) if tc["arguments"] else {}
            except json.JSONDecodeError:
                args = {}
            content.append(ToolUseBlock(
                id=tc["id"],
                name=tc["name"],
                input=args,
            ))

        return LLMResponse(
            content=content,
            usage=Usage(
                input_tokens=usage_data["input"],
                output_tokens=usage_data["output"],
            ),
        )

    def _convert_tools(self, tools: list) -> list:
        """Anthropic 도구 스키마를 OpenAI 형식으로 변환"""
        if not tools:
            return []

        openai_tools = []
        for tool in tools:
            openai_tools.append({
                "type": "function",
                "function": {
                    "name": tool["name"],
                    "description": tool.get("description", ""),
                    "parameters": tool.get("input_schema", {}),
                },
            })
        return openai_tools

    def _convert_messages(self, system: str, messages: list) -> list:
        """정규화된 메시지를 OpenAI 형식으로 변환"""
        openai_messages = []

        # 시스템 프롬프트 (OpenAI는 messages 안에 넣음)
        if system:
            openai_messages.append({"role": "system", "content": system})

        for msg in messages:
            role = msg["role"]
            content = msg["content"]

            # 일반 텍스트 메시지
            if isinstance(content, str):
                openai_messages.append({"role": role, "content": content})
                continue

            # assistant 응답 (텍스트 + 도구 호출)
            if role == "assistant":
                text_parts = []
                tool_calls = []

                for block in content:
                    if hasattr(block, "type"):
                        if block.type == "text":
                            text_parts.append(block.text)
                        elif block.type == "tool_use":
                            tool_calls.append({
                                "id": block.id,
                                "type": "function",
                                "function": {
                                    "name": block.name,
                                    "arguments": json.dumps(block.input),
                                },
                            })

                msg_data = {"role": "assistant"}
                msg_data["content"] = " ".join(text_parts) if text_parts else None
                if tool_calls:
                    msg_data["tool_calls"] = tool_calls
                openai_messages.append(msg_data)
                continue

            # 도구 결과 (user role + tool_result 리스트)
            if role == "user" and isinstance(content, list):
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "tool_result":
                        openai_messages.append({
                            "role": "tool",
                            "tool_call_id": block.get("tool_use_id", ""),
                            "content": block.get("content", ""),
                        })
                continue

        return openai_messages

    def _to_llm_response(self, response) -> LLMResponse:
        """OpenAI 응답을 정규화된 LLMResponse로 변환"""
        content = []
        choice = response.choices[0].message

        # 텍스트
        if choice.content:
            content.append(TextBlock(text=choice.content))

        # 도구 호출
        if choice.tool_calls:
            for tc in choice.tool_calls:
                try:
                    args = json.loads(tc.function.arguments) if tc.function.arguments else {}
                except json.JSONDecodeError:
                    args = {}
                content.append(ToolUseBlock(
                    id=tc.id,
                    name=tc.function.name,
                    input=args,
                ))

        usage = Usage()
        if response.usage:
            usage.input_tokens = response.usage.prompt_tokens
            usage.output_tokens = response.usage.completion_tokens

        return LLMResponse(content=content, usage=usage)
