# Prototype Input Upgrade Design

> Date: 2026-04-22
> Status: approved in-session

## Goal

Claude Design 같은 프로토타입 코드 산출물을 하네스의 입력으로 안전하게 받아, `요구사항 초안`으로 승격할 수 있게 한다. 기존 docs-first, step-gated, evidence-based 구조는 유지하고, 입력 분석 단계와 handoff 계약만 강화한다.

## Problem

현재 하네스의 입력 분석은 PDF, 이미지, 와이어프레임 등 시각 자산 중심으로 설계되어 있다. 하지만 최근 입력은 `index.html + styles.css + JSX 컴포넌트 묶음`처럼 화면, 상태, 데이터 구조, 인터랙션을 모두 담은 프로토타입 코드 형태로도 들어온다.

이런 입력을 단순 visual source로만 취급하면:

- 화면 수는 읽을 수 있어도 상태/행동 계약을 충분히 승격하지 못한다
- 데모 구현(`alert()`, 하드코딩 데이터, 임시 쿠폰 코드)과 제품 의도를 구분하지 못한다
- requirements 단계에서 정보를 다시 자연어로 재해석하며 손실할 수 있다

## Design Principles

1. 기존 파이프라인은 유지한다
   `analyze-visual-source -> author-product-requirements -> select-technical-approach -> ...`

2. 프로토타입 코드는 `요구사항 초안`으로 취급한다
   최우선 source of truth로 곧장 승격하지 않는다.

3. 분석 단계는 관찰만 하고, 채택/폐기 결정은 하지 않는다
   implementation delta는 `select-technical-approach`가 맡는다.

4. 모든 추출 항목은 confidence와 source reference를 가진다
   하네스는 AI 산출물을 맹신하지 않고, 나중에 왜 그렇게 읽었는지 추적 가능해야 한다.

## Proposed Changes

## 1. `analyze-visual-source` 확장

이 스킬은 더 이상 PDF/이미지만 다루지 않는다. HTML/JSX/CSS 기반 프로토타입 코드 입력도 처리한다.

새로운 분석 항목:

- screen map
- route / navigation map
- interaction map
- data / entity hints
- design token hints
- prototype-only implementation notes

각 항목에는 아래 confidence 태그 중 하나를 붙인다.

- `explicit`: 코드/자산에 명시된 사실
- `inferred`: 강하게 추론되는 의도
- `demo-suspect`: 데모 편의 로직 또는 임시 구현으로 보이는 항목
- `needs-confirm`: 제품 요구인지 확정할 수 없는 항목

또한 가능하면 각 항목에 `source_refs`를 남긴다.
예: `components/App.jsx`, `components/CartPage.jsx`, `index.html`

## 2. `visual-source-analysis.md` 템플릿 강화

기존 screen inventory는 유지한다. 대신 아래 섹션을 추가한다.

- Input Interpretation
- Interaction Inventory
- Data / Entity Signals
- Design Token Signals
- Prototype-only Implementation Notes
- Requirements Promotion Rules

## 3. `author-product-requirements` 규칙 강화

requirements authoring은 분석 문서의 confidence 태그를 해석해서 요구사항으로 승격한다.

- `explicit`, `inferred`: scope / success criteria / constraints로 승격 가능
- `demo-suspect`: 기본적으로 최종 요구사항으로 승격하지 않음
- `needs-confirm`: 사용자 확인 질문 후보로 유지

요구사항 문서에는 “프로토타입 입력에서 승격된 계약”과 “최종 계약이 아닌 데모 구현”의 차이가 보이도록 Notes를 남긴다.

## 4. `select-technical-approach` 규칙 강화

이 단계에서만 아래를 결정한다.

- 프로토타입 구조에서 무엇을 유지할지
- 어떤 런타임/프레임워크로 재구성할지
- 하드코딩 데이터를 유지/치환할지
- 임시 구현(`alert`, Babel standalone, local state routing)을 최종 아키텍처에 그대로 가져갈지

즉, 분석 단계는 관찰만 하고, 기술접근 단계가 implementation delta를 고른다.

## 5. 루트 가이드 문서 업데이트

`README.md`, `CLAUDE.md`, `route-self-harness`에 다음 규칙을 드러낸다.

- 하네스는 시각 자료뿐 아니라 프로토타입 코드 입력도 먼저 분석한다
- 프로토타입 코드는 요구사항 초안 입력이다
- requirements 이전에 제품 의도와 데모 구현을 분리해야 한다

## Scope

이번 변경의 범위:

- skill 문서
- 템플릿
- 루트/운영 가이드

이번 변경의 범위 밖:

- 실제 runtime parser 구현
- 자동 AST 분석기 추가
- hook 로직 변경
- planning/verification 스킬 전면 개편

## Success Criteria

- 하네스가 HTML/JSX/CSS 프로토타입 입력을 공식적으로 받아들일 수 있다
- 분석 문서에서 제품 의도와 데모 구현이 구분된다
- requirements 단계가 `demo-suspect`를 그대로 최종 계약으로 굳히지 않는다
- technical-approach 단계가 “무엇을 살리고 무엇을 버릴지” 결정할 명시적 근거를 갖는다
