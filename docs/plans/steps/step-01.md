---
id: step-01
title: project-scaffold
status: completed
screen_ids: []
visual_scope: not-applicable
depends_on: []
outputs:
  - Next.js App Router + TypeScript 프로젝트 (권장 경로: `app/`)
  - `package.json` 스크립트: `dev`(port 3333), `build`, `start`, `test` (Vitest), `test:e2e` (Playwright)
  - Vitest + React Testing Library 구성 (`vitest.config.ts`, `vitest.setup.ts`)
  - Playwright 구성 (`playwright.config.ts`) — iPhone 13 세로 프로파일 기본, 스크린샷 저장 경로 `docs/verification/evidence/step-xx/`
  - 다크 테마 글로벌 스타일 (`globals.css` 또는 tailwind 토큰), `<html data-theme="dark">` 기본값
  - 루트 `README.md` (셋업/실행/테스트 명령)
  - 프로젝트 `CLAUDE.md` (규약·주의: 포트 3333, 시드 모듈 경로 자리표시, placeholder 교체 지점 추가 공간)
acceptance:
  - dev 서버가 port 3333에서 빈 루트 페이지를 다크 배경으로 렌더
  - Vitest 스모크 1건 통과
  - Playwright 스모크: iPhone 13 세로 프로파일에서 루트 페이지 로드 + 스크린샷 산출
  - README.md와 CLAUDE.md 존재 및 필수 섹션 포함
---

# 스텝

## 목표

이후 모든 step이 재사용할 Next.js App Router + TS 기반 스캐폴드를 세우고, Vitest/Playwright 파이프라인과 문서 뼈대를 동시에 구축한다. 이 step 이후로는 "어디에 코드를 두는가"와 "어떻게 검증을 남기는가"가 이미 결정된 상태여야 한다.

## 범위 안

- `app/`(또는 동급) 경로에 Next.js 앱 생성 및 TypeScript 기본값.
- `next dev -p 3333` 스크립트 구성.
- Vitest + jsdom + RTL 최소 구성과 스모크 테스트 1건.
- Playwright 구성, iPhone 13 세로 프로파일, 스크린샷 기본 경로, 스모크 시나리오 1건.
- 다크 테마 전역 기본값(배경·전경색 최소 2쌍) 설정.
- 루트 `README.md`에 설치/실행/테스트 명령 작성.
- 프로젝트 `CLAUDE.md`에 규약(포트 3333, 시드 모듈 경로, placeholder 교체 지점 빈 표) 작성.

## 범위 밖

- 실제 화면(Home/Search/Detail) UI.
- 데이터 시드/타입 정의(step-02 소관).
- 환경변수(`NEXT_PUBLIC_SURVEY_URL`) 실제 사용 — 이 step에서는 자리만 만들지 값 주입·참조는 하지 않는다.
- Tailwind 도입 여부는 선택(도입 시 설정·토큰만, 실제 컴포넌트 스타일은 이후 step).

## 산출물

- `app/` 디렉터리와 기본 레이아웃 파일.
- `package.json`, `tsconfig.json`, `vitest.config.ts`, `vitest.setup.ts`, `playwright.config.ts`.
- `app/globals.css`(또는 동급) 다크 테마 토큰.
- `README.md`, `CLAUDE.md`.
- `docs/verification/evidence/step-01/` 디렉터리(빈 상태여도 됨, step 증거 저장용).

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| `npm run dev` 후 `http://localhost:3333` 접속 시 다크 배경의 루트 페이지가 200으로 응답 | command + manual |
| `npm run test` (Vitest) 스모크 1건 이상 통과 | test |
| `npm run test:e2e` (Playwright) 스모크에서 iPhone 13 세로 프로파일 스크린샷이 `docs/verification/evidence/step-01/` 아래 생성 | test + file-check |
| 루트 `README.md`에 셋업/실행/테스트 명령이 포함되어 있고, 프로젝트 `CLAUDE.md`에 포트·시드 경로·placeholder 교체 지점 섹션이 존재 | file-check |
