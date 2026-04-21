---
id: step-06
title: finalize-wiring-and-regression
status: completed
screen_ids: []
visual_scope: not-applicable
depends_on: [step-01, step-02, step-03, step-04, step-05]
outputs:
  - `.env.example` 업데이트 (`NEXT_PUBLIC_SURVEY_URL`, `NEXT_PUBLIC_SHOW_PLATFORM_BADGES`)
  - `README.md` 섹션: 실행·테스트·placeholder 교체 체크리스트
  - `CLAUDE.md` 섹션: placeholder 교체 지점 목록(로고 자산 경로, 설문 URL 키, Platform 라벨 위치, `externalUrl` 시드 위치, 플랫폼 배지 플래그)
  - Playwright E2E 회귀 스위트 하나 (Home → Search → Detail → Watch Now → Back → Board)
acceptance:
  - E2E 회귀 스위트가 iPhone 13 세로 프로파일에서 끝까지 통과
  - `NEXT_PUBLIC_SURVEY_URL` 미설정 상태에서 앱이 placeholder 값으로 동작(크래시 없음)
  - `README.md`와 `CLAUDE.md`에 placeholder 교체 체크리스트가 존재
  - 전체 Vitest 스위트 + Playwright 스위트 통과
---

# 스텝

## 목표

개별 화면 step들이 끝난 뒤 남는 교차 관심사(환경변수 기본값, placeholder 교체 문서화, end-to-end 회귀)를 정리해 마감한다. 새 기능은 추가하지 않는다.

## 범위 안

- 환경변수 부재 시 설문 베너·Watch Now가 안전하게 placeholder로 동작하는지 확인.
- 플랫폼 배지 플래그 기본값(off) 최종 재확인.
- `README.md` 재정리(설치 → 실행(3333) → 테스트 → placeholder 교체 체크리스트).
- `CLAUDE.md`에 교체 지점 목록: 로고(`public/logo.*`), 설문 URL(`NEXT_PUBLIC_SURVEY_URL`), Platform 라벨(`src/data/filters.ts`), `externalUrl` 시드 값(`src/data/titles.ts`), 플랫폼 배지 표시 플래그.
- E2E 회귀: Home 상단 설문 베너 → 검색바/Event 탭으로 Search 이동 → 결과 카드 탭으로 Detail → Watch Now 외부 링크 검증(이동 가로채기) → 뒤로가기 → Board 탭 설문 링크.

## 범위 밖

- 신규 화면/기능.
- 실제 로고/플랫폼 이름/설문 URL 자산 교체(문서의 체크리스트만).
- 호스팅/배포 구성.
- 성능·접근성·국제화 회귀 확장.

## 산출물

- 갱신된 `README.md`, `CLAUDE.md`, `.env.example`.
- `tests/e2e/regression.spec.ts`(경로는 구성에 맞게) 회귀 스크립트.
- `docs/verification/evidence/step-06/` 아래 최종 회귀 스크린샷 세트.

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| Playwright E2E 회귀 스위트가 iPhone 13 세로 프로파일에서 끝까지 통과 | test |
| `NEXT_PUBLIC_SURVEY_URL` 미설정 환경에서 앱 구동 후 Home/Detail 베너가 placeholder 값으로 렌더 | manual + test |
| `README.md`에 placeholder 교체 체크리스트 섹션 존재 | file-check |
| `CLAUDE.md`에 교체 지점 5종(로고/설문/Platform/externalUrl/플랫폼 배지 플래그) 목록 존재 | file-check |
| 전체 Vitest + Playwright 스위트 한 번에 통과 | test |
