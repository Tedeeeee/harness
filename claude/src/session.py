import json
import uuid
from pathlib import Path
from datetime import datetime

# 세션 저장 위치
SESSIONS_DIR = Path.home() / ".claude-harness" / "sessions"


def new_session_id() -> str:
    """새 세션 ID 생성 (8자리)"""
    return str(uuid.uuid4())[:8]


def save_session(session_id: str, messages: list):
    """대화를 파일로 저장한다 (일기 쓰기)"""
    SESSIONS_DIR.mkdir(parents=True, exist_ok=True)
    path = SESSIONS_DIR / f"{session_id}.json"
    path.write_text(json.dumps({
        "session_id": session_id,
        "messages": messages,
        "created_at": datetime.now().isoformat(),
    }, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"세션 저장됨: {session_id}")


def load_session(session_id: str) -> list:
    """저장된 대화를 불러온다 (일기 읽기)"""
    path = SESSIONS_DIR / f"{session_id}.json"
    if not path.exists():
        raise FileNotFoundError(f"세션 '{session_id}'을 찾을 수 없습니다.")
    data = json.loads(path.read_text(encoding="utf-8"))
    messages = data["messages"]
    print(f"세션 '{session_id}' 복원됨 ({len(messages) // 2}번 대화)")
    return messages


def list_sessions() -> list:
    """저장된 세션 목록을 반환한다."""
    if not SESSIONS_DIR.exists():
        return []
    sessions = []
    for path in sorted(SESSIONS_DIR.glob("*.json"), reverse=True):
        data = json.loads(path.read_text(encoding="utf-8"))
        sessions.append({
            "id": data["session_id"],
            "created_at": data["created_at"],
            "turns": len(data["messages"]) // 2,
        })
    return sessions
