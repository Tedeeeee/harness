# Visual Source Analysis

## Summary

- Source File: `C:\Users\wan\Downloads\키보드판매페이지\` (index.html + styles.css + components/*.jsx)
- Source Type: HTML / JSX / CSS prototype code bundle
- Coverage Mode: all-visible-screens
- Input Mode: prototype-code-primary
- Last Updated: 2026-04-22

## Global Directives

- 다크/라이트 테마 전환 지원 (CSS 변수 기반, localStorage 연동) [explicit, styles.css + App.jsx]
- Pretendard Variable (본문) + Inter Tight (영문 디스플레이) + JetBrains Mono (레이블/가격) 폰트 체계 [explicit, styles.css]
- 머스터드 골드 (`#C8922B` light / `#E0B04A` dark) 악센트 컬러 [explicit, styles.css :root]
- 최대 너비 1440px 중앙 정렬 컨테이너, 데스크톱 48px · 모바일(768px 이하) 20px 패딩 [explicit, styles.css .container]
- 글로벌 스크롤바 커스텀, `::selection` 악센트 [explicit, styles.css]
- 한국어 UI 텍스트 기본, 제품명·라벨 일부 영문 [explicit, 전 컴포넌트]

## Screen Inventory

| ID | Screen | Source Page / Frame | Entry Path / Navigation | Core Visible Elements | Mandatory Changes | Inclusion Status | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V-01 | Home | App.jsx page==='home' | 초기 진입, 로고 클릭 | Nav, Hero(인터랙티브 키보드+스위치 선택+마키), Flagships(3종), Advantages(4종), BestSellers(8종 그리드+필터+정렬), Reviews(4건), LaunchBanner(카운트다운), Footer | - | included | `explicit` |
| V-02 | Catalog (PLP) | CatalogPage.jsx | Nav '키보드' 클릭 | 사이드바 필터(레이아웃/스위치/바디/가격), 정렬 드롭다운, 그리드/리스트 뷰 전환, 12종 제품 카드, 페이지네이션, 활성 필터 칩 | - | included | `explicit` |
| V-03 | Product Detail (PDP) | ProductPage.jsx | 제품 카드 클릭 | 4뷰 갤러리, 변형(colorway) 선택, 스위치 선택, 수량 조절, 장바구니/구매 버튼, 탭(상세/스펙/리뷰/배송), 하이라이트 3종, 박스 구성품, 리뷰 요약 | - | included | `explicit`. 현재 kb78-pro만 상세 데이터 있음 |
| V-04 | Cart Page | CartPage.jsx | Nav 장바구니 클릭 | 진행 단계 표시(3단계), 전체 선택/개별 선택, 수량 조절, 배송 방법(일반/특급), 선물 포장, 프로모 코드 입력, 결제 요약(소계/할인/배송/총액), 결제 수단 배지, 추천 상품 3종 | - | included | `explicit` |
| V-05 | Profile (My Page) | ProfilePage.jsx | Nav 사용자 아이콘 클릭 | 히어로(아바타+등급+포인트), 주문 상태 스트립, 8탭 사이드바(대시보드/컬렉션/주문/찜/리뷰/AS/쿠폰/설정), 각 탭별 콘텐츠 | - | included | `explicit`. 데이터 전부 하드코딩 |
| V-06 | Wishlist | WishlistPage.jsx (App.jsx 내) | Nav 하트 아이콘 클릭 | 정렬(최근/이름순), 제품 카드 그리드, 찜 해제, 장바구니 담기, 빈 상태 | - | included | `explicit` |
| V-07 | Keycaps | KeycapsPage.jsx | Nav '키캡' 클릭 | 프로파일 필터(Cherry/OEM/SA/DSA/KAT), 프로파일 비교 시각화, 12종 키캡 세트 그리드, 정렬, 가이드 에디토리얼 | - | included | `explicit` |
| V-08 | Switches | SwitchesPage.jsx | Nav '스위치' 클릭 | 타입 필터(Linear/Tactile/Clicky), 비교 선택(최대 3개), 포스 커브 시각화, 트래블 시각화, 사운드 프로파일, 6종 스위치 테이블 | - | included | `explicit` |
| V-09 | Accessories | AccessoriesPage.jsx | Nav '액세서리' 클릭 | 카테고리 칩 필터(6종), 14종 액세서리 매거진형 그리드, 번들 3세트 | - | included | `explicit` |
| V-10 | Magazine | MagazinePage.jsx | Nav '매거진' 클릭 | 마스트헤드, 커버 스토리, 카테고리 필터(7종), 8건 에디토리얼 그리드, 연재 컬럼 3종, 뉴스레터 구독 | - | included | `explicit` |
| V-11 | Cart Drawer | CartDrawer.jsx | 장바구니 버튼 (사이드 패널) | 460px 오른쪽 드로어, 항목 목록, 수량 조절, 소계/배송/총액, 결제 버튼, 빈 상태 | - | included | `explicit`. 현재 open=false 고정 |

