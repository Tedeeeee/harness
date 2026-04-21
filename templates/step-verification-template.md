# 스텝 검증

## 메타데이터

- Step:
- Title:
- Verification Date:
- Result: pass | fail | blocked
- Verification Doc Filename:

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 |  |  |  |

## 테스트

- Commands Run:
- Result:
- Notes:

## 수동 검증

- Check Performed:
- Result:
- Notes:

## 시각 검증

- 적용 여부: yes | no | not-applicable
- 대상 Screen IDs:
- visual_scope: strict | approximate | loose | not-applicable

### 카테고리별 결과

| Category | Expected | Observed | Result |
| --- | --- | --- | --- |
| coverage |  |  |  |
| spacing |  |  |  |
| hierarchy |  |  |  |
| tab bar |  |  |  |
| banner |  |  |  |
| typography |  |  |  |

### 증거

- 스크린샷 경로 또는 수동 관찰 노트:

Rule:

- 프로젝트에 `docs/visual-analysis/visual-source-analysis.md`가 존재하면 "적용 여부"는 `yes` 또는 `not-applicable`만 가능하다 (`no`는 금지)
- "대상 Screen IDs"는 해당 step 문서의 `screen_ids`와 정확히 일치해야 한다
- 카테고리 중 하나라도 `fail`이면 visual 검증 결과는 fail이다

## 문서 점검

- Updated Files:
- Result:
- Notes:

## 판정

- `pass` | `fail` | `blocked`

## 건너뛴 점검 (선택)

- User-approved skip:
- Reason:

## 후속 조치

- Next allowed action:
