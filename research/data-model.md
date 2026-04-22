# 데이터 모델

## 개요

이 프로젝트에는 DB 스키마는 없지만, 실험 앱이 사용하는 정적 도메인 모델과 운영 환경 값이 명확히 존재한다. 실제 기능 변경 시 가장 많이 건드리게 되는 모델은 `Title`과 홈 섹션 구성이다.

## 주요 엔티티

## Title

- **위치**: `experiments/moyza-discovery/src/data/types.ts`
- **필드**:
  - `id`: 작품 식별자 (`t-01` 형식)
  - `title`: 작품명
  - `posterUrl`: 포스터 경로
  - `year`, `episodes`
  - `country`, `genre`, `platform`: 필터 가능한 범주형 값
  - `rating`, `ageRating`
  - `externalUrl`: `Watch Now` 외부 링크
  - `synopsis`
  - `cast`: 이름 목록
  - `similarIds`: 연관 작품 id 목록
  - `isTop?`: TOP 배지 여부

## HomeSection

- **위치**: `experiments/moyza-discovery/src/data/types.ts`, `home-sections.ts`
- **역할**: 홈 화면 가로 섹션 정의
- **핵심 필드**:
  - `key`
  - `label`
  - `titleIds`
  - `maxItems`

`ResolvedHomeSection`은 여기에 실제 `Title[]`를 매핑한 결과 타입이다.

## FilterSelection

- **위치**: `experiments/moyza-discovery/src/data/types.ts`
- **역할**: 검색/필터 화면의 현재 선택 상태 표현
- **특징**:
  - 각 필드는 단일 값 또는 배열 값을 모두 허용한다.
  - `keyword`는 title과 cast 이름에 대해 부분 검색으로 적용된다.

## 열거형 값

- `Country`: `USA | Korea | China | Japan`
- `Genre`: `Romance | Horror | Action | Comedy | B/L`
- `Platform`: `A | B | C | D | E`

현재는 요구사항 문서 기준 더미 플랫폼 라벨을 그대로 사용한다.

## 파생 데이터

- `TITLES_BY_ID`: `titles.ts` 배열을 `Map`으로 변환한 조회 인덱스
- `getAllSections()`: 홈 섹션 키를 실제 카드 리스트로 풀어낸 결과
- `filterTitles()`: 국가/장르/플랫폼/키워드 조합 필터 + 최신순 정렬

## 운영 환경 값

## 설문 URL

- **위치**: `experiments/moyza-discovery/src/lib/env.ts`
- **환경 변수**: `NEXT_PUBLIC_SURVEY_URL`
- **기본값**: `https://example.invalid/survey`
- **사용 지점**: 홈/상세 설문 배너, 하단 `Board` 탭

## 플랫폼 배지 노출 플래그

- **환경 변수**: `NEXT_PUBLIC_SHOW_PLATFORM_BADGES`
- **의미**: `"true"`일 때만 플랫폼 배지 렌더링
- **배경**: 요구사항에서 플랫폼 배지 블록은 MVP 기본 숨김으로 정의됨

## 모델 변경 시 유의점

- `platform`의 실제 라벨을 확정하면 `types.ts`, `filters.ts`, 시드 데이터, 관련 테스트가 함께 바뀐다.
- `externalUrl` 구조가 바뀌면 `WatchNowBar`와 E2E 회귀 테스트도 같이 갱신해야 한다.
- `Title` 필드 확장은 대부분 `MetaTable`, `SynopsisPanel`, `accessors.test.ts`에 영향을 준다.