## Interaction Inventory

- Interaction: 테마 전환
  - Type: toggle
  - Trigger: Nav 해/달 아이콘 클릭
  - Result: data-theme 속성 변경 + localStorage 저장 + CSS 변수 전환
  - Confidence: `explicit`
  - Source Ref: App.jsx handleToggleTheme, Nav.jsx

- Interaction: 장바구니 추가
  - Type: action
  - Trigger: 제품 카드/상세 "장바구니 담기" 버튼
  - Result: cart 배열에 항목 추가/수량 증가, 확인 피드백 1.5~2초
  - Confidence: `explicit`
  - Source Ref: App.jsx handleAdd, BestSellers.jsx, ProductPage.jsx

- Interaction: 장바구니 수량 변경
  - Type: stepper
  - Trigger: +/- 버튼
  - Result: 수량 변경, 0이면 제거
  - Confidence: `explicit`
  - Source Ref: CartPage.jsx, CartDrawer.jsx, ProductPage.jsx

- Interaction: 찜 토글
  - Type: toggle
  - Trigger: 하트 아이콘 클릭
  - Result: wishlist 배열 추가/제거 + localStorage 저장 + 토스트 알림 1.8초
  - Confidence: `explicit`
  - Source Ref: App.jsx toggleWish

- Interaction: 카탈로그 필터
  - Type: multi-select filter
  - Trigger: 사이드바 체크박스, 활성 필터 칩 X 클릭
  - Result: 4기준(레이아웃/스위치/바디/가격) AND 논리 필터링
  - Confidence: `explicit`
  - Source Ref: CatalogPage.jsx

- Interaction: 정렬
  - Type: dropdown select
  - Trigger: 정렬 드롭다운 변경
  - Result: 제품 목록 재정렬 (인기순=rating*reviews, 가격순, 신상품순 등)
  - Confidence: `explicit`
  - Source Ref: CatalogPage.jsx, BestSellers.jsx

- Interaction: 뷰 전환
  - Type: toggle
  - Trigger: 그리드/리스트 아이콘 버튼
  - Result: 카탈로그 레이아웃 변경
  - Confidence: `explicit`
  - Source Ref: CatalogPage.jsx

- Interaction: 제품 변형 선택
  - Type: radio select
  - Trigger: colorway 스와치 클릭
  - Result: 선택 변형 변경, 품절 변형은 선택 불가
  - Confidence: `explicit`
  - Source Ref: ProductPage.jsx

- Interaction: 스위치 선택
  - Type: radio select
  - Trigger: 스위치 옵션 클릭
  - Result: 선택 스위치 변경
  - Confidence: `explicit`
  - Source Ref: ProductPage.jsx

