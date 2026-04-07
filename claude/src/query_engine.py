import anthropic
from src.tools.registry import ToolRegistry
from src.cost_tracker import CostTracker

MAX_ITERATIONS = 50


def run_query(
    messages: list,
    client: anthropic.Anthropic,
    model: str,
    max_tokens: int,
    system: str,
    registry: ToolRegistry,
    tracker: CostTracker,
) -> str:
    """LLM ↔ Tool 반복 루프 (하네스의 심장)"""

    for turn in range(MAX_ITERATIONS):
        # ① Claude에게 메시지 + 도구 목록 보내기
        response = client.messages.create(
            model=model,
            max_tokens=max_tokens,
            system=system,
            messages=messages,
            tools=registry.get_api_schemas(),
        )

        # 비용 기록
        tracker.add(response.usage)

        # ② 응답 분석 — 텍스트인지, 도구 요청인지
        has_tool_use = False
        text_parts = []

        for block in response.content:
            if block.type == "text":
                text_parts.append(block.text)
            elif block.type == "tool_use":
                has_tool_use = True

        # 텍스트가 있으면 출력
        if text_parts:
            print("\nClaude >", " ".join(text_parts))

        # ③ 도구 요청이 없으면 → 최종 답변, 루프 종료
        if not has_tool_use:
            # assistant 메시지 기록에 추가
            messages.append({"role": "assistant", "content": response.content})
            return " ".join(text_parts)

        # ④ 도구 요청이 있으면 → 실행하고 결과를 돌려줌
        # assistant 메시지 (도구 요청 포함) 기록에 추가
        messages.append({"role": "assistant", "content": response.content})

        # 각 도구 실행
        tool_results = []
        for block in response.content:
            if block.type != "tool_use":
                continue

            tool = registry.find(block.name)
            if not tool:
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": f"Unknown tool: {block.name}",
                    "is_error": True,
                })
                continue

            print(f"\n  [도구 실행] {block.name}({block.input})")
            result = tool.execute(block.input)

            tool_results.append({
                "type": "tool_result",
                "tool_use_id": block.id,
                "content": result.content,
                "is_error": result.is_error,
            })

        # ⑤ 도구 결과를 messages에 추가 → 다시 루프 맨 위로
        messages.append({"role": "user", "content": tool_results})

    return "최대 반복 횟수(50) 초과"
