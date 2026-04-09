"""
Orchestrator — 작업의 생명주기와 상태를 관리하는 상위 실행기

Phase 1에서는 query_engine.run_query()를 감싸는 facade.
Task 생성 → hook emit → 상태 전이 → run_query 호출 → 결과 기록.
"""

from datetime import datetime
from src.tasks.models import Task, PENDING, RUNNING, COMPLETED, FAILED
from src.tasks.store import TaskStore
from src.hooks.registry import HookRegistry
from src.query_engine import run_query


def run_task(
    goal: str,
    messages: list,
    provider,
    model: str,
    max_tokens: int,
    system: str,
    registry,
    tracker,
    permission,
    hooks: HookRegistry | None = None,
    task_store: TaskStore | None = None,
) -> Task:
    """
    사용자 요청을 Task 단위로 실행한다.

    1. Task 생성 (pending)
    2. before_task hook
    3. running으로 전이
    4. run_query() 호출
    5. completed / failed로 전이
    6. after_task / on_failure hook
    7. Task 반환
    """
    # Task 생성
    task = Task(goal=goal)

    # TaskStore에 등록
    if task_store:
        task_store.add(task)

    # before_task hook
    if hooks:
        hooks.emit("before_task", task=task)

    # running으로 전이
    task.status = RUNNING

    try:
        # 기존 query_engine 호출
        result_text = run_query(
            messages=messages,
            provider=provider,
            model=model,
            max_tokens=max_tokens,
            system=system,
            registry=registry,
            tracker=tracker,
            permission=permission,
            hooks=hooks,
        )

        # 성공
        task.status = COMPLETED
        task.result = result_text
        task.completed_at = datetime.now().isoformat()

        # after_task hook
        if hooks:
            hooks.emit("after_task", task=task)

    except Exception as e:
        # 실패
        task.status = FAILED
        task.error = str(e)
        task.completed_at = datetime.now().isoformat()

        # on_failure hook
        if hooks:
            hooks.emit("on_failure", task=task, error=e)

        # after_task hook (실패해도 호출)
        if hooks:
            hooks.emit("after_task", task=task)

    return task