- Interaction: 프로모 코드
  - Type: form submit
  - Trigger: 코드 입력 + "적용" 버튼
  - Result: KEYBODER10 입력 시 10% 할인, 그 외 오류
  - Confidence: `demo-suspect` (하드코딩 검증, 실제 서버 검증 필요)
  - Source Ref: CartPage.jsx

- Interaction: 배송 방법 선택
  - Type: radio select
  - Trigger: 일반/특급 라디오 버튼
  - Result: 배송비 변경 (일반 3000원/10만 이상 무료, 특급 7000원)
  - Confidence: `explicit`
  - Source Ref: CartPage.jsx

- Interaction: 선물 포장
  - Type: checkbox toggle
  - Trigger: 선물 포장 체크박스
  - Result: +5000원 추가
  - Confidence: `explicit`
  - Source Ref: CartPage.jsx

- Interaction: 결제 진행
  - Type: action
  - Trigger: "결제하기" 버튼
  - Result: alert('결제 진행 (데모)')
  - Confidence: `demo-suspect` (실제 결제 미구현)
  - Source Ref: App.jsx checkout

- Interaction: 키캡 프로파일 비교
  - Type: filter + visualization
  - Trigger: 프로파일 버튼 클릭
  - Result: 필터링 + 높이 비교 시각화
  - Confidence: `explicit`
  - Source Ref: KeycapsPage.jsx

- Interaction: 스위치 비교
  - Type: multi-select (max 3)
  - Trigger: 비교 버튼 토글
  - Result: 최대 3개 선택, 포스커브/트래블/사운드 비교
  - Confidence: `explicit`
  - Source Ref: SwitchesPage.jsx

- Interaction: 검색
  - Type: action
  - Trigger: Nav 검색 아이콘
  - Result: 없음 (비기능)
  - Confidence: `demo-suspect`
  - Source Ref: Nav.jsx

- Interaction: 사운드 재생
  - Type: action
  - Trigger: Hero 사운드 버튼, SwitchesPage 재생 버튼
  - Result: 없음 (비기능)
  - Confidence: `demo-suspect`
  - Source Ref: Hero.jsx, SwitchesPage.jsx

- Interaction: 뉴스레터 구독
  - Type: form submit
  - Trigger: 이메일 입력 + "구독하기" 버튼
  - Result: 없음 (비기능)
  - Confidence: `needs-confirm` (제품 의도는 있으나 구현 없음)
  - Source Ref: MagazinePage.jsx, Footer.jsx

## Route / Navigation Signals

- Route or state: home
  - Entry: 초기 진입, 로고 클릭, goHome()
  - Exit or next state: 제품 클릭 → product, Nav 메뉴 → 각 페이지
  - Confidence: `explicit`
  - Source Ref: App.jsx page state

- Route or state: catalog
  - Entry: Nav '키보드', goCatalog()
  - Exit or next state: 제품 클릭 → product
  - Confidence: `explicit`
  - Source Ref: App.jsx, CatalogPage.jsx

- Route or state: product (동적, ID 기반)
  - Entry: openProduct(id)
  - Exit or next state: 뒤로가기 → 이전 페이지
  - Confidence: `explicit`
  - Source Ref: App.jsx, ProductPage.jsx

- Route or state: cart
  - Entry: Nav 장바구니 클릭
  - Exit or next state: 쇼핑 계속 → home, 결제 → alert (데모)
  - Confidence: `explicit`
  - Source Ref: App.jsx, CartPage.jsx

- Route or state: profile
  - Entry: Nav 사용자 아이콘, goProfile()
  - Exit or next state: 탭 내비게이션 (8탭)
  - Confidence: `explicit`
  - Source Ref: App.jsx, ProfilePage.jsx

- Route or state: wishlist
  - Entry: Nav 하트 아이콘, goWishlist()
  - Exit or next state: 제품 클릭 → product, 홈으로 → home
  - Confidence: `explicit`
  - Source Ref: App.jsx, WishlistPage.jsx

