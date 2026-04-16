# Movie Log

개인 영화 감상 기록 앱입니다. 본 영화의 감상을 기록하고, 찾아보고, 필터링하고, 정렬할 수 있습니다.

## 요구 사항

- Node.js 18+
- npm

## 설치

```bash
npm install
```

## 실행

```bash
npm run dev
```

[http://localhost:3333](http://localhost:3333)을 엽니다.

## 기능

- 제목, 별점(1~5), 한줄평, 상세 리뷰, 감상 날짜를 포함한 영화 감상 기록 생성
- 전체 감상 기록 목록 조회
- 별점 범위와 감상 날짜 범위로 필터링
- 날짜, 별점, 제목 기준 오름차순/내림차순 정렬
- 기존 감상 기록 수정 및 삭제
- 모바일 브라우저 대응 반응형 레이아웃

## 기술 스택

- Next.js (App Router)
- SQLite via better-sqlite3
- Tailwind CSS
- TypeScript

## 테스트

```bash
npm test
```

Vitest로 API와 데이터 계층 unit test를 실행합니다.
