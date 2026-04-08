"""
Google Gemini 프로바이더

Gemini API의 형식을 정규화된 형식으로 변환한다.
주요 차이점:
  - Anthropic: role="assistant"  →  Gemini: role="model"
  - Anthropic: content=[블록들]  →  Gemini: parts=[파트들]
  - 도구 스키마 형식이 다름
  - 도구 결과 전달 방식이 다름
"""

import uuid
import google.generativeai as genai
from google.generativeai.types import content_types

from src.providers.base import Provider, LLMResponse, TextBlock, ToolUseBlock, Usage


class GeminiProvider(Provider):
    """Google Gemini API 프로바이더"""

    def __init__(self, api_key: str):
        genai.configure(api_key=api_key)

    def call(self, model, max_tokens, system, messages, tools, on_text=None):
        """Gemini API 호출"""

        # 도구 스키마 변환 (Anthropic 형식 → Gemini 형식)
        gemini_tools = self._convert_tools(tools)

        # 모델 생성 (시스템 프롬프트 포함)
        gemini_model = genai.GenerativeModel(
            model_name=model,
            system_instruction=system,
            tools=gemini_tools if gemini_tools else None,
        )

        # 메시지 변환 (Anthropic 형식 → Gemini 형식)
        gemini_messages = self._convert_messages(messages)

        if on_text:
            return self._stream_call(gemini_model, gemini_messages, max_tokens, on_text)
        else:
            return self._sync_call(gemini_model, gemini_messages, max_tokens)

    def _sync_call(self, model, messages, max_tokens):
        """동기 호출"""
        response = model.generate_content(
            messages,
            generation_config=genai.types.GenerationConfig(
                max_output_tokens=max_tokens,
            ),
        )
        return self._to_llm_response(response)

    def _stream_call(self, model, messages, max_tokens, on_text):
        """스트리밍 호출"""
        response = model.generate_content(
            messages,
            generation_config=genai.types.GenerationConfig(
                max_output_tokens=max_tokens,
            ),
            stream=True,
        )

        # 스트리밍으로 텍스트 실시간 출력
        is_first = True
        all_parts = []

        for chunk in response:
            if chunk.parts:
                for part in chunk.parts:
                    if hasattr(part, "text") and part.text:
                        on_text(part.text, is_first)
                        is_first = False

        # 스트리밍 끝난 후 전체 응답 조립
        # resolve()로 최종 응답 확보
        response.resolve()
        return self._to_llm_response(response)

    def _convert_tools(self, tools: list) -> list:
        """Anthropic 도구 스키마를 Gemini 형식으로 변환"""
        if not tools:
            return []

        declarations = []
        for tool in tools:
            # Anthropic의 input_schema에서 Gemini의 parameters로 변환
            params = tool.get("input_schema", {}).copy()

            # Gemini는 additionalProperties를 지원하지 않으므로 제거
            params.pop("additionalProperties", None)
            if "properties" in params:
                for prop in params["properties"].values():
                    prop.pop("additionalProperties", None)

            declarations.append(
                genai.types.FunctionDeclaration(
                    name=tool["name"],
                    description=tool.get("description", ""),
                    parameters=params if params.get("properties") else None,
                )
            )

        return [genai.types.Tool(function_declarations=declarations)]

    def _convert_messages(self, messages: list) -> list:
        """Anthropic 메시지를 Gemini 형식으로 변환"""
        gemini_messages = []

        for msg in messages:
            role = msg["role"]
            content = msg["content"]

            # role 변환: assistant → model
            gemini_role = "model" if role == "assistant" else "user"

            # content가 문자열인 경우 (일반 텍스트)
            if isinstance(content, str):
                gemini_messages.append({
                    "role": gemini_role,
                    "parts": [{"text": content}],
                })
                continue

            # content가 리스트인 경우 (블록들)
            parts = []
            for block in content:
                # dict인 경우 (tool_result 등)
                if isinstance(block, dict):
                    if block.get("type") == "tool_result":
                        # 도구 결과 → Gemini function_response
                        parts.append(genai.types.Part(
                            function_response=genai.types.FunctionResponse(
                                name=block.get("tool_name", "unknown"),
                                response={"result": block.get("content", "")},
                            )
                        ))
                    elif block.get("type") == "text":
                        parts.append({"text": block.get("text", "")})

                # TextBlock / ToolUseBlock 객체인 경우
                elif hasattr(block, "type"):
                    if block.type == "text":
                        parts.append({"text": block.text})
                    elif block.type == "tool_use":
                        # 도구 호출 → Gemini function_call
                        parts.append(genai.types.Part(
                            function_call=genai.types.FunctionCall(
                                name=block.name,
                                args=block.input,
                            )
                        ))

            if parts:
                gemini_messages.append({
                    "role": gemini_role,
                    "parts": parts,
                })

        return gemini_messages

    def _to_llm_response(self, response) -> LLMResponse:
        """Gemini 응답을 정규화된 LLMResponse로 변환"""
        content = []

        # 응답 파트 처리
        if response.parts:
            for part in response.parts:
                if hasattr(part, "text") and part.text:
                    content.append(TextBlock(text=part.text))
                elif hasattr(part, "function_call") and part.function_call:
                    fc = part.function_call
                    content.append(ToolUseBlock(
                        id=f"tool_{uuid.uuid4().hex[:12]}",
                        name=fc.name,
                        input=dict(fc.args) if fc.args else {},
                    ))

        # 사용량 추적 (Gemini도 usage_metadata 제공)
        usage = Usage()
        if hasattr(response, "usage_metadata") and response.usage_metadata:
            meta = response.usage_metadata
            usage.input_tokens = getattr(meta, "prompt_token_count", 0) or 0
            usage.output_tokens = getattr(meta, "candidates_token_count", 0) or 0

        return LLMResponse(content=content, usage=usage)
