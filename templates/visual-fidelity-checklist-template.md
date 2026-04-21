# Visual Fidelity Checklist

이 체크리스트는 `verify-current-step`이 visual pass를 판단할 때 사용하는 표준 카테고리를 정의한다. 각 카테고리는 step의 `screen_ids`에 포함된 각 screen마다 독립적으로 평가된다.

## 카테고리

| Category | 의미 | 기본 판정 기준 |
| --- | --- | --- |
| coverage | visual-source-analysis의 해당 screen이 실제로 구현되었는가 | included screen이 화면에 존재하고 entry path가 작동 |
| spacing | padding/margin/간격이 원본과 유사한가 | 시각적으로 눈에 띄는 차이가 없음 |
| hierarchy | 제목/본문/서브텍스트의 계층이 원본과 일치하는가 | 크기/굵기 계층이 뒤집히지 않음 |
| tab bar | 탭바/네비게이션바의 위치, 항목, 활성 상태가 일치 | 항목 수, 순서, 아이콘이 원본과 일치 |
| banner | 상단 배너/알림/고지 영역 위치와 내용 일치 | 존재 여부와 위치가 일치 |
| typography | 폰트 family/weight/size가 지시된 대로 적용 | mandatory directives의 폰트 지시를 위반하지 않음 |

## 사용 방법

1. step 문서의 `screen_ids`에서 대상 screen을 읽는다
2. 각 screen에 대해 6개 카테고리를 평가한다
3. 평가 결과는 `docs/verification/step-xx-verification.md`의 `시각 검증` 섹션 표에 기록한다
4. `visual_scope` 값에 따라 엄격도를 조정한다:
   - `strict`: 모든 카테고리에서 시각 차이가 눈에 띄면 fail
   - `approximate`: coverage/hierarchy/tab bar/banner가 맞으면 pass (spacing/typography는 큰 차이만 fail)
   - `loose`: coverage만 맞으면 pass
   - `not-applicable`: 이 체크리스트는 적용하지 않음

## 판정 규칙

- 모든 대상 screen × 모든 카테고리 중 하나라도 fail이면 step의 visual 검증은 fail
- `visual_scope: not-applicable`인 step은 이 체크리스트를 건너뛴다
- 한 screen의 일부 카테고리가 `not-applicable`이면 해당 칸에 사유를 적는다
