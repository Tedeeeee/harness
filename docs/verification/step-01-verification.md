# 스텝 01 검증

## 메타데이터

- Step: step-01
- Title: 프로젝트 초기화 및 DB 스키마
- Verification Date: 2026-04-14
- Result: pass
- Verification Doc Filename: step-01-verification.md

## 승인 기준 체크리스트

| Item | Expected | Evidence | Result |
| --- | --- | --- | --- |
| 1 | npm run dev로 Next.js가 포트 3333에서 실행된다 | curl http://localhost:3333/ → HTTP 200 | pass |
| 2 | better-sqlite3가 정상 import 된다 | 페이지 로드 시 DB 쿼리 성공, "Reviews count" 표시 | pass |
| 3 | 앱 시작 시 reviews 테이블이 자동 생성된다 | data/movie-log.db 파일 존재, sqlite_master에서 reviews 테이블 확인 | pass |
| 4 | DB 스키마에 필요한 컬럼이 모두 존재한다 | id, title, rating, short_review, detail_review, watched_date, created_at, updated_at 모두 확인 | pass |

## 테스트

- Commands Run: `curl -s -o /dev/null -w "%{http_code}" http://localhost:3333/` → 200
- Result: pass
- Notes: 서버 정상 기동 확인

## 수동 검증

- Check Performed: node -e로 better-sqlite3를 직접 열어 sqlite_master 조회
- Result: pass
- Notes: CREATE TABLE 구문에서 모든 컬럼과 CHECK 제약조건 확인

## 문서 점검

- Updated Files: package.json (port 3333), next.config.ts (serverExternalPackages), lib/db.ts, .gitignore
- Result: pass
- Notes: 해당 없음 (step-01에 문서화 요구 없음)

## 판정

- `pass`

## 후속 조치

- Next allowed action: step-02를 활성화하고 CRUD API 구현을 시작한다
