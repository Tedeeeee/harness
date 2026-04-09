"""
TaskStore — 실행 중 task 상태를 메모리에서 관리

Phase 1에서는 in-memory only.
Phase 2에서 session 파일과 연결 예정.
"""

from src.tasks.models import Task


class TaskStore:
    """in-memory task 저장소"""

    def __init__(self):
        self._tasks: dict[str, Task] = {}  # task_id → Task

    def add(self, task: Task) -> None:
        """task를 저장소에 추가한다."""
        self._tasks[task.id] = task

    def get(self, task_id: str) -> Task | None:
        """task_id로 task를 가져온다."""
        return self._tasks.get(task_id)

    def all(self) -> list[Task]:
        """모든 task를 생성 순서로 반환한다."""
        return list(self._tasks.values())

    def update_status(self, task_id: str, status: str) -> None:
        """task 상태를 변경한다."""
        task = self._tasks.get(task_id)
        if task:
            task.status = status
