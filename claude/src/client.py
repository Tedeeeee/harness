import anthropic
from src.retry import with_retry
from src.cost_tracker import CostTracker
from src.config import get_config
from src.models import get_model

# 설정 불러오기
config = get_config()

# Claude API 클라이언트 (전화기)
client = anthropic.Anthropic(api_key=config["api_key"])

# 토큰 비용 추적기 (택시 미터기)
tracker = CostTracker()


def chat_stream(messages: list, system: str = "") -> str:
    """Claude에게 메시지를 보내고, 스트리밍으로 대답을 받는다."""
    print("\nClaude > ", end="", flush=True)

    def do_stream():
        full_response = ""
        with client.messages.stream(
            model=get_model(),
            max_tokens=config["max_tokens"],
            system=system,
            messages=messages
        ) as stream:
            for text in stream.text_stream:
                print(text, end="", flush=True)
                full_response += text

            # 스트리밍 끝나면 usage 기록 (미터기 올리기)
            tracker.add(stream.get_final_message().usage)

        return full_response

    full_response = with_retry(do_stream)

    print()
    return full_response
