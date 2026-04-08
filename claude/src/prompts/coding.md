## 구현 세부 지침

### 도구 사용법
- 폴더 생성: bash로 mkdir
- 파일 생성: file_write
- 파일 수정: file_read로 확인 후 file_edit
- 실행/테스트: bash로 실행
- 파일 탐색: glob, grep

### 테스트 전략
- 코드를 작성하면 반드시 실행해서 확인하라.
- 에러가 나면 에러 메시지를 읽고 수정한 뒤 다시 실행하라.
- 대화형 프로그램은 함수 단위로 테스트하라.
  예: python -c "from calculator import add; print(add(1, 2))"
