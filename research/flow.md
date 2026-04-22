# 동작 흐름

## 요청 처리 흐름

하네스의 기본 흐름은 README에 적힌 운영 순서와 실제 hook 코드가 거의 일치한다.

1. 사용자가 요청을 보낸다.
2. `UserPromptSubmit` 훅이 실행되어 `hooks/user_prompt_submit.py`가 `hooklib`를 호출한다.
3. `hooklib`는 `docs/implementation/implementation-state.md`, `docs/plans/planning-state.md`, `docs/requirements/*.md`, `memory/*.md`를 읽어 현재 상태를 요약한다.
4. 필요하면 interrupt 여부, blocker 여부, closure mismatch 여부를 계산한다.
5. 훅은 모델에게 “지금 planning을 계속해야 하는지, implementation을 막아야 하는지, verification으로 넘어가야 하는지”를 컨텍스트로 전달한다.
6. 선택된 skill이 작업을 수행하고 결과를 다시 `docs/`에 기록한다.

## 세션 시작 흐름

세션 시작 시 `hooks/session_start.py`가 같은 상태 문서를 읽고, 현재 step과 status에 맞는 시작 지침을 생성한다.

- planning만 존재하면 planning을 이어가라고 지시
- implementation이 blocked면 정확히 한 개 질문으로 unblock하라고 지시
- implementation이 done이면 새 작업인지 먼저 판단하라고 지시

이 흐름 덕분에 세션 간 컨텍스트 손실을 완화한다.

## 중단 방지 흐름

`hooks/stop_guard.py`는 작업이 verification-ready, blocked, or still in progress인 상태에서 너무 일찍 종료하지 않도록 막는 역할을 한다. 즉 “완료”보다 “검증 완료”를 우선시한다.

## Moyza 실험 앱의 사용자 흐름

대표 사용자 흐름은 아래와 같다.

1. `/` Home 진입
2. 상단 검색바 또는 하단 `Event` 탭으로 `/search` 진입
3. Country/Genre/Platform 필터 및 키워드로 결과 좁히기
4. 결과 카드 클릭으로 `/titles/[id]` 상세 진입
5. Synopsis/Cast/Similar 섹션 확인
6. `Watch Now`로 외부 URL 이동, 또는 `Board`/배너로 설문 링크 이동

## 데이터 흐름

실험 앱은 모두 메모리 내 정적 데이터 흐름이다.

1. `src/data/titles.ts`가 원본 작품 레코드를 제공한다.
2. `src/data/accessors.ts`가 `getAllSections`, `filterTitles`, `getTitleById` 같은 읽기 API를 만든다.
3. 각 라우트/컴포넌트가 접근자를 호출해 UI에 데이터를 주입한다.
4. 환경 변수는 `src/lib/env.ts`를 통해 설문 URL과 플랫폼 배지 표시 여부만 제어한다.

## 검증 흐름

검증은 단계별 문서와 산출물로 남는다.

1. 각 step은 `docs/plans/steps/step-xx.md`에 정의된다.
2. 완료 전 `docs/verification/step-xx-verification.md`에 acceptance와 evidence가 기록된다.
3. 실제 로그와 스크린샷은 `docs/verification/evidence/step-xx/`에 저장된다.
4. `docs/implementation/implementation-state.md`가 최종 상태를 `completed` 또는 `done`으로 닫는다.
