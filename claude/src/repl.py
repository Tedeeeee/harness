from src.client import client, tracker
from src.config import get_config
from src.context import get_system_context
from src.models import get_model
from src.session import new_session_id
from src.tools.registry import get_tools
from src.commands.registry import get_commands
from src.query_engine import run_query
from src.permissions.permission_manager import PermissionManager


def run_repl(resume_messages: list = None):
    """대화 루프 (접수 창구)"""
    session_id = new_session_id()
    messages = resume_messages if resume_messages else []
    system_prompt = get_system_context()
    registry = get_tools()
    command_registry = get_commands()
    config = get_config()
    permission = PermissionManager()

    # 공유 컨텍스트 — 명령어들이 필요한 정보를 여기서 꺼내 씀
    context = {
        "session_id": session_id,
        "messages": messages,
        "tracker": tracker,
        "command_registry": command_registry,
        "should_exit": False,
    }

    print(f"세션: {session_id} | 모델: {get_model()}")
    print(f"도구: {', '.join(t.name for t in registry.all())}")
    print("/help 로 명령어 목록 확인")

    while True:
        user_input = input("\n나 > ")

        # 슬래시 명령어 처리
        if user_input.startswith("/"):
            parts = user_input[1:].split(maxsplit=1)
            if not parts:
                continue
            cmd_name = parts[0]
            cmd_args = parts[1] if len(parts) > 1 else ""
            cmd = command_registry.find(cmd_name)
            if cmd:
                result = cmd.call(cmd_args, context)
                if result:
                    print(result)
                if context["should_exit"]:
                    break
            else:
                print(f"알 수 없는 명령어: /{cmd_name} (/help 로 확인)")
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