- Route or state: keycaps
  - Entry: Nav '키캡'
  - Exit or next state: Nav 메뉴
  - Confidence: `explicit`
  - Source Ref: App.jsx, KeycapsPage.jsx

- Route or state: switches
  - Entry: Nav '스위치'
  - Exit or next state: Nav 메뉴
  - Confidence: `explicit`
  - Source Ref: App.jsx, SwitchesPage.jsx

- Route or state: accessories
  - Entry: Nav '액세서리'
  - Exit or next state: Nav 메뉴
  - Confidence: `explicit`
  - Source Ref: App.jsx, AccessoriesPage.jsx

- Route or state: magazine
  - Entry: Nav '매거진'
  - Exit or next state: Nav 메뉴
  - Confidence: `explicit`
  - Source Ref: App.jsx, MagazinePage.jsx

## Data / Entity Signals

- Entity or state concept: Product (키보드)
  - Fields or properties observed: id, name, cat, price, original, rating, reviews, tag, color, switch, body, weight, stock, accent, subtitle, tagline
  - Product meaning: 핵심 상품 엔티티, 카탈로그/상세/장바구니 전체에서 사용
  - Confidence: `explicit`
  - Source Ref: BestSellers.jsx PRODUCTS, CatalogPage.jsx CATALOG, Flagships.jsx FLAGSHIPS

- Entity or state concept: ProductDetail (상세 스펙)
  - Fields or properties observed: variants[{id,label,color,available}], switches[{id,label,force,travel,default}], specs[{k,v}], highlights[{num,title,body}], includes[]
  - Product meaning: PDP 전용 확장 데이터
  - Confidence: `explicit`
  - Source Ref: ProductPage.jsx PRODUCT_DETAILS

- Entity or state concept: Keycap (키캡 세트)
  - Fields or properties observed: id, name, profile, material, kits, price, color1, color2, accent, tag
  - Product meaning: 키캡 카테고리 상품
  - Confidence: `explicit`
  - Source Ref: KeycapsPage.jsx KEYCAPS

- Entity or state concept: Switch (스위치)
  - Fields or properties observed: id, name, type, brand, actuation, bottom, pretravel, total, sound, color, price, pack, tag, desc
  - Product meaning: 스위치 카테고리 상품 + 기술 스펙
  - Confidence: `explicit`
  - Source Ref: SwitchesPage.jsx SWITCHES

- Entity or state concept: Accessory (액세서리)
  - Fields or properties observed: id, cat, name, price, material, size, color, tag
  - Product meaning: 액세서리 카테고리 상품
  - Confidence: `explicit`
  - Source Ref: AccessoriesPage.jsx ACCESSORIES

- Entity or state concept: Bundle (번들 세트)
  - Fields or properties observed: title, items[], price, orig
  - Product meaning: 큐레이션 번들 상품
  - Confidence: `explicit`
  - Source Ref: AccessoriesPage.jsx BUNDLES

- Entity or state concept: CartItem (장바구니 항목)
  - Fields or properties observed: id, name, cat, switch, color, price, qty
  - Product meaning: 장바구니 상태
  - Confidence: `explicit`
  - Source Ref: App.jsx cart, CartPage.jsx

- Entity or state concept: WishlistItem (찜 항목)
  - Fields or properties observed: id, name, savedAt, ...product fields
  - Product meaning: 위시리스트 상태
  - Confidence: `explicit`
  - Source Ref: App.jsx wishlist

- Entity or state concept: User (회원)
  - Fields or properties observed: name, handle, joined, tier, tierNext, points, coupons, lifetimeSpent, avatar, bio, tierProgress
  - Product meaning: 회원/등급 시스템
  - Confidence: `needs-confirm` (데모 데이터만 존재, 인증 시스템 없음)
  - Source Ref: ProfilePage.jsx USER

