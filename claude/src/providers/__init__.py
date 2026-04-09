from src.providers.base import Provider, LLMResponse, TextBlock, ToolUseBlock, Usage


def create_provider(provider_name: str, **kwargs) -> Provider:
    """프로바이더 이름으로 인스턴스를 만든다 (공장 함수)"""
    if provider_name == "anthropic":
        from src.providers.anthropic_provider import AnthropicProvider
        return AnthropicProvider(**kwargs)
    elif provider_name == "gemini":
        from src.providers.gemini_provider import GeminiProvider
        return GeminiProvider(**kwargs)
    elif provider_name == "openai":
        from src.providers.openai_provider import OpenAIProvider
        return OpenAIProvider(**kwargs)
    elif provider_name == "vllm":
        # vLLM은 OpenAI 호환 API — base_url만 바꿔서 연결
        from src.providers.openai_provider import OpenAIProvider
        return OpenAIProvider(**kwargs)
    else:
        raise ValueError(f"알 수 없는 프로바이더: {provider_name}")
