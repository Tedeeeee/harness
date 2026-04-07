import httpx
from bs4 import BeautifulSoup
from src.tools.base import Tool, ToolResult

MAX_CONTENT = 20_000  # 약 5000 토큰


class WebFetchTool(Tool):
    """URL의 내용을 가져오는 도구 (웹 브라우저 텍스트 모드)"""

    name = "web_fetch"
    description = "Fetch a URL and return its text content. HTML is converted to plain text."
    input_schema = {
        "type": "object",
        "properties": {
            "url": {"type": "string", "description": "The URL to fetch"},
        },
        "required": ["url"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        url = tool_input["url"]

        try:
            resp = httpx.get(
                url,
                follow_redirects=True,
                timeout=30,
                headers={"User-Agent": "claude-harness/1.0"},
            )
            resp.raise_for_status()

            # HTML이면 텍스트만 추출
            content_type = resp.headers.get("content-type", "")
            if "html" in content_type:
                soup = BeautifulSoup(resp.text, "html.parser")
                # 스크립트, 스타일 태그 제거
                for tag in soup(["script", "style"]):
                    tag.decompose()
                text = soup.get_text(separator="\n", strip=True)
            else:
                text = resp.text

            # 너무 길면 자르기
            if len(text) > MAX_CONTENT:
                text = text[:MAX_CONTENT] + "\n... (content truncated)"

            return ToolResult(content=text)

        except Exception as e:
            return ToolResult(content=f"Failed to fetch {url}: {e}", is_error=True)
