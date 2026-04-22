# 코드 컨벤션 및 패턴

## 네이밍 규칙

- 상태 문서는 `docs/<area>/...`에 의미 중심 이름을 사용한다.
- step 문서는 `step-01`, `step-02`처럼 순차 번호를 붙인다.
- 테스트 파일은 대상 이름과 맞춘 `*.test.tsx`, `*.spec.ts` 형식을 따른다.
- 데이터 타입은 `Country`, `Genre`, `Platform`, `Title`처럼 도메인 명사를 그대로 타입 이름으로 사용한다.

## 파일/폴더 구조 규칙

- 운영 문서와 구현 결과물을 분리한다.
  - 운영 프레임워크: 루트 `docs/`, `hooks/`, `skills/`, `templates/`
  - 산출물 앱: `experiments/moyza-discovery/`
- App Router 페이지는 `app/`에, 재사용 UI는 `src/components/`, 정적 데이터는 `src/data/`에 둔다.
- verification 근거 파일은 문서와 분리해서 `docs/verification/evidence/step-xx/`에 저장한다.

## 코딩 패턴

### 하네스는 공통 로직 집중, 엔트리포인트는 얇게 유지

`session_start.py`와 `user_prompt_submit.py`는 거의 orchestration만 하고, 파싱 로직은 `hooklib.py`에 모아둔다. 새로운 훅을 추가할 때도 동일한 구조를 따르는 것이 자연스럽다.

### 프런트엔드는 정적 데이터 접근자를 통해 읽기

페이지가 직접 시드 배열을 뒤지기보다 `getAllSections`, `filterTitles`, `getTitleById` 같은 접근자를 통해 읽는다. 데이터 모델을 바꿀 때 영향 범위를 좁히려는 패턴이다.

### 플래그와 환경 값은 얇은 wrapper로 감싼다

환경 변수는 `process.env`를 컴포넌트마다 직접 읽지 않고 `src/lib/env.ts`를 통해 조회한다. 런타임 변경 지점을 한곳에 모으는 패턴이다.

## 문서 운영 패턴

- requirements는 사람 입력 원본으로 취급하며 덮어쓰지 않는다.
- visual source는 requirements 전에 별도 분석 문서로 고정한다.
- completion은 대화가 아니라 verification 문서와 evidence 디렉토리로 닫는다.
- retrospective나 transition 같은 다음 역할도 문서 상태를 보고 결정한다.

## 에러 처리 패턴

- 하네스 파서 함수는 문서가 없을 때 예외보다 “빈 요약 객체”를 반환하는 쪽을 택한다.
- trace 기록은 실패해도 훅 전체를 깨지 않도록 silent no-op로 처리한다.
- 상세 페이지는 존재하지 않는 `id`에 대해 `notFound()`로 라우팅 레벨에서 처리한다.

## import 규칙

- 프런트엔드는 `@/components`, `@/data`, `@/lib` 별칭 import를 사용한다.
- Python 훅은 표준 라이브러리 우선, 로컬 모듈(`hooklib`) 단순 import 구조다.

## 테스트/검증 규칙

- step 완료는 “테스트 통과”만으로 끝나지 않고 verification 문서가 필요하다.
- UI 계약은 `data-testid`를 적극 사용해 Playwright/Vitest에서 고정 지점을 잡는다.
- 시각 검증은 스크린샷 파일과 로그를 evidence 디렉토리에 남기는 방식이다.
