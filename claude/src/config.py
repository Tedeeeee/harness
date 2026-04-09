import json
import os
from pathlib import Path

# 기본값 — 설정 파일이 없어도 이걸로 동작
DEFAULTS = {
    "provider": "anthropic",      # 프로바이더: "anthropic", "gemini", "openai", "vllm"
    "api_key": "",                # Anthropic API 키
    "gemini_api_key": "",         # Gemini API 키
    "openai_api_key": "",         # OpenAI API 키
    "vllm_base_url": "",          # vLLM 엔드포인트 URL (예: http://192.168.1.111:8000/v1)
    "vllm_api_key": "EMPTY",      # vLLM API 키 (사내 서버: Bearer EMPTY)
    "model": "",                  # 모델 (비어있으면 프로바이더 기본값 사용)
    "max_tokens": 4096,           # 최대 출력 토큰
}

# 프로바이더별 기본 모델
PROVIDER_DEFAULT_MODELS = {
    "anthropic": "claude-sonnet-4-20250514",
    "gemini": "gemini-2.5-flash",
    "openai": "gpt-4o-mini",
    "vllm": "vllm",
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
    if env_key := os.getenv("GEMINI_API_KEY"):
        config["gemini_api_key"] = env_key
    if env_key := os.getenv("OPENAI_API_KEY"):
        config["openai_api_key"] = env_key
    if env_url := os.getenv("VLLM_BASE_URL"):
        config["vllm_base_url"] = env_url
    if env_key := os.getenv("VLLM_API_KEY"):
        config["vllm_api_key"] = env_key
    if env_provider := os.getenv("CLAUDE_PROVIDER"):
        config["provider"] = env_provider
    if env_model := os.getenv("CLAUDE_MODEL"):
        config["model"] = env_model

    # 모델이 비어있으면 프로바이더 기본값
    if not config["model"]:
        config["model"] = PROVIDER_DEFAULT_MODELS.get(config["provider"], "")

    return config
