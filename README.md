# 개인 하네스

한 사람이 자기 PC에서만 쓰는 AI 작업 규칙이다. 팀이 함께 쓰는 프로젝트 하네스는 바꾸지 않고, 그 위에 개인 규칙을 더한다.

지금 담고 있는 규칙은 하나다. **Claude가 판단·조율·검토를 맡고, Codex는 의견과 승인된 구현을 맡는 방식**이다(`codex-delegation`).

## 원칙

- **프로젝트 규칙이 우선한다.** 작업 중인 프로젝트의 진입 문서(`AGENTS.md`·`CLAUDE.md`)와 스킬을 먼저 따르고, 개인 규칙은 더하기만 한다. 충돌하면 프로젝트 규칙을 따르고 충돌을 알린다.
- **프로젝트에 흔적을 남기지 않는다.** 설치는 사용자 폴더에만 하고 프로젝트 저장소에는 파일을 만들지 않는다. 설치 뒤에도 프로젝트의 `git status`는 깨끗해야 한다.
- **이 저장소가 정본이다.** 여러 PC에서 같은 규칙을 쓰므로, PC마다 따로 쌓이는 메모리가 아니라 이 문서를 기준으로 한다.
- **공개 저장소다.** 특정 회사·프로젝트의 내부 정보, 접속 정보, 업무 데이터를 적지 않는다. 프로젝트 고유 규칙은 각 프로젝트의 하네스에 둔다.
- **도구 의존은 참고 문서에 가둔다.** Orca·Codex CLI 명령은 `references/orca.md`·`references/codex-cli.md`에만 둔다. 도구를 바꾸면 그 문서만 고친다.

## 구조

```
harness/
├─ README.md                      이 문서
├─ CLAUDE.md · AGENTS.md          이 저장소를 고칠 때의 진입 문서
├─ entry.md                       ~/.claude/CLAUDE.md가 불러오는 개인 규칙 진입
├─ skills/
│  └─ codex-delegation/
│     ├─ SKILL.md                 역할, 쓸지 정하기, 흐름, 지킬 것
│     ├─ references/
│     │  ├─ opinion.md            의견 질문 양식, 지적 처리, 보고 양식
│     │  ├─ codex-cli.md          의견을 Codex CLI 읽기 전용으로 받는 방법
│     │  ├─ brief.md              구현 지시서 양식
│     │  ├─ orca.md               Orca 작업자로 구현을 맡기는 방법
│     │  └─ review.md             검토, 되돌리기, 합치기, 정리
│     └─ schemas/
│        └─ opinion.schema.json   Codex 의견 답의 형식
└─ scripts/
   └─ install.ps1                 PC마다 한 번 실행하는 설치·제거 스크립트
```

## 필요한 것

- Claude Code
- Codex CLI (로그인까지)
- Orca: 구현을 맡길 때 쓴다. 설정 > Experimental에서 orchestration을 켠다.

## 설치 (PC마다 한 번)

```powershell
git clone https://github.com/Tedeeeee/harness.git C:\study\harness
powershell -ExecutionPolicy Bypass -File C:\study\harness\scripts\install.ps1
```

설치 스크립트가 하는 일:

1. 옛 개인 하네스(v0)가 설치한 것을 백업한 뒤 걷어 낸다. `%APPDATA%\personal-harness`가 남아 있으면 그 폴더와 옛 스킬 폴더 7개(`~/.agents/skills`·`~/.claude/skills`)를 걷어 내고, `~/.codex/AGENTS.md`에 옛 블록이 있으면 그 블록을 뺀다. 백업은 `%LOCALAPPDATA%\personal-harness-backup\<시각>`에 남는다.
2. `skills/` 아래 스킬을 `~/.claude/skills`에 디렉터리 정션으로 연결한다. 관리자 권한이 필요 없다.
3. `~/.claude/CLAUDE.md`에 `entry.md`를 불러오는 블록을 넣는다. 블록 밖의 내용은 건드리지 않는다.
4. Codex CLI와 Orca 준비 상태를 확인해 알려 준다.

다시 실행해도 결과가 같다. 블록 표시(`<!-- personal-harness:start -->`·`end`)가 깨져 있으면 사용자 내용을 지우지 않도록 고치지 않고 멈춘다.

## 갱신

`git pull`만 하면 된다. 정션과 불러오기라서 다시 설치할 필요가 없다. 스킬을 새로 추가했을 때만 설치 스크립트를 다시 실행한다.

## 제거

```powershell
powershell -ExecutionPolicy Bypass -File C:\study\harness\scripts\install.ps1 -Uninstall
```

정션과 `~/.claude/CLAUDE.md`의 블록을 뺀다.

## 권한

설치 스크립트는 Claude Code 권한 설정을 바꾸지 않는다. `codex exec`, `orca orchestration` 명령은 처음 실행할 때 묻는 창에서 허용하거나, Claude Code 설정에 직접 추가한다.

## 이 저장소를 고칠 때

- 스킬 본문은 `skills/<이름>/SKILL.md`, 세부 절차는 같은 폴더의 `references/`에 둔다. 스킬이 쓰는 파일은 스킬 폴더 안에 둔다. 정션으로 연결되므로 스킬 폴더 밖을 상대 경로로 가리키지 않는다.
- 새 스킬을 추가하면 이 README의 구조와 `entry.md`를 함께 고치고 설치 스크립트를 다시 실행한다.
- Orca·Codex 명령은 외워 쓰지 말고 설치된 버전에서 확인한다(`orca skills get orchestration`, `codex exec --help`).
