# Orca로 구현 맡기기

Codex 구현 작업자는 Orca orchestration으로 띄운다. 진행 화면이 남고, 작업자는 실행 중에 질문(`question`)하고 끝나면 보고(`worker_done`)한다.

## 먼저

1. Orca 안에서 실행 중인지 확인한다. 환경 변수 `ORCA_TERMINAL_HANDLE`이 있어야 한다. 없으면 구현을 맡기지 않는다(SKILL.md 「조율자 위치」).
2. 설치된 Orca 버전의 가이드를 읽는다: `orca skills get orchestration`. 아래 명령은 Orca 1.4.253 기준 요약이다. 가이드와 다르면 가이드를 따른다.
3. `orca status --json`으로 런타임이 떠 있는지 본다. orchestration은 Orca 설정 > Experimental에서 켠다.

## 순서

1. **Run 만들기.** 기능 하나에 Run 하나를 만든다.

   ```bash
   orca orchestration run-create --objective "<기능 요약>" --json
   ```

2. **작업자 띄우기.** 작업마다 지시서([brief.md](brief.md))를 파일로 쓰고 넘긴다.

   ```bash
   orca orchestration worker-start \
     --spec-file "<지시서 파일>" --task-title "<제목>" \
     --worktree new-child --name "<이름>" --base-branch "<조율자 브랜치>" \
     --agent codex --setup run --json
   ```

   - 작업자 worktree는 조율자가 있는 브랜치의 HEAD에서 만든다. 조율자 폴더의 커밋 안 된 변경은 worktree에 들어가지 않는다. 작업이 그 변경에 기대면 먼저 개발자와 정한다.
   - 파일이 겹치지 않는 작업은 모두 띄운 뒤에 기다린다.
   - 응답의 dispatch id와 worktree 경로를 적어 둔다.

3. **기다리기.**

   ```bash
   orca orchestration check --wait --types worker_done,escalation,question --timeout-ms 900000 --json
   ```

   - 시간 초과는 실패가 아니다. 다시 기다린다. 긴 작업은 15~60분 걸린다.
   - 이 버전의 `check`는 받은 묶음을 처리한 것으로 표시한다. 받은 메시지를 모두 처리한 뒤 다음 기다리기로 넘어간다.
   - 진행은 Orca 화면에서 보이고, 기록은 `orca orchestration worker-read --dispatch <id> --json`으로 읽는다.

4. **질문 처리** (`question`). 설계 판단이면 바로 답한다. 제품 판단이면 개발자에게 묻고 답을 받은 뒤 답한다. 답은 계획에도 적는다. 개발자를 기다리는 동안 질문은 Orca에 남아 있다.

   ```bash
   orca orchestration reply --id <message_id> --body "<답>" --json
   ```

   범위가 바뀌는 질문이면 그 작업자를 멈추고(아래 6) 기획으로 돌아간다.

5. **완료** (`worker_done`). 보고를 그대로 믿지 말고 [review.md](review.md)대로 검토한다.
   - 고칠 게 있으면 같은 작업자에게 후속 작업으로 보낸다. 맥락이 이어진다. `orca orchestration worker-show --dispatch <id> --json`에서 작업자 터미널 handle을 읽고, 후속 지시서를 그 터미널로 넘긴다.

     ```bash
     orca orchestration worker-start --spec-file "<후속 지시서>" --terminal <handle> --json
     ```

   - 더 맡길 게 없으면 작업자를 정리한다.

     ```bash
     orca orchestration worker-release --dispatch <dispatch_id> --json
     ```

6. **멈추기** (개발자가 "혼자 해"라고 하거나 범위가 바뀔 때).

   ```bash
   orca orchestration worker-stop --dispatch <dispatch_id> --json
   ```

   worktree는 지워지지 않는다. 그때까지 바뀐 것을 검토한 뒤 Claude가 이어서 한다.

## 화면 확인 (이미지)

화면 작업은 Orca 내장 브라우저로 캡처해 Claude가 이미지로 확인할 수 있다.

- `orca screenshot --worktree <worktree> --json`(보이는 부분), `orca full-screenshot --worktree <worktree> --json`(페이지 전체)은 이미지를 파일로 저장하고 경로를 알려 준다.
- `orca snapshot`(접근성 트리), `orca capture start|stop`(콘솔·네트워크 기록)도 쓸 수 있다.
- 그 worktree용 개발 서버가 필요하다. 먼저 개발자에게 묻고, 개발자가 쓰는 포트와 겹치지 않게 한다.
- 개발자는 시안·스크린샷을 Claude에게 준다(Orca 채팅 탭에서는 첨부할 수 있다). Claude가 파일로 저장해 지시서에 경로를 적는다. Codex가 그 파일을 열어 볼 수 있는지는 첫 시범에서 확인한다.
