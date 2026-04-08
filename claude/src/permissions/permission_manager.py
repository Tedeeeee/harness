import json
from enum import Enum
from pathlib import Path

# 읽기 전용 도구 — 확인 없이 자동 허용
READ_ONLY_TOOLS = {"file_read", "glob", "grep"}

# 전역 권한 설정 파일 경로
PERMISSIONS_FILE = Path.home() / ".claude-harness" / "permissions.json"


class PermissionDecision(Enum):
    ALLOW = "allow"
    DENY = "deny"


class PermissionManager:
    """도구 실행 전 사용자 확인 (경비원)"""

    def __init__(self, bypass: bool = False):
        self.always_allowed: set[str] = set()  # 세션 내 항상 허용
        self.bypass = bypass  # True면 모든 확인 건너뜀
        self._load_global()  # 전역 설정 불러오기

    def check(self, tool_name: str, tool_input: dict) -> PermissionDecision:
        """도구 실행 전 허용 여부를 확인한다."""
        # 모든 확인 건너뛰기 모드
        if self.bypass:
            return PermissionDecision.ALLOW

        # 읽기 전용 도구는 자동 허용
        if tool_name in READ_ONLY_TOOLS:
            return PermissionDecision.ALLOW

        # 이전에 "항상 허용"한 도구인지 확인
        if tool_name in self.always_allowed:
            return PermissionDecision.ALLOW

        # 사용자에게 묻기
        return self._ask_user(tool_name, tool_input)

    def _ask_user(self, tool_name: str, tool_input: dict) -> PermissionDecision:
        """사용자에게 허용/거부를 묻는다."""
        print(f"\n[Permission] {tool_name}: {str(tool_input)[:100]}")
        choice = input("[y]허용 / [n]거부 / [a]항상허용 / [g]전역허용 / [!]모두허용: ").strip().lower()

        if choice == "y":
            return PermissionDecision.ALLOW
        elif choice == "a":
            self.always_allowed.add(tool_name)
            return PermissionDecision.ALLOW
        elif choice == "g":
            self.always_allowed.add(tool_name)
            self._save_global()
            return PermissionDecision.ALLOW
        elif choice == "!":
            self.bypass = True
            return PermissionDecision.ALLOW

        return PermissionDecision.DENY

    def _load_global(self):
        """전역 권한 설정을 파일에서 불러온다."""
        if PERMISSIONS_FILE.exists():
            try:
                data = json.loads(PERMISSIONS_FILE.read_text(encoding="utf-8"))
                self.always_allowed.update(data.get("always_allowed", []))
            except (json.JSONDecodeError, KeyError):
                pass

    def _save_global(self):
        """전역 권한 설정을 파일에 저장한다."""
        PERMISSIONS_FILE.parent.mkdir(parents=True, exist_ok=True)
        data = {"always_allowed": sorted(self.always_allowed)}
        PERMISSIONS_FILE.write_text(
            json.dumps(data, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    def reset(self) -> str:
        """전역 권한 설정을 초기화한다."""
        self.always_allowed.clear()
        self.bypass = False
        if PERMISSIONS_FILE.exists():
            PERMISSIONS_FILE.unlink()
        return "권한 설정이 초기화되었습니다."
