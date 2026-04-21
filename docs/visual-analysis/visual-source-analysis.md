# Visual Source Analysis

## Summary

- Source File: `프로토타입_ux.pdf`
- Source Type: 기존 `Moyza` 앱 스크린샷에 빨간 박스 + 변경 지시 주석이 붙은 PDF (5페이지)
- Coverage Mode: `mixed` (표지 인벤토리 1p + 화면별 change-directives 4p)
- Last Updated: 2026-04-20

## Global Directives

- 기존 `Moyza` 앱의 UI를 베이스로 하되, 로고/탭 구성/베너/필터 표기 등 일부 요소를 재정의한다.
- 다크 테마, iOS 세로형 모바일 레이아웃을 그대로 유지한다.
- 로고는 `Moyza` 대신 "전달드릴 로고"로 교체한다 (실제 로고 자산은 요구사항 단계에서 사용자에게 요청).
- 베너/Watch Now/Board/Event 탭 등 외부로 연결되는 링크 대상은 현재 PDF에 명시돼 있지 않으므로 요구사항 단계에서 수집한다.
- "개발 기간에 따라 숨김 처리" 문구는 런타임 조건이 아니라 **MVP 범위에서 제외 여부를 개발 일정에 맞춰 결정**한다는 의미로 해석한다.

## Screen Inventory

