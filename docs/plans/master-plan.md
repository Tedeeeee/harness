# 마스터 플랜

## 목표

KEYBODER 프로토타입 코드 번들을 기반으로 **11개 화면의 프리미엄 키보드 이커머스 웹사이트**를 `C:\study\my-new-project\`에 Next.js App Router + TypeScript + Tailwind CSS로 구현한다. 프로토타입의 디자인 토큰과 데이터/로직을 정확히 이식하되, UI는 프로덕션 스택으로 완전 재작성한다.

## 방향

- Application: Next.js 15 App Router + TypeScript. 포트 3333. 데스크톱 우선(1440px), 768px 브레이크포인트.
- Styling: Tailwind CSS + 프로토타입 CSS 변수(globals.css). 다크/라이트 테마.
- State: Zustand (cart/wishlist/theme 스토어, persist 미들웨어).
- Data: src/data/ TS 정적 시드. 제품 50건+ (키보드 12, 키캡 12, 스위치 6, 액세서리 14, 번들 3). 접근자 함수.
- Curation: src/data/home-sections.ts (Flagships/BestSellers/Reviews ID 배열).
- Testing: Vitest + Playwright (Desktop Chromium 1280x720 primary, Mobile 375px secondary).
- Prototype: 참조 전용. 데이터+로직 이식, UI 재작성, 런타임 교체.

## 포함 범위

- 11개 화면: Home(V-01), Catalog(V-02), PDP(V-03), Cart(V-04), Profile(V-05), Wishlist(V-06), Keycaps(V-07), Switches(V-08), Accessories(V-09), Magazine(V-10), Cart Drawer(V-11)
- 글로벌: Nav(스티키, 안내 스트립, 검색/찜/프로필/테마/장바구니), Footer(뉴스레터, 사이트맵, 법적 정보)
- 테마: 다크/라이트 CSS 변수 전환 + localStorage + Zustand
- 장바구니: 추가/수량변경/삭제/프로모 코드/배송 옵션/요약 계산/Cart Drawer
- 위시리스트: 추가/삭제/localStorage/정렬
- 카탈로그: 4기준 다중 필터 + AND + 6종 정렬 + 그리드/리스트 뷰 + 페이지네이션
- PDP: 갤러리/변형/스위치 선택/수량/탭(4종)/브레드크럼
- 키캡: 프로파일 필터 + 비교 시각화 + 12종 그리드
- 스위치: 타입 필터 + 비교(max 3) + 포스커브/트래블 시각화 + 6종 테이블
- 액세서리: 카테고리 필터 + 매거진형 그리드 + 번들 3세트
- 매거진: 카테고리 필터 + 커버 스토리 + 에디토리얼 그리드 + 연재 컬럼
- 프로필: 8탭 대시보드 (데모 데이터)
- 검색: 키워드 검색 (클라이언트 메모리)

## 비목표

- 실제 결제 PG 연동, 인증/로그인, 백엔드 API/DB
- 실제 오디오 재생, 실시간 재고, 주문 추적
- 뉴스레터/쿠폰/포인트 서버 처리
- TweakPanel/편집 모드, SEO, SSR, 배포
- 프로토타입 코드 직접 리팩터링

## 개발 규칙

- **기술 선택**: Next.js App Router + TS + Tailwind + Zustand. 포트 3333. 정적 시드.
- **테스트 완료 규칙**: Vitest + Playwright(데스크톱) 시나리오 1~3건 + 스크린샷 + verification 문서.
- **문서화 완료 규칙**: README.md + CLAUDE.md + docs/verification/.
- **Scope 고정**: 11개 화면 범위 내에서만. 확장 시 planner 복귀.
- **프로토타입 참조 규칙**: 원본(`C:\Users\wan\Downloads\키보드판매페이지\`)은 읽기 전용. 디자인 토큰/데이터/로직만 이식.

## 마일스톤

1. **프로젝트 스캐폴드** — Next.js App Router + TS + Tailwind + Zustand 앱을 `C:\study\my-new-project\`에 세운다. 프로토타입 CSS 변수를 globals.css에 이식. 다크/라이트 테마 기본 전환. Vitest + Playwright 구성. 포트 3333. 빈 첫 페이지의 Playwright 스크린샷이 나와야 완료.

2. **데이터 모델과 시드** — src/data/에 Product/Keycap/Switch/Accessory/Bundle/Article 타입 정의. 프로토타입의 하드코딩 데이터를 TS 시드로 이식(키보드 12, 키캡 12, 스위치 6, 액세서리 14, 번들 3, 아티클 8). 필터 옵션, 홈 섹션 큐레이션. 접근자/필터/정렬 함수 + Vitest.

3. **글로벌 레이아웃 + Nav + Footer** — layout.tsx에 Zustand Provider, 테마 전환, Nav(스티키+안내 스트립+메뉴+아이콘), Footer(뉴스레터+사이트맵+법적), Cart Drawer(슬라이드 패널). 모든 라우트에서 공유.

4. **Home 화면** — Hero(인터랙티브 키보드+마키), Flagships(3종), Advantages(4종), BestSellers(8종+필터+정렬), Reviews(4건), LaunchBanner(카운트다운). 프로토타입의 애니메이션 이식.

5. **Catalog + Search** — /catalog 라우트. 사이드바 4기준 다중 필터 + AND + 6종 정렬 + 그리드/리스트 뷰 + 페이지네이션 + 빈 결과. /search 또는 Nav 검색에서 키워드 검색.

6. **Product Detail** — /products/[id] 라우트. 갤러리(4뷰), 변형/스위치 선택, 수량, 장바구니 담기, 탭(상세/스펙/리뷰/배송), 브레드크럼.

7. **Cart + Checkout** — /cart 라우트. 전체/개별 선택, 수량 조절, 배송/포장 옵션, 프로모 코드, 요약 계산, 추천 상품, 결제 placeholder 페이지.

8. **Keycaps + Switches + Accessories** — /keycaps, /switches, /accessories 3개 라우트. 프로파일 비교, 포스커브/트래블 시각화, 매거진형 그리드, 번들.

9. **Magazine + Profile + Wishlist** — /magazine, /profile, /wishlist 3개 라우트. 에디토리얼 그리드, 8탭 대시보드(데모 데이터), 찜 목록.

10. **마감 + 회귀 + Visual Pass** — E2E 전체 회귀, 테마 전환 전 화면 검증, 반응형 확인, placeholder 지점 문서화, README/CLAUDE.md 최종 정리.

## 위험

- **규모**: 11개 화면은 Moyza(3개 화면)보다 훨씬 큼. step당 1~2개 화면씩 분할해 관리.
- **Tailwind 커스텀**: 프로토타입의 정밀한 shadow/gradient/animation을 Tailwind로 매핑하려면 커스텀 설정이 많이 필요. step-01에서 tailwind.config 기반을 잡아야 함.
- **데이터 볼륨**: 50건+ 시드 데이터를 정확히 이식해야 필터/검색이 의미 있게 동작.
