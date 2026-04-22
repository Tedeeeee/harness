# Product Requirements

## Metadata

- Status: confirmed
- Confirmed By: taesik (KEYBODER 프로젝트 오너)
- Confirmed At: 2026-04-22
- Linked Planning State: docs/plans/planning-state.md

## Input Sources

- Primary Text Input: 사용자 요청 — "키보드판매페이지 HTML 프로토타입을 기반으로 전체 11개 화면 재구현"
- Visual Source of Truth: 없음 (PDF/이미지 없음)
- Prototype Source Input: `C:\Users\wan\Downloads\키보드판매페이지\` (HTML/JSX/CSS, Claude Design 산출물)
- Notes:
  - 분석 문서: `docs/visual-analysis/visual-source-analysis.md`
  - 프로토타입은 Babel standalone + UMD React 기반 데모. 제품은 Next.js App Router + TypeScript로 재구현.
  - 원본 폴더는 읽기 전용 참조. 구현은 `C:\study\my-new-project\`에서 진행.

## Goal

KEYBODER(키보더) 브랜드의 **프리미엄 기계식 키보드 이커머스 웹사이트**를 프로토타입 코드 기반으로 구축한다. Home부터 Magazine까지 11개 화면, 다크/라이트 테마, 장바구니, 위시리스트, 카탈로그 필터/정렬, 제품 상세, 프로필 대시보드를 포함하는 풀 기능 프론트엔드.

## Problem

키보드 브랜드가 제품 라인업(키보드, 키캡, 스위치, 액세서리)을 한 곳에서 탐색하고 구매 플로우까지 경험할 수 있는 웹사이트가 필요하다. 프로토타입이 이미 완성 수준으로 존재하지만 Babel standalone/하드코딩 데이터/인라인 스타일로 되어 있어 프로덕션 스택으로 재구현해야 한다.

## Users

- Primary user: 기계식 키보드에 관심 있는 소비자. 제품을 탐색, 비교, 필터링하고 장바구니에 담는 목적.
- Secondary user: 브랜드 운영자. 제품/콘텐츠 데이터를 관리하고 매거진을 통해 커뮤니티를 형성하는 목적.

## Core Features

1. **Home 화면** (V-01)
   - 스티키 Nav: 로고, 메뉴 7종(신제품/키보드/키캡/스위치/액세서리/매거진), 검색/찜/프로필/테마/장바구니 아이콘
   - 안내 스트립: 무료배송 조건, 당일 출고 마감
   - Hero: 인터랙티브 키보드 시각화(키캡 프레스 애니메이션), 스위치 타입 선택(Linear/Tactile/Clicky), 마키 배너
   - Flagships: 3종 시그니처 제품 카드 (KB-78 Pro, KB-65 Air, KB-104 Studio)
   - Advantages: 4종 특장점 (사운드/무선/핫스왑/보증)
   - BestSellers: 8종 제품 그리드 + 카테고리 필터 + 정렬
   - Reviews: 4건 고객 후기
   - LaunchBanner: 한정판 사전예약 + 카운트다운 타이머
   - Footer: 뉴스레터, 소셜 링크, 사이트맵, 법적 정보

2. **Catalog 화면** (V-02)
   - 사이드바 필터: 레이아웃(60%~NUMPAD), 스위치(Linear/Tactile/Clicky), 바디(알루미늄/폴리카보네이트 등), 가격대(4구간)
   - 다중 선택 필터 + AND 논리 + 활성 필터 칩 + 초기화
   - 정렬: 추천순/인기순/신상품순/가격순/리뷰순
   - 그리드/리스트 뷰 전환
   - 12종 제품 카드 + 페이지네이션
   - 빈 결과 상태 메시지

3. **Product Detail 화면** (V-03)
   - 4뷰 갤러리 (TOP/ANGLE/SIDE/KEYCAP) + 썸네일 선택
   - 변형(colorway) 선택: Graphite/Ivory/Olive/Terracotta (품절 표시)
   - 스위치 선택: 3종 라디오 (force/travel 스펙)
   - 수량 조절 + 총액 계산
   - "장바구니 담기" + 성공 피드백
   - 탭: 상세정보(하이라이트 3종 + 박스 구성품) / 스펙(기술 스펙 표) / 리뷰(별점 요약 + 분포 + 4건) / 배송·교환(정책)
   - 브레드크럼 내비게이션

4. **Cart 화면** (V-04)
   - 진행 단계 표시 (장바구니 → 배송 정보 → 결제)
   - 전체/개별 선택 체크박스 + 선택 삭제
   - 항목별 수량 조절 + 가격 계산
   - 배송 방법: 일반(3,000원/10만 이상 무료) / 특급(7,000원)
   - 선물 포장 옵션 (+5,000원)
   - 프로모 코드 입력 + 검증 [undecided: 서버 검증 vs 클라이언트 검증]
   - 결제 요약: 소계/할인/배송/포장/총액/적립 포인트(3%)
   - 무료배송 진행바 (10만원 미달 시)
   - 결제 수단 배지 (VISA/MASTER/TOSS/KAKAO/NAVER) — 디스플레이용
   - 추천 상품 3종
   - 결제 버튼 [undecided: 실제 PG 연동 범위]

5. **Profile 화면** (V-05)
   - 히어로: 아바타 + 이름 + 등급(CHERRY→BRASS) + 진행바 + 포인트/쿠폰/누적 구매
   - 주문 상태 스트립 (5단계 카운트)
   - 8탭 대시보드:
     - 대시보드: 리뷰 요청 알림, 내 키보드 미리보기, 최근 주문, 활동 타임라인
     - 컬렉션: 보유 키보드 카드 (보유일/타건수/구매연도)
     - 주문 내역: 기간 필터 + 주문 목록 + 상태 칩 + 추적
     - 찜 목록: 가격 변동 배지 + 재고 상태
     - 리뷰 관리: 작성 대기/완료 탭 + 포인트 보상
     - A/S 내역: 보증/응답/수리 기간 + 이력
     - 쿠폰·포인트: 포인트 잔액 + 만료 예정 + 쿠폰 카드(등급/생일/카테고리)
     - 계정 설정: 기본 정보/배송·결제/알림·구독
   - [undecided: 인증/로그인 시스템 범위]

6. **Wishlist 화면** (V-06)
   - 정렬 (최근 찜/이름순)
   - 제품 카드 그리드 + 찜 해제 + 장바구니 담기
   - 찜 경과 일수 배지
   - 빈 상태 + "카탈로그 전체 보기" CTA

7. **Keycaps 화면** (V-07)
   - 프로파일 필터 (Cherry/OEM/SA/DSA/KAT)
   - 프로파일 높이 비교 시각화
   - 12종 키캡 세트 그리드 + 정렬
   - 3D 키캡 스택 시각화
   - "처음 사는 키캡" 가이드 에디토리얼

8. **Switches 화면** (V-08)
   - 타입 필터 (Linear/Tactile/Clicky)
   - 비교 선택 (최대 3개)
   - 포스 커브 시각화 (10개 바, 타입별 곡선)
   - 트래블 시각화 (프리트래블 포인트)
   - 사운드 프로파일 파형 [undecided: 실제 오디오 재생 여부]
   - 6종 스위치 테이블

9. **Accessories 화면** (V-09)
   - 카테고리 칩 필터 (6종: 팜레스트/케이블/데스크매트/유지보수/케이스/녹음)
   - 14종 액세서리 매거진형 그리드 (7번째마다 큰 카드)
   - 번들 3세트 (할인가 표시)

10. **Magazine 화면** (V-10)
    - 마스트헤드 (THE KEYBODER)
    - 커버 스토리 (이슈/시즌)
    - 카테고리 필터 (7종: ESSAY/REVIEW/INTERVIEW/GUIDE/ARCHIVE/JOURNAL)
    - 8건 에디토리얼 그리드 (크기 변형: normal/wide/tall)
    - 연재 컬럼 3종
    - 뉴스레터 구독 폼 [undecided: 실제 구독 처리 여부]

11. **Cart Drawer** (V-11)
    - 460px 오른쪽 슬라이드 드로어
    - 항목 목록 + 수량 조절
    - 소계/배송/총액
    - 결제 버튼
    - 빈 상태

## Out of Scope

- 실제 결제 PG 연동 (UI까지만, alert 등 placeholder)
- 사용자 인증/로그인 시스템 (프로필은 데모 데이터로 구현)
- 백엔드 API/DB (정적 시드 데이터로 구현)
- 실제 오디오 파일 재생 (스위치 사운드 시각화만)
- 실시간 재고 관리
- 주문 추적 시스템
- 실제 뉴스레터 발송
- 실제 쿠폰/포인트 서버 처리
- TweakPanel / 편집 모드 / postMessage 프로토콜
- SEO 최적화, 서버 사이드 렌더링 (dev 모드 검증까지)
- 호스팅/배포

## Constraints

- 기술: Next.js App Router + TypeScript, 포트 3333
- 데이터: TS 정적 시드 모듈 (프로토타입의 하드코딩 데이터를 타입 안전하게 이식)
- 스타일: 프로토타입의 CSS 변수/디자인 토큰 체계를 그대로 이식 (인라인 스타일은 CSS Modules 또는 글로벌 CSS로 전환)
- 테스트: Vitest + Playwright
- 구현 디렉토리: `C:\study\my-new-project\`
- 원본 프로토타입: 읽기 전용 참조

## Prototype Input Notes

- Product behaviors promoted from prototype input:
  - 테마 전환 (다크/라이트, localStorage 연동) [explicit]
  - 장바구니 CRUD (추가/수량변경/삭제) [explicit]
  - 위시리스트 토글 (localStorage 연동) [explicit]
  - 카탈로그 다중 필터 + AND 논리 + 6종 정렬 [explicit]
  - 제품 변형/스위치 선택 [explicit]
  - 프로모 코드 할인 계산 [explicit]
  - 배송/포장 옵션 + 요약 계산 [explicit]
  - 카운트다운 타이머 [explicit]
  - 키캡 프로파일 비교, 스위치 포스커브/트래블 시각화 [explicit]
  - 매거진 에디토리얼 레이아웃 [explicit]

- Prototype-only implementation details not promoted:
  - Babel standalone 브라우저 트랜스파일 → Next.js 빌드
  - TweakPanel / 편집 모드 / postMessage 프로토콜
  - 악센트 컬러 런타임 변경 (6색 스와치)
  - alert('결제 진행 (데모)') → [undecided] placeholder
  - BestSellers 하드코딩 ID (onOpen('kb78-pro')) → 실제 ID 연결
  - CartDrawer open=false 고정 → 실제 토글
  - 전체 인라인 스타일 → CSS 시스템으로 전환

- Needs confirmation:
  - 결제 플로우 최종 형태 (alert? 별도 안내 페이지? 토스 연동?)
  - 검색 기능 구현 여부 (현재 비기능)
  - 사운드 재생 구현 여부 (현재 비기능)
  - 뉴스레터 구독 처리 여부

## Success Criteria

- 프로토타입의 11개 화면이 Next.js App Router 라우트로 동작
- 다크/라이트 테마 전환이 모든 화면에서 정상 동작
- 장바구니 추가/수량변경/삭제/프로모 코드/배송 옵션 계산이 정확
- 카탈로그 4기준 필터 + 정렬이 12종 제품에서 정상 동작
- 제품 상세의 변형/스위치 선택 + 탭 전환 동작
- 위시리스트 추가/제거 + localStorage 연동
- 프로토타입의 디자인 토큰(색상/폰트/간격)이 정확히 이식
- 프로토타입 대비 시각적 동등성 확보 (approximate fidelity)
- Vitest + Playwright 테스트 스위트 통과

## Screen Coverage

- Included screens: V-01(Home), V-02(Catalog), V-03(PDP), V-04(Cart), V-05(Profile), V-06(Wishlist), V-07(Keycaps), V-08(Switches), V-09(Accessories), V-10(Magazine), V-11(Cart Drawer)
- Excluded screens: 없음
- Open visual ambiguities: 없음 (프로토타입 코드에서 정확한 값 추출 가능)
