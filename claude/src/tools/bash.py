import subprocess
from src.tools.base import Tool, ToolResult

MAX_OUTPUT = 100_000  # 출력 10만 자 제한


class BashTool(Tool):
    """셸 명령을 실행하는 도구 (LLM의 손)"""

    name = "bash"
    description = "Execute a shell command. Returns stdout, stderr, and exit code."
    input_schema = {
        "type": "object",
        "properties": {
            "command": {
                "type": "string",
                "description": "The shell command to run",
            },
            "timeout": {
                "type": "integer",
                "description": "Timeout in seconds (default 120)",
            },
        },
        "required": ["command"],
    }

    def execute(self, tool_input: dict) -> ToolResult:
        command = tool_input["command"]
        timeout = tool_input.get("timeout", 120)

        try:
            proc = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                timeout=timeout,
                cwd=None,  # 현재 디렉토리에서 실행
            )
            out = proc.stdout.decode("utf-8", errors="replace")
            err = proc.stderr.decode("utf-8", errors="replace")

            # 출력이 너무 크면 자르기
            truncated = ""
            if len(out) > MAX_OUTPUT:
                out = out[:MAX_OUTPUT]
                truncated = "\n... (output truncated)"

            result = f"{out}{truncated}"
            if err:
                result += f"\nSTDERR: {err[:2000]}"
            if proc.returncode != 0:
                result += f"\nExit code: {proc.returncode}"

            return ToolResult(content=result or "(no output)")

        except subprocess.TimeoutExpired:
            return ToolResult(content=f"Command timed out after {timeout}s", is_error=True)
        except Exception as e:
            return ToolResult(content=str(e), is_error=True)