| Screen | Source Page / Frame | Entry Path / Navigation | Core Visible Elements | Mandatory Changes | Inclusion Status | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Home | p.1 썸네일 1, p.2 전체 | 앱 진입 기본 화면, 하단 탭 `Home` | 상단 로고 + 지구본 아이콘, 키워드 검색바, `New Releases` 가로 스크롤, `Trends` 가로 스크롤, `Join now and get a free Americano!` 광고 베너, 하단 탭(Home/Event/Board/Account) | (1) 로고를 전달드릴 로고로 교체. (2) 섹션 재구성: `업데이트된 신작` → `인기작 픽` → `코리아 픽` 순으로 3개만 배치하고 나머지는 숨김. (3) 하단 광고 베너를 화면 최상단(로고 바로 아래)으로 이동 + 용도를 "설문지 링크용 베너"로 변경. (4) 하단 탭: `Account` 숨김, `Board`는 설문지 아이콘으로 교체 + 설문 링크 삽입, `Event`는 탐색(검색) 아이콘으로 교체 + 탭 선택 시 Search/Filter(2p) 화면으로 연결. (5) `Home` 탭과 지구본 아이콘은 PDF에 변경 지시가 없으므로 현재 동작 유지. | included | `코리아 픽`은 기존에 없던 섹션 — 요구사항 단계에서 큐레이션 기준 확인 필요. |
| Search + Filter Results | p.1 썸네일 2, p.3 전체 | Home 상단 검색바 탭, 또는 하단 `Event`(탐색) 탭 클릭으로 진입 | 뒤로가기 + 키워드 입력바, `Filter` 접힘/펼침 섹션(Country / Genre / Platform 칩), `Results 6` + `Latest first` 정렬 드롭다운, 결과 포스터 그리드 | (1) `Platform` 필터 표기를 칩 아이콘/배경 없이 **플랫폼 명 텍스트만** 사용하도록 단순화. (2) 필터 카테고리(Country, Genre, Platform)와 옵션 목록(USA/Korea/China/Japan, Romance/Horror/Action/Comedy/B/L, A/B/C/D/E) 자체는 PDF에 명시된 그대로 초기 값으로 유지(실제 플랫폼 이름은 요구사항 단계에서 수집). | included | `Event` 탭이 이 화면으로 연결된다는 점이 홈 변경 지시와 쌍으로 확인됨. |
| Title Detail — Top (포스터 + Watch Now) | p.1 썸네일 3, p.4 전체 | Home/Search 결과의 포스터 카드 탭으로 진입 | 뒤로가기, 검색 아이콘, 공유 아이콘, 히어로 포스터, 타이틀(예: `레이디 두아`), 별점(`5.0 (207건 리뷰)`), `Synopsis / Cast / Similar` 탭, Synopsis 카드 (요약 + `19+ 2025 20 EP Drama More`), 플랫폼 배지(NETFLIX / TVING / coupang play), Cast 섹션 시작부, 하단 `♥ Watch Now` 고정 바 | (1) 상단 공유 아이콘 숨김. (2) 플랫폼 배지 블록은 개발 일정에 따라 숨김 처리 가능. (3) `Watch Now` 버튼은 해당 작품의 외부 플랫폼 URL로 연결. (4) 하단 바의 하트(찜) 아이콘 숨김 + `Watch Now` 버튼을 좌우 전체폭으로 정렬. | included | 타이틀 텍스트/별점/메타 수치는 데이터 예시 — 실제 값은 콘텐츠 데이터 소스에서 옴. |
| Title Detail — Mid (베너 + Cast) | p.1 썸네일 4, p.5 전체 | Title Detail 화면 내부 스크롤 상태 | 상단 타이틀 바 `The Art of Sarah` + 검색 + 공유, Synopsis 요약 + 메타 칩, 플랫폼 배지, `Join now and get a free Americano!` 파란 베너, `Cast` 리스트(사라 킴/박무경/정여진/김미정/오츠오 … Lead Cast 역할 라벨 포함) | (1) `Join now…` 베너를 **설문용 베너**로 재사용하고 설문 URL 링크 삽입. (2) Cast 리스트는 **이름만 표시**, `Lead Cast` 등 역할 라벨 제거. | included | 이 화면은 Detail과 동일 페이지의 스크롤 상태. 별도 라우트가 아님. |
| Title Detail — Bottom (Synopsis 확장 + 메타 표 + Similar) | p.1 썸네일 5 | Title Detail 화면 내부 스크롤 상태 | 상단 탭 `Synopsis / Similar`(선택됨: Synopsis), 확장된 Synopsis 본문 2단락, 메타 정보 표(Title / Genre / Release Year / Episodes / Country / Age Rating), 플랫폼 배지, `View Summary` 토글, 설문 베너, Cast | Detail 화면의 같은 요소에 대해 위에서 정의한 지시가 그대로 적용된다(공유 숨김, 플랫폼 배지 조건부 숨김, 설문 베너 링크, Cast 이름만). 확장 Synopsis와 메타 정보 표 자체는 기존 UI 유지. | included | p.1 썸네일 상단 탭이 `Synopsis / Similar`로 보이나 p.4·p.5에서는 `Synopsis / Cast / Similar` 세 탭 구조. 썸네일 크롭으로 `Cast`가 가려진 것으로 간주(하단에 Cast 섹션이 여전히 존재하므로). |

## Exclusions

- Screen: Account 탭 / Account 페이지
  - Reason: 하단 탭에서 `Account` 항목을 숨기라는 명시 지시(p.2)
  - User Approved: PDF 명시
- Screen: Home의 `Trends` 섹션 (또는 `New Releases`와 `Trends` 뒤 추가 섹션)
  - Reason: "업데이트된 신작 / 인기작 픽 / 코리아 픽 순으로 배치, 4. 숨김 처리" 지시(p.2). 이 3개 섹션 외 기존 섹션은 숨김.
  - User Approved: PDF 명시
- Element: Title Detail 상단 공유 아이콘
  - Reason: p.4 "공유 아이콘 숨김 처리"
  - User Approved: PDF 명시
- Element: Title Detail 하단 바 하트(찜) 아이콘
  - Reason: p.4 "하트 이미지 숨김처리"
  - User Approved: PDF 명시
- Element: Title Detail 플랫폼 배지 블록 (NETFLIX / TVING / coupang play)
  - Reason: p.4 "개발 기간에 따라 숨김 처리" — MVP에서는 기본 숨김 가정, 요구사항 단계에서 최종 결정
  - User Approved: 조건부 (요구사항 단계 재확인 필요)

