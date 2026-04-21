---
id: step-02
title: data-model-and-seed
status: completed
screen_ids: []
visual_scope: not-applicable
depends_on: [step-01]
outputs:
  - `src/data/types.ts`: `Title`, `FilterOptions`, `HomeSectionKey`, `HomeSection` 등 타입 정의
  - `src/data/titles.ts`: 작품 시드 12~20개(국가/장르/플랫폼 분포 균형)
  - `src/data/filters.ts`: Country(USA/Korea/China/Japan), Genre(Romance/Horror/Action/Comedy/B/L), Platform `A/B/C/D/E` placeholder 라벨
  - `src/data/home-sections.ts`: 섹션 키 3종(`new-releases` / `popular-picks` / `korea-picks`)과 각 섹션의 작품 ID 배열
  - `src/data/accessors.ts`: `getSection`, `searchTitles`, `filterTitles`, `getTitleById`
acceptance:
  - Vitest: 접근자 함수별 단위 테스트 통과 (필터 AND 조합, 정렬 `Latest first`, 섹션 조회, ID 조회, 미존재 케이스 포함)
  - 시드 데이터가 타입 컴파일 통과 (`tsc --noEmit`)
  - `home-sections.ts`의 모든 ID가 `titles.ts`에 존재 (integrity 테스트)
  - 12~20개 작품 중 최소 3개의 국가·3개의 장르·3개의 플랫폼이 존재
---

# 스텝

## 목표

이후 모든 화면이 읽어갈 정적 시드 데이터와 접근자 함수를 제공한다. 큐레이션은 작품 레코드와 분리된 `home-sections.ts`로 관리해 추후 플래그 기반(Option 2)으로 이행 가능한 경계를 확보한다.

## 범위 안

- 타입 정의: 작품(`id`, `title`, `posterUrl`, `year`, `episodes`, `country`, `genre`, `platform`, `rating`, `ageRating`, `externalUrl`, `synopsis`, `cast[]`, `similarIds[]`), 필터 옵션, 섹션 키.
- 시드 작품 12~20개 — 포스터 URL은 public 자산 경로 또는 외부 placeholder URL. 외부 링크(`externalUrl`)는 placeholder 값.
- 필터 옵션 배열(Country/Genre/Platform). Platform은 `A`~`E` 5종 placeholder.
- `home-sections.ts` 3개 섹션(`new-releases`, `popular-picks`, `korea-picks`). 각 섹션 최대 노출 개수 상수 포함.
- 접근자: `getSection(key)`, `filterTitles({country?, genre?, platform?})`, `searchTitles(keyword)`, `getTitleById(id)`. 정렬은 기본 `Latest first` (year desc, tiebreak id).
- 무결성 검사(모든 섹션 ID가 유효한지) Vitest 테스트 1건.

## 범위 밖

- 화면 렌더링, React 컴포넌트 코드.
- 환경변수 실제 참조(`externalUrl`은 시드 값, 설문 URL은 step-03에서 도입).
- 이미지 자산 최적화/CDN 연동.
- 검색 결과 페이지네이션(클라이언트 연산만).

## 산출물

- `src/data/types.ts`, `titles.ts`, `filters.ts`, `home-sections.ts`, `accessors.ts`.
- `src/data/__tests__/accessors.test.ts` 등 Vitest 단위 테스트.
- `CLAUDE.md`에 시드 경로·타입 요약 추가.

## 승인 기준

| Criteria | Evidence Type |
| --- | --- |
| `npm run test` 스위트에서 접근자 테스트와 무결성 테스트가 모두 통과 | test |
| `tsc --noEmit` 성공 | command |
| 시드 분포 체크(최소 3개 국가/3개 장르/3개 플랫폼 노출)를 Vitest로 검증 | test |
| `home-sections.ts`의 모든 ID가 `titles.ts`에 존재하는지 Vitest로 검증 | test |
| `CLAUDE.md`에 `src/data/` 경로와 접근자 목록이 문서화 | file-check |
