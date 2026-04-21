# Trace

이 디렉터리는 하네스 동작의 짧은 운영 로그를 담는다.

## 목적

- 어떤 hook이 언제 개입했는지
- router/skill이 왜 그렇게 판단했는지
- memory가 언제 참조되고 언제 승격됐는지
- blocker가 어떤 분류로 발생했는지
- closure와 visual pass가 언제 확정됐는지

나중에 디버깅할 때 "당시 하네스가 무엇을 보고 어떤 판단을 했는가"를 복원하기 위함이다.

## 파일 규칙

- 하루에 하나씩 `trace-YYYY-MM-DD.md`로 append
- 포맷은 `templates/trace-entry-template.md` 참조
- 한 줄당 하나의 엔트리
- append-only. 과거 엔트리를 편집하지 않는다

## 읽는 법

- 최근 파일부터 역순으로 확인
- 특정 event_type만 필터링하려면 `rg "\[skill-selected\]" docs/trace/` 같이 검색
- trace는 verification 증거가 아니다 — acceptance 판정은 `docs/verification/`을 본다