## Ambiguities

- **설문지/설문 베너 링크 대상**: Board 탭, 홈 최상단 베너, Detail 중간 베너 모두 "설문지 링크" 또는 "설문용 베너"로 연결된다고만 명시됨. 동일 설문인지, 각각 다른 설문인지, 외부 URL인지 앱 내부 뷰인지 불명. 요구사항 단계에서 링크 값과 개수를 수집해야 함.
- **Watch Now 플랫폼 링크 매핑**: 작품별 "해당 작품 플랫폼 링크"가 데이터로 주어지는지, 메타에서 추출해야 하는지 불명. 데이터 스키마와 함께 확인 필요.
- **전달드릴 로고 자산**: "전달드릴 로고로 변경"이라는 표현은 사용자가 이후 전달할 예정이라는 뜻으로 해석. 자산 수령 전에는 플레이스홀더를 사용해야 함.
- **Platform 필터 옵션 `A/B/C/D/E`의 실제 이름**: PDF에는 더미로만 제시됨. 상세 화면의 실제 플랫폼 배지는 NETFLIX/TVING/coupang play 3개로 보이므로, 5개 옵션의 최종 목록이 무엇인지 요구사항 단계에서 확정 필요.
- **"코리아 픽" 섹션 정의**: 기존 앱에는 없던 신규 섹션. 어떤 기준으로 큐레이션되는지(Country=Korea 필터와 동일? 편집팀 큐레이션?) 불명.
- **Event 탭 전환의 세부 동작**: "2페이지 상세검색창 연결"이 탭 클릭 즉시 Search/Filter 화면으로 **대체 이동**인지, Home 위에 오버레이인지 명시적이지 않음. 기본은 일반 탭 내비게이션(라우트 변경)으로 가정.
- **Similar 탭의 내용**: 상세 화면 상단 탭 `Similar`의 실제 컨텐츠가 PDF에 렌더링된 페이지가 없음. 탭 자체는 유지하되 목록 형태는 요구사항 단계에서 정의.

## Clarifying Question

- None. 가시 화면 인벤토리와 변경 지시는 충분히 명확하므로 하드스톱 없이 진행. 열린 질문은 위 **Ambiguities**에서 요구사항 단계가 해결하도록 넘긴다.

## Requirements Promotion Notes

- **Screens that must appear in requirements**:
  - 홈 (Home)
  - 검색 + 필터 결과 (Search + Filter Results)
  - 작품 상세 (Title Detail — 단일 페이지, 스크롤 가능한 Synopsis/Cast/Similar 탭 구조)
  - 하단 탭 내비게이션 (Home / Event(탐색) / Board(설문) 3탭, Account 제외)
- **Global directives that must become implementation rules**:
  - 로고는 전달드릴 자산이 도착하기 전까지 플레이스홀더.
  - Home 섹션 순서: `업데이트된 신작` → `인기작 픽` → `코리아 픽` (그 외 섹션 비활성).
  - 홈 최상단에 설문지 링크 베너 고정.
  - 하단 탭은 Home / Event(탐색→검색 페이지) / Board(설문 링크) 3개.
  - Platform 필터는 텍스트 전용 표기.
  - Title Detail: 상단 공유 아이콘·하트 아이콘 숨김, Watch Now 버튼 전체폭·외부 링크, Cast는 이름만, 설문 베너는 링크 삽입, 플랫폼 배지 블록은 MVP 기본 숨김(결정 재확인).
- **Ambiguities that must be resolved before requirements authoring**:
  - 설문지 링크 URL(들) 및 단일/복수 여부
  - Watch Now 링크가 작품 데이터 모델의 어느 필드에서 오는지
  - 전달드릴 로고 자산 수령 타이밍
  - Platform 필터 옵션의 실제 이름 5종
  - "코리아 픽" 큐레이션 기준
  - MVP에서 플랫폼 배지 블록 표시/숨김 최종 결정
