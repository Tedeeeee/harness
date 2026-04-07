import os
from src.config import get_config

# Claude 모델 메뉴판
KNOWN_MODELS = {
    "claude-sonnet-4-20250514": {"context_window": 200000, "alias": "sonnet"},
    "claude-haiku-4-5-20251001": {"context_window": 200000, "alias": "haiku"},
    "claude-opus-4-20250514":  {"context_window": 200000, "alias": "opus"},
}

# 대화 중 모델 변경용
_session_model_override = None


def set_model_override(model: str):
    """대화 중 모델을 변경한다."""
    global _session_model_override
    _session_model_override = model


def get_model() -> str:
    """현재 사용할 모델을 결정한다. 우선순위: 세션 변경 > 환경변수 > 설정 > 기본값"""
    if _session_model_override:
        return _session_model_override
    if env := os.getenv("CLAUDE_MODEL"):
        return env
    return get_config().get("model", "claude-sonnet-4-20250514")


def resolve_model_name(name: str) -> str | None:
    """별칭(sonnet, haiku)을 전체 모델명으로 변환한다."""
    # 이미 전체 모델명이면 그대로
    if name in KNOWN_MODELS:
        return name
    # 별칭으로 찾기
    for full_name, info in KNOWN_MODELS.items():
        if info["alias"] == name:
            return full_name
    return None
