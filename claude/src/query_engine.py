"""
LLM ↔ Tool 반복 루프 (하네스의 심장)

프로바이더 추상화를 통해 Anthropic, Gemini 등
어떤 LLM이든 같은 루프로 동작한다.
"""

import json
from src.providers.base import Provider
from src.tools.registry import ToolRegistry
from src.cost_tracker import CostTracker
from src.permissions.permission_manager import PermissionManager, PermissionDecision
from src.retry import with_retry
from src.hooks.registry import HookRegistry

MAX_ITERATIONS = 50
MAX_REPEAT = 5  # 같은 도구 호출 반복 허용 횟수 (oh-my-claudecode 참고)


def run_query(
    messages: list,
    provider: Provider,
    model: str,
    max_tokens: int,
    system: str,
    registry: ToolRegistry,
    tracker: CostTracker,
    permission: PermissionManager,
    hooks: HookRegistry | None = None,
) -> str:
    """LLM ↔ Tool 반복 루프"""

    # 반복 감지용: "도구이름:입력요약" → 횟수
    repeat_tracker = {}

    for turn in range(MAX_ITERATIONS):
        # ① LLM에게 메시지 + 도구 목록 보내기 (스트리밍)
        printed_header = False

        def on_text(chunk, is_first):
            """텍스트가 올 때마다 실시간 출력"""
            nonlocal printed_header
            if is_first and not printed_header:
                print("\nAI > ", end="", flush=True)
                printed_header = True
            if chunk:
                print(chunk, end="", flush=True)

        try:
            response = with_retry(lambda: provider.call(
                model=model,
                max_tokens=max_tokens,
                system=system,
                messages=messages,
                tools=registry.get_api_schemas(),
                on_text=on_text,
            ))
        except Exception as e:
            print(f"\n❌ API 오류: {e}")
            return f"API 오류: {e}"

        if printed_header:
            print()  # 줄바꿈

        # 비용 기록
        tracker.add(response.usage)

        # ② 응답에서 도구 요청 분리
        tool_use_blocks = [
            block for block in response.content
            if block.type == "tool_use"
        ]

        # ③ 도구 요청이 없으면 → 최종 답변, 루프 종료
        if not tool_use_blocks:
            messages.append({"role": "assistant", "content": response.content})
            text = " ".join(
                block.text for block in response.content
                if block.type == "text"
            )
            return text

        # ④ 도구 요청이 있으면 → 권한 확인 후 실행
        messages.append({"role": "assistant", "content": response.content})

        tool_results = []
        for block in tool_use_blocks:
            tool = registry.find(block.name)
            if not tool:
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "tool_name": block.name,
                    "content": f"Unknown tool: {block.name}",
                    "is_error": True,
                })
                continue

            # 반복 감지: 같은 도구+같은 입력이 3번 이상이면 차단
            call_key = f"{block.name}:{json.dumps(block.input, sort_keys=True)}"
            repeat_tracker[call_key] = repeat_tracker.get(call_key, 0) + 1

            if repeat_tracker[call_key] > MAX_REPEAT:
                print(f"\n  ⚠️ 같은 호출이 {MAX_REPEAT}번 반복됨 — 중단하고 다른 방법을 시도하세요.")
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "tool_name": block.name,
                    "content": f"이 도구 호출이 {MAX_REPEAT}번 반복되어 차단되었습니다. "
                               f"같은 방법을 반복하지 말고 다른 접근법을 사용하세요. "
                               f"예: file_edit 대신 file_read로 전체를 읽고 file_write로 새로 작성하세요.",
                    "is_error": True,
                })
                continue

            # 권한 확인 (경비원)
            decision = permission.check(block.name, block.input)
            if decision == PermissionDecision.DENY:
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "tool_name": block.name,
                    "content": "사용자가 거부했습니다",
                    "is_error": True,
                })
                continue

            # 도구 입력을 보기 좋게 표시
            input_summary = json.dumps(block.input, ensure_ascii=False)
            if len(input_summary) > 200:
                input_summary = input_summary[:200] + "..."
            print(f"\n  [도구 실행] {block.name}({input_summary})")

            result = tool.execute(block.input)
            tool_results.append({
                "type": "tool_result",
                "tool_use_id": block.id,
                "tool_name": block.name,
                "content": result.content,
                "is_error": result.is_error,
            })

            # after_tool hook — 도구 실행 직후 이벤트
            if hooks:
                hooks.emit(
                    "after_tool",
                    tool_name=block.name,
                    tool_input=block.input,
                    result=result,
                )

        # ⑤ 도구 결과를 messages에 추가 → 다시 루프 맨 위로
        messages.append({"role": "user", "content": tool_results})

    return "최대 반복 횟수(50) 초과"
