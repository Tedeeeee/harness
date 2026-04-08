from src.commands.base import Command


class ExitCommand(Command):
    name = "exit"
    description = "대화를 종료합니다"

    def call(self, args, context):
        from src.session import save_session
        messages = context["messages"]
        if messages:
            save_session(context["session_id"], messages)
        print(context["tracker"].summary())
        context["should_exit"] = True
        return None


class ModelCommand(Command):
    name = "model"
    description = "모델을 변경합니다. 사용법: /model haiku"

    def call(self, args, context):
        from src.models import get_model, set_model_override, resolve_model_name, KNOWN_MODELS
        if not args:
            aliases = ", ".join(info["alias"] for info in KNOWN_MODELS.values())
            return f"현재 모델: {get_model()}\n사용 가능: {aliases}"
        resolved = resolve_model_name(args.strip())
        if resolved:
            set_model_override(resolved)
            return f"모델 변경: {resolved}"
        return f"알 수 없는 모델: {args}"


class SessionsCommand(Command):
    name = "sessions"
    description = "저장된 세션 목록을 봅니다"

    def call(self, args, context):
        from src.session import list_sessions
        sessions = list_sessions()
        if not sessions:
            return "저장된 세션이 없습니다."
        lines = [f"  {s['id']} — {s['turns']}턴 ({s['created_at'][:16]})" for s in sessions[:5]]
        return "\n".join(lines)


class HelpCommand(Command):
    name = "help"
    description = "사용 가능한 명령어를 봅니다"

    def call(self, args, context):
        commands = context["command_registry"].all()
        lines = [f"  /{cmd.name} — {cmd.description}" for cmd in commands]
        return "사용 가능한 명령어:\n" + "\n".join(lines)


class CostCommand(Command):
    name = "cost"
    description = "현재 세션의 토큰 사용량을 봅니다"

    def call(self, args, context):
        return context["tracker"].summary()


class ClearCommand(Command):
    name = "clear"
    description = "대화 기록을 초기화합니다"

    def call(self, args, context):
        context["messages"].clear()
        return "대화 기록이 초기화되었습니다."


class ModeCommand(Command):
    name = "mode"
    description = "모드를 전환합니다. 사용법: /mode brainstorm"

    def call(self, args, context):
        from src.context import get_mode, set_mode, get_available_modes, get_system_context

        if not args:
            modes = ", ".join(get_available_modes())
            return f"현재 모드: {get_mode()}\n사용 가능: {modes}"

        mode = args.strip()
        if set_mode(mode):
            # 모드 전환 시 시스템 프롬프트 갱신
            context["system_prompt"] = get_system_context()
            return f"모드 전환: {mode}"
        return f"알 수 없는 모드: {mode}\n사용 가능: {', '.join(get_available_modes())}"
