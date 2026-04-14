# 개인 독서 기록 앱 설계

## 개요

읽은 책을 기록하고 독서 통계(월별 권수, 장르별 분포)를 확인하는 개인 트래커.
로그인 없이 로컬에서 혼자 사용하는 단일 사용자 앱.

## 기술 스택

- **Backend**: FastAPI + SQLAlchemy + SQLite, uvicorn (포트 8000)
- **Frontend**: Next.js (App Router), 포트 3333
- **DB**: SQLite 파일 (`reading.db`)
- **CORS**: `http://localhost:3333` 허용

## 프로젝트 위치

```
experiments/reading-tracker/
├── backend/
└── frontend/
```

## 데이터 모델

### Genre (장르)

| 필드       | 타입     | 제약조건          |
|-----------|---------|-----------------|
| id        | int     | PK, auto        |
| name      | str     | unique, not null |
| created_at| datetime| auto             |

시드 데이터: 소설, 에세이, 자기계발, 과학, 역사, 기타

### Book (책)

| 필드        | 타입                              | 제약조건                    |
|------------|----------------------------------|---------------------------|
| id         | int                              | PK, auto                  |
| title      | str                              | not null                   |
| author     | str                              | not null                   |
| genre      | str                              | FK → Genre.name            |
| total_pages| int                              | not null                   |
| status     | enum [reading, completed, abandoned] | not null, default: reading |
| start_date | date                             | not null                   |
| end_date   | date \| null                     |                            |
| rating     | int \| null                      | 1-5, 완독 시만             |
| one_liner  | str \| null                      | 한줄평, 완독 시만           |
| created_at | datetime                         | auto                       |
| updated_at | datetime                         | auto                       |

**규칙**:
- `status`가 `completed`일 때만 `end_date`, `rating`, `one_liner` 입력 가능
- `start_date`는 필수, `end_date`는 완독/중단 시 설정
- `abandoned` 상태도 `end_date` 기록 (중단일)

## API 엔드포인트

| 메서드   | 경로                  | 설명                                      |
|---------|----------------------|------------------------------------------|
| GET     | /genres              | 장르 목록                                  |
| POST    | /books               | 책 등록 (status: reading)                  |
| GET     | /books               | 책 목록 (필터: status, genre, year)         |
| GET     | /books/{id}          | 책 상세                                    |
| PUT     | /books/{id}          | 책 수정                                    |
| PUT     | /books/{id}/status   | 상태 변경                                  |
| DELETE  | /books/{id}          | 책 삭제                                    |
| GET     | /stats/summary       | 통계 (year 필수, month 선택)               |

### 상태 변경 규칙

- `reading` → `completed`: `end_date`, `rating` 필수, `one_liner` 선택
- `reading` → `abandoned`: `end_date` 자동 설정 (오늘)
- 완독/중단 후 다시 `reading`으로 되돌리기 가능 — `end_date`, `rating`, `one_liner` 초기화(null)

### 통계 응답 예시

`GET /stats/summary?year=2026`:

```json
{
  "year": 2026,
  "month": null,
  "total_books": 12,
  "completed": 10,
  "reading": 1,
  "abandoned": 1,
  "by_genre": [
    {"genre": "소설", "count": 5},
    {"genre": "에세이", "count": 3}
  ]
}
```

## 프론트엔드 페이지

### / (메인 - 책 목록)
- 상태별 탭: 읽는 중 / 완독 / 중단 / 전체
- 필터: 장르, 연도
- 책 카드: 제목, 저자, 장르, 상태 배지, 별점
- 책 등록 버튼

### /books/{id} (책 상세)
- 책 정보 전체 표시
- 상태 변경 버튼 (완독 처리, 중단 처리, 다시 읽기)
- 수정 / 삭제
- 완독 시 별점·한줄평 입력 모달

### /stats (통계)
- 연도 선택
- 월별 완독 권수 (숫자 그리드)
- 장르별 분포 (비율 표시)

### UI 방향
- 심플하고 깔끔한 리스트 기반 UI
- 반응형 (모바일 대응)
- 별도 인증 없이 바로 사용

## 프로젝트 구조

```
experiments/reading-tracker/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py          — FastAPI app, CORS, lifespan
│   │   ├── database.py      — SQLAlchemy engine, session
│   │   ├── models.py        — Genre, Book 모델
│   │   ├── schemas.py       — Pydantic request/response
│   │   └── seed.py          — 기본 장르 시드
│   ├── tests/
│   │   ├── conftest.py
│   │   ├── test_books.py
│   │   └── test_stats.py
│   └── requirements.txt
└── frontend/
    ├── src/
    │   ├── app/
    │   │   ├── page.tsx          — 메인 (책 목록)
    │   │   ├── books/[id]/page.tsx — 책 상세
    │   │   ├── stats/page.tsx    — 통계
    │   │   └── layout.tsx
    │   ├── components/
    │   │   ├── BookCard.tsx
    │   │   ├── BookForm.tsx
    │   │   ├── StatusBadge.tsx
    │   │   └── StatsChart.tsx
    │   └── lib/
    │       └── api.ts            — API 호출 래퍼
    ├── package.json
    └── next.config.js
```
