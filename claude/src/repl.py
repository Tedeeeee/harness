from src.client import provider, tracker
from src.config import get_config
from src.context import get_system_context, get_mode
from src.models import get_model
from src.session import new_session_id
from src.tools.registry import get_tools
from src.commands.registry import get_commands
from src.orchestrator.runner import run_task
from src.hooks.registry import HookRegistry
from src.tasks.store import TaskStore
from src.permissions.permission_manager import PermissionManager


def _read_input() -> str:
    """사용자 입력을 읽는다. 여러 줄 붙여넣기도 하나로 합친다."""
    import msvcrt
    import time

    first_line = input("\n나 > ")
    lines = [first_line]

    # 붙여넣기 감지: 버퍼에 남은 입력이 있으면 계속 읽음
    time.sleep(0.05)
    while msvcrt.kbhit():
        lines.append(input())

    return "\n".join(lines)


def run_repl(resume_messages: list = None):
    """대화 루프 (접수 창구)"""
    session_id = new_session_id()
    messages = resume_messages if resume_messages else []
    system_prompt = get_system_context()
    registry = get_tools()
    command_registry = get_commands()
    config = get_config()
    permission = PermissionManager()
    hooks = HookRegistry()
    task_store = TaskStore()

    # 공유 컨텍스트 — 명령어들이 필요한 정보를 여기서 꺼내 씀
    context = {
        "session_id": session_id,
        "messages": messages,
        "tracker": tracker,
        "command_registry": command_registry,
        "system_prompt": system_prompt,
        "permission": permission,
        "should_exit": False,
        "hooks": hooks,
        "task_store": task_store,
    }

    print(f"세션: {session_id} | 프로바이더: {config['provider']} | 모델: {get_model()} | 모드: {get_mode()}")
    print(f"도구: {', '.join(t.name for t in registry.all())}")
    print("/help 로 명령어 목록 확인")

    while True:
        user_input = _read_input()

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

        # 일반 대화 → Orchestrator를 통해 Task 단위로 실행
        messages.append({"role": "user", "content": user_input})
        task = run_task(
            goal=user_input,
            messages=messages,
            provider=provider,
            model=get_model(),
            max_tokens=config["max_tokens"],
            system=context["system_prompt"],
            registry=registry,
            tracker=tracker,
            permission=permission,
            hooks=hooks,
            task_store=task_store,
        )
