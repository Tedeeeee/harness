# Codex CLI로 의견 받기

의견은 Codex CLI를 읽기 전용으로 실행해 받는다. Orca 밖에서도 된다. 옵션은 codex-cli 0.153.0 기준이다. 실패하면 `codex exec --help`로 설치된 버전을 확인한다. 옵션을 짐작해 쓰지 않는다.

## 실행

질문은 [opinion.md](opinion.md)의 양식으로 임시 파일에 쓰고, 표준 입력으로 넘긴다. 따옴표와 줄바꿈 문제를 피할 수 있다.

```bash
codex exec \
  -s read-only \
  -C "<프로젝트 폴더>" \
  --output-schema "<이 스킬 폴더>/schemas/opinion.schema.json" \
  -o "<임시 폴더>/codex-opinion.json" \
  - < "<임시 폴더>/codex-question.md"
```

| 옵션 | 뜻 |
|---|---|
| `-s read-only` | 파일을 고칠 수 없다 |
| `-C` | 코드를 읽을 폴더. 의견은 worktree 없이 지금 작업 폴더에서 받는다 |
| `--output-schema` | 마지막 답을 [opinion.schema.json](../schemas/opinion.schema.json) 형식으로 고정한다 |
| `-o` | 마지막 답을 파일로 받는다 |
| `-` | 질문을 표준 입력에서 읽는다 |

- `<이 스킬 폴더>`는 이 `SKILL.md`가 있는 폴더다. 정션으로 연결돼 있어도 그 경로를 그대로 쓴다.
- 몇 분 걸리므로 백그라운드로 실행하고, 그동안 Claude는 자기 조사를 한다.
- 임시 파일은 프로젝트 폴더 밖(Claude의 임시 작업 폴더)에 둔다.

## 실패할 때

- **모델을 모른다는 오류**(`model is not supported`, `model_not_found`): Codex 설정 파일(`~/.codex/config.toml`)의 모델을 설치된 CLI가 모르는 경우다. `codex debug models`로 이 CLI가 아는 모델을 보고 `-m <모델>`로 지정하거나, 개발자에게 CLI 갱신을 묻는다. 설정 파일은 개발자의 것이므로 고치지 않는다.
- **Windows에서 명령 실행 실패**(`CreateProcessWithLogonW failed`): 읽기 전용 샌드박스에서 Codex가 셸 명령을 못 띄우는 경우가 있다. Codex는 파일을 읽어 답을 내지만 실행 확인은 못 한 것이므로, 답의 근거를 Claude가 더 꼼꼼히 확인한다.

## 이어 묻기

의견은 보통 한 번으로 끝낸다. 더 물을 게 있으면 앞 답을 붙여 새로 묻는다. `codex exec resume`은 샌드박스 옵션을 받지 않아서, 이어 물을 때도 읽기 전용이 유지되는지 확인되지 않았다.

## 결과 읽기

`-o` 파일의 JSON을 읽고 [opinion.md](opinion.md)의 「지적 처리」대로 나눈다. 근거로 적힌 파일·줄은 Claude가 직접 열어 확인한다.
