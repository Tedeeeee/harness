# Development Interview Decisions

## Metadata

- Project: KEYBODER
- Last Updated: 2026-04-22

## Decisions

### Decision 1: Step 수용 기준

- Question: 각 step의 완료 기준은?
- Answer: 균형 (memory 기본값)
- Basis: Vitest + Playwright(데스크톱 뷰포트) 시나리오 1~3건 + 스크린샷 1장 이상 + verification 문서. Moyza 프로젝트에서 6/6 무재작업 검증됨.
- Decision Origin: from memory — harness-memory 기본값

### Decision 2: 문서화 범위

- Question: 어디까지 문서화?
- Answer: 표준 (memory 기본값)
- Basis: README.md + CLAUDE.md + docs/verification/. Storybook 등 MVP 과투자.
- Decision Origin: from memory — harness-memory 기본값

### Decision 3: 큐레이션 데이터 전략

- Question: Flagships/BestSellers 같은 홈 큐레이션 데이터를 어떻게 구성?
- Answer: 별도 리스트 파일 (memory 기본값)
- Basis: src/data/home-sections.ts에 섹션 키 + 제품 ID 배열. 향후 레코드 플래그로 전환 지향.
- Decision Origin: from memory — project-memory 기본값

### Decision 4: 검색 기능 MVP 범위

- Question: 프로토타입에서 비기능인 검색을 MVP에서 어떻게?
- Answer: (자동 선택 — 추천안) 키워드 검색 구현. src/data/ 시드에서 클라이언트 메모리 검색.
- Basis: 11개 화면 + 50개 이상 제품이면 검색 없으면 UX 저하. 정적 데이터이므로 클라이언트 검색으로 충분.
- Decision Origin: ai-raised-approved-by-user

### Decision 5: 결제 버튼 최종 형태

- Question: alert('결제 진행 (데모)')를 어떻게?
- Answer: (자동 선택 — 추천안) "결제 준비 중" 안내 페이지로 리다이렉트 (placeholder)
- Basis: alert는 프로토타입 티가 남. 간단한 안내 페이지가 MVP에 적합.
- Decision Origin: ai-raised-approved-by-user

## Exit Condition

- Key tech choices: confirmed (technical-approach.md)
- Test expectations: confirmed (균형 기준)
- Documentation scope: confirmed (표준)
- No remaining unresolved items blocking plan generation