- Entity or state concept: Order (주문)
  - Fields or properties observed: id, date, status, items[], total, tracking
  - Product meaning: 주문 이력
  - Confidence: `needs-confirm` (데모 데이터만 존재)
  - Source Ref: ProfilePage.jsx RECENT_ORDERS

- Entity or state concept: Coupon (쿠폰)
  - Fields or properties observed: type, title, desc, code, exp, minOrder
  - Product meaning: 할인 쿠폰
  - Confidence: `needs-confirm` (데모 데이터만 존재)
  - Source Ref: ProfilePage.jsx COUPONS

- Entity or state concept: Article (매거진 글)
  - Fields or properties observed: cat, title, dek, author, date, read, color, size
  - Product meaning: 에디토리얼 콘텐츠
  - Confidence: `explicit`
  - Source Ref: MagazinePage.jsx ARTICLES

## Design Token Signals

- Token or theme signal: Color Palette (Light)
  - Value or pattern: --bg:#FAFAF7, --bg-elev:#FFFFFF, --bg-subtle:#F1F0EA, --ink:#0E0E0C, --ink-2:#2A2A27, --ink-3:#6B6B63, --ink-4:#9A9A90, --line:#E4E2D8, --line-strong:#1A1A17, --accent:#C8922B, --accent-soft:#F4E4B8, --danger:#B23A1E
  - Scope: global
  - Confidence: `explicit`
  - Source Ref: styles.css :root

- Token or theme signal: Color Palette (Dark)
  - Value or pattern: --bg:#0E0E0C, --bg-elev:#161614, --bg-subtle:#1E1E1B, --ink:#F5F4EE, --ink-2:#D6D5CD, --ink-3:#8D8C84, --ink-4:#58574F, --line:#262622, --line-strong:#F5F4EE, --accent:#E0B04A, --accent-soft:#3A2E15, --danger:#E66A4E
  - Scope: global
  - Confidence: `explicit`
  - Source Ref: styles.css [data-theme="dark"]

- Token or theme signal: Typography
  - Value or pattern: Pretendard Variable (본문, -0.01em), Inter Tight (영문 디스플레이, -0.02em), JetBrains Mono (레이블/가격, tnum)
  - Scope: global
  - Confidence: `explicit`
  - Source Ref: styles.css @import, .mono, .eng

- Token or theme signal: Shadows
  - Value or pattern: --shadow-sm, --shadow-md, --shadow-lg (light/dark 각각 정의)
  - Scope: global
  - Confidence: `explicit`
  - Source Ref: styles.css

- Token or theme signal: Spacing / Layout
  - Value or pattern: 컨테이너 max-width 1440px, 데스크톱 padding 48px, 모바일 20px, 섹션 간격 120px, 그리드 gap 24px
  - Scope: global
  - Confidence: `explicit`
  - Source Ref: styles.css, 각 컴포넌트 inline styles

- Token or theme signal: Button Styles
  - Value or pattern: padding 16px 28px, font 15px weight 500, border-radius 2px, 3종 (primary/outline/ghost)
  - Scope: global
  - Confidence: `explicit`
  - Source Ref: styles.css .btn*

- Token or theme signal: Animations
  - Value or pattern: keypress(0.5s), ripple(1s), waveline(0.3s), fadeUp(0.7s cubic-bezier), marquee(40s)
  - Scope: Hero 중심
  - Confidence: `explicit`
  - Source Ref: styles.css, Hero.jsx inline

## Prototype-only Implementation Notes

- Note: Babel standalone 브라우저 트랜스파일
  - Why it may be demo-only: 프로덕션에서는 빌드 도구(Vite/Webpack) 사용 필수
  - Confidence: `demo-suspect`
  - Source Ref: index.html script tags

- Note: TweakPanel 편집 모드
  - Why it may be demo-only: postMessage 프로토콜로 외부 제어, EDITMODE 마커 주석
  - Confidence: `demo-suspect`
  - Source Ref: App.jsx TweakPanel, EDITMODE-BEGIN/END

