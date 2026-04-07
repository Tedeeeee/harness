from dataclasses import dataclass


@dataclass
class CostTracker:
    """토큰 사용량 추적 (택시 미터기)"""
    total_input: int = 0
    total_output: int = 0

    def add(self, usage):
        """API 응답의 usage를 누적한다."""
        self.total_input += usage.input_tokens
        self.total_output += usage.output_tokens

    def summary(self) -> str:
        """총 사용량 요약."""
        return f"총 사용량 — Input: {self.total_input} / Output: {self.total_output} tokens"
