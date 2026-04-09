"""
Task 모델 — 사용자 요청을 작업 단위로 관리하는 데이터 구조

orchestrator가 Task를 생성하고, 상태를 전이하고, 결과를 기록한다.
Phase 1에서는 최소 모델로 시작한다.
"""

import uuid
from dataclasses import dataclass, field
from datetime import datetime


# 상태 상수 — Phase 1은 3가지만
PENDING = "pending"
RUNNING = "running"
COMPLETED = "completed"
FAILED = "failed"


@dataclass
class Task:
    """하나의 작업 단위"""
    id: str = ""                              # 고유 ID (8자리 UUID)
    goal: str = ""                            # 사용자가 요청한 목표
    status: str = PENDING                     # pending → running → completed / failed
    owner_agent: str = "coder"                # 이 task를 실행할 agent (Phase 2에서 확장)
    parent_task_id: str | None = None         # 상위 task (위임 체인 추적용)
    result: str | None = None                 # 최종 응답 텍스트
    artifacts: list[str] = field(default_factory=list)  # 산출물 (파일 경로 등)
    error: str | None = None                  # 실패 시 사유
    created_at: str = ""
    completed_at: str = ""

    def __post_init__(self):
        if not self.id:
            self.id = str(uuid.uuid4())[:8]
        if not self.created_at:
            self.created_at = datetime.now().isoformat()
