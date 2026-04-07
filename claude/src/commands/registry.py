from src.commands.base import Command


class CommandRegistry:
    """슬래시 명령어 등록소"""

    def __init__(self):
        self._commands: list[Command] = []

    def register(self, cmd: Command):
        self._commands.append(cmd)

    def find(self, name: str) -> Command | None:
        for cmd in self._commands:
            if cmd.name == name:
                return cmd
        return None

    def all(self) -> list[Command]:
        return list(self._commands)


def get_commands() -> CommandRegistry:
    """모든 명령어를 등록하고 레지스트리를 반환한다."""
    from src.commands.builtin import ExitCommand, ModelCommand, SessionsCommand, HelpCommand, CostCommand, ClearCommand

    registry = CommandRegistry()
    registry.register(ExitCommand())
    registry.register(ModelCommand())
    registry.register(SessionsCommand())
    registry.register(HelpCommand())
    registry.register(CostCommand())
    registry.register(ClearCommand())
    return registry
