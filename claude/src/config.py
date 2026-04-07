import json
import os
from pathlib import Path

# 기본값 — 설정 파일이 없어도 이걸로 동작
DEFAULTS = {
    "api_key": "",
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
}


def get_config() -> dict:
    """설정을 불러온다. 우선순위: 환경변수 > 프로젝트 > 전역 > 기본값"""
    config = DEFAULTS.copy()

    # 1. 전역 설정 (~/.claude-harness/config.json)
    global_path = Path.home() / ".claude-harness" / "config.json"
    if global_path.exists():
        config.update(json.loads(global_path.read_text(encoding="utf-8")))

    # 2. 프로젝트 설정 (./.claude-harness/config.json)
    project_path = Path(".claude-harness") / "config.json"
    if project_path.exists():
        config.update(json.loads(project_path.read_text(encoding="utf-8")))

    # 3. 환경변수 (가장 높은 우선순위)
    if env_key := os.getenv("CLAUDE_API_KEY"):
        config["api_key"] = env_key
    if env_model := os.getenv("CLAUDE_MODEL"):
        config["model"] = env_model

    return config
