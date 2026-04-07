from abc import ABC, abstractmethod


class Command(ABC):
    """모든 슬래시 명령어가 지켜야 하는 규격"""

    name: str          # 명령어 이름 ("exit", "model")
    description: str   # 설명

    @abstractmethod
    def call(self, args: str, context: dict) -> str | None:
        """명령어를 실행한다. 반환값이 있으면 출력."""
        pass