- Note: 악센트 컬러 런타임 변경
  - Why it may be demo-only: 6색 스와치 실시간 교체는 프로토타입 프레젠테이션용
  - Confidence: `demo-suspect`
  - Source Ref: App.jsx accent state, TweakPanel

- Note: alert('결제 진행 (데모)')
  - Why it may be demo-only: 실제 결제 플로우 없음, 명시적 "(데모)" 표기
  - Confidence: `demo-suspect`
  - Source Ref: App.jsx checkout

- Note: 하드코딩 프로모 코드 검증
  - Why it may be demo-only: 'KEYBODER10'만 인식, 서버 검증 없음
  - Confidence: `demo-suspect`
  - Source Ref: CartPage.jsx promo validation

- Note: BestSellers 제품 클릭 고정 ID
  - Why it may be demo-only: onOpen('kb78-pro') 하드코딩, 실제로는 onOpen(p.id)여야 함
  - Confidence: `demo-suspect`
  - Source Ref: BestSellers.jsx line ~66

- Note: CartDrawer open=false 고정
  - Why it may be demo-only: 드로어 UI는 있으나 열리지 않음
  - Confidence: `demo-suspect`
  - Source Ref: App.jsx CartDrawer render

- Note: 전체 제품 데이터 인라인 하드코딩
  - Why it may be demo-only: PRODUCTS, CATALOG, KEYCAPS, SWITCHES 등 컴포넌트 내부 배열
  - Confidence: `demo-suspect`
  - Source Ref: 각 페이지 컴포넌트 상수

- Note: 프로필 사용자 데이터 하드코딩
  - Why it may be demo-only: 김타건 프로필, 주문 이력, 쿠폰 등 전부 픽스처
  - Confidence: `demo-suspect`
  - Source Ref: ProfilePage.jsx USER, RECENT_ORDERS 등

- Note: 검색 기능 미구현
  - Why it may be demo-only: 아이콘만 존재, 클릭 시 동작 없음
  - Confidence: `demo-suspect`
  - Source Ref: Nav.jsx search button

- Note: 사운드 재생 미구현
  - Why it may be demo-only: 버튼/파형 시각화는 있으나 오디오 없음
  - Confidence: `demo-suspect`
  - Source Ref: Hero.jsx, SwitchesPage.jsx

## Exclusions

- Screen: 없음 (전체 11개 화면 포함)
  - Reason: 프로토타입의 모든 화면이 제품 의도를 가짐
  - User Approved: n/a

## Ambiguities

- 프로필/주문/쿠폰/AS 시스템이 MVP 범위에 포함되는지 확인 필요 (인증/백엔드 의존)
- 검색 기능이 제품 요구인지 향후 기능인지 확인 필요
- 사운드 재생이 제품 요구인지 향후 기능인지 확인 필요
- 뉴스레터 구독이 MVP에 포함되는지 확인 필요
- 결제 플로우의 실제 범위 (데모 alert → 실제 PG 연동까지?)

## Clarifying Question

- Resolved: 사용자가 Option C (전체 11개 화면) 선택. 2026-04-22.

## Requirements Promotion Notes

- Screens that must appear in requirements: V-01(Home), V-02(Catalog), V-03(PDP), V-04(Cart) — 이커머스 핵심 플로우
- Global directives that must become implementation rules: 테마 전환, 디자인 토큰 체계, 폰트 체계, 컨테이너 레이아웃
- Items safe to promote as product requirements: 장바구니 CRUD, 필터/정렬, 제품 변형 선택, 찜 토글, 다크모드
- Items that must not be promoted directly: TweakPanel, Babel standalone, 하드코딩 데이터, alert 결제, postMessage 편집 프로토콜
- Ambiguities that must be resolved before requirements authoring: MVP 화면 범위 (위 질문 참조)
