# 로드맵

## 진행 중

- [ ] `project-retrospective` 실행
  - 현재 상태: `docs/plans/planning-state.md`의 Current Owner가 Planner / `project-retrospective`를 가리킨다.

## 다음 할 일

- [ ] 실제 로고 자산과 설문 URL을 placeholder 대신 운영 값으로 치환
- [ ] 플랫폼 필터 `A/B/C/D/E`를 실제 플랫폼 이름 체계로 확정
- [ ] 플랫폼 배지 블록을 계속 숨길지, 실제 제품 범위에 맞춰 노출할지 재결정
- [ ] `experiments/` 하위에 다음 프로젝트 산출물을 추가할 때 transition 규칙 문서화 보강
- [ ] 프로토타입 코드 입력에서 confidence/source-ref를 자동 추출하는 보조 파서 도입 검토

## 기술 부채

- [ ] 훅/문서 상태 파서에 대한 테스트 범위를 `session_start.py`, `user_prompt_submit.py`, `stop_guard.py`까지 넓히기
- [ ] trace 파일이 자동으로 dirty worktree를 만들 수 있으므로 ignore 또는 보관 정책 재검토
- [ ] `research/` 문서를 기준으로 새 contributors 온보딩 절차를 한 번 더 다듬기
- [ ] 향후 실험 앱이 늘어나면 `experiments/` 공통 규칙 문서를 별도 분리
- [ ] prototype-code 입력을 다룬 `visual-source-analysis` 예시 문서를 한 개 추가해 새 세션의 품질 기준으로 사용

## 완료

- [x] Moyza Discovery App planning 완료
- [x] step-01 ~ step-07 구현 및 검증 완료
- [x] 앱 느낌(app-feel) 시각 보강 완료
- [x] docs-first 하네스 구조와 Claude hook wiring 정착
