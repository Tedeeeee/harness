"""
프로바이더 인스턴스와 비용 추적기를 생성한다.
config에 따라 Anthropic, Gemini, OpenAI 프로바이더가 만들어진다.
"""

from src.config import get_config
from src.cost_tracker import CostTracker
from src.providers import create_provider

# 설정 불러오기
config = get_config()

# 프로바이더별 API 키 매핑
_API_KEY_MAP = {
    "anthropic": "api_key",
    "gemini": "gemini_api_key",
    "openai": "openai_api_key",
    "vllm": "vllm_api_key",
}

# 프로바이더 생성
provider_name = config["provider"]
key_field = _API_KEY_MAP.get(provider_name)
if not key_field:
    raise ValueError(f"알 수 없는 프로바이더: {provider_name}")

# vLLM은 base_url과 API 키(없으면 더미값) 전달
if provider_name == "vllm":
    provider = create_provider(
        provider_name,
        api_key=config.get(key_field) or "EMPTY",
        base_url=config.get("vllm_base_url"),
    )
else:
    provider = create_provider(provider_name, api_key=config.get(key_field, ""))

# 토큰 비용 추적기 (택시 미터기)
tracker = CostTracker()
