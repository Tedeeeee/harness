from src.client import client, tracker
from src.config import get_config
from src.context import get_system_context
from src.models import get_model, set_model_override, resolve_model_name, KNOWN_MODELS
from src.session import new_session_id, save_session, list_sessions
from src.tools.registry import get_tools
from src.query_engine import run_query
from src.permissions.permission_manager import PermissionManager


def run_repl(resume_messages: list = None):
    """대화 루프 (접수 창구)"""
    session_id = new_session_id()
    messages = resume_messages if resume_messages else []
    system_prompt = get_system_context()
    registry = get_tools()
    config = get_config()
    permission = PermissionManager()

    print(f"세션: {session_id} | 모델: {get_model()}")
    print(f"도구: {', '.join(t.name for t in registry.all())}")
    print("명령어: /exit, /model, /sessions")

    while True:
        user_input = input("\n나 > ")

        # /exit — 종료 + 세션 저장
        if user_input == "/exit":
            if messages:
                save_session(session_id, messages)
            print(tracker.summary())
            break

        # /model — 모델 변경
        if user_input.startswith("/model"):
            parts = user_input.split()
            if len(parts) < 2:
                print(f"현재 모델: {get_model()}")
                print(f"사용 가능: {', '.join(info['alias'] for info in KNOWN_MODELS.values())}")
                continue
            resolved = resolve_model_name(parts[1])
            if resolved:
                set_model_override(resolved)
                print(f"모델 변경: {resolved}")
            else:
                print(f"알 수 없는 모델: {parts[1]}")
            continue

        # /sessions — 저장된 세션 목록
        if user_input == "/sessions":
            sessions = list_sessions()
            if not sessions:
                print("저장된 세션이 없습니다.")
            else:
                for s in sessions[:5]:
                    print(f"  {s['id']} — {s['turns']}턴 ({s['created_at'][:16]})")
            continue

        # 일반 대화 → QueryEngine으로 처리
        messages.append({"role": "user", "content": user_input})
        run_query(
            messages=messages,
            client=client,
            model=get_model(),
            max_tokens=config["max_tokens"],
            system=system_prompt,
            registry=registry,
            tracker=tracker,
            permission=permission,
        )
