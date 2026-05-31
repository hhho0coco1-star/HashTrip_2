# HashTrip ✈️

> 여행 성향 분석부터 일정 공유까지, 내 취향에 맞는 여행을 계획하는 플랫폼

## 프로젝트 소개

여행 계획을 세울 때 어디를 가야 할지 막막함을 느끼는 경우가 많습니다.  
HashTrip은 **설문 기반 성향 분석**으로 개인 맞춤 여행 스타일을 도출하고, 한국관광공사 공공 API 기반 여행지 데이터를 활용해 체계적인 일정 계획과 공유를 지원합니다.

| 항목 | 내용 |
|------|------|
| 기간 | 2026.02.09 ~ 2026.03.04 |
| 팀 구성 | 5명 |
| 담당 역할 | 핵심 알고리즘 설계 · 풀스택 · 최종 발표 |

---

## 핵심 기능

- **여행 성향 분석** — 설문 기반 태그 가중치 합산으로 개인 맞춤 여행 스타일 도출
- **여행 일정 계획** — 공공 API 여행지 기반 일정 생성·공유 및 루트 북마크
- **여행지 탐색** — 한국관광공사 API 기반 장소 검색·평점·운영시간 제공
- **소셜 로그인** — Google · Kakao · Naver OAuth2 통합 인증

---

## 기술 스택

### Backend
| 기술 | 선택 이유 |
|------|----------|
| Java 11 · Spring Framework 5.3 | 페이지 단위 이동 중심 서비스라 서버 렌더링으로 충분, 개발 속도 우선 |
| Spring Security + OAuth2 | 여행 서비스 특성상 가입 장벽 최소화 — Google·Kakao·Naver 3종 통합 |
| MyBatis | 성향 분석 태그 집계·여행지 매칭 등 복잡한 조인 쿼리를 SQL로 직접 제어 |
| ExecutorService | 한국관광공사 API 대량 수집을 병렬(6~12 스레드)로 처리해 수집 시간 단축 |
| Spring Mail | 회원가입·알림 이메일 발송 |

### Frontend
`JSP` · `Vanilla JS` (서버 렌더링)

### Database / Infra
`Oracle DB` · `Apache Commons DBCP2` · `Maven`

---

## 시스템 구조

```
Client Layer
  └── 브라우저 (JSP 서버 렌더링)
         ↓ HTTP / Form 요청
App Layer
  └── Spring Framework 5.3     포트 8080
        ├── Spring Security (Form 로그인 + OAuth2)
        └── Spring MVC (Controller → Service → DAO → JSP)
         ↓ MyBatis
Data Layer
  └── Oracle DB (DBCP2 커넥션 풀)
External
  └── 한국관광공사 공공 API · OAuth2 (Google·Kakao·Naver) · Spring Mail
```

---

## 담당 역할

HashTrip의 차별점인 **성향 기반 맞춤 추천**의 핵심 알고리즘을 직접 설계했습니다.  
추천 품질이 입력 데이터에 좌우되기 때문에 데이터를 공급하는 **공공 데이터 수집 파이프라인**까지 함께 담당해 `수집 → 분석 → 추천` 흐름을 끝까지 책임졌습니다.

| 영역 | 담당 내용 |
|------|----------|
| 메인 페이지 | 여행지 목록·검색 UI + MainPageController |
| 성향 분석 페이지 | 설문 UI + 가중치 합산 알고리즘 설계 (AnalysisController · AnalysisService) |
| 관리자 페이지 | 공지·FAQ·문의 관리 (AdminController) |
| 공공 데이터 수집 | ExecutorService 병렬 처리 + 배치 INSERT 300건 (PlaceServiceImpl · PlaceTagClassifier) |

---

## 핵심 설계 포인트

### 성향 분석 알고리즘
```
설문 응답 수집
  → 질문별 선택 태그에 가중치 부여
  → Map<String, Integer> 합산 누적
  → 최다 합산 점수 태그 → 최종 여행 스타일 결정
  → User_Tag_Map · Travel_Styles 저장
  → 성향 코드 기반 여행지 매칭 (PLACE_TAG_MAP JOIN)
```

### 도메인 설계 핵심
- 장소에 태그를 문자열로 직접 저장할 수도 있었지만, 한 태그가 여러 장소에 **재사용**되고 자동 분류의 가중치·신뢰도를 함께 남겨야 해 N:M 중간 테이블(`Place_Tag_Map`)로 분리 — `tag_weight` · `tag_confidence` 컬럼으로 AI 자동 분류 이력 관리
- `User_Tag_Map`을 질문별로 분리 저장해 성향 분석의 유연한 가중치 계산 지원
- `Travel_Plans` ↔ `Plan_Details` 분리로 계획 단위(공개/비공개)와 장소별 방문 순서를 독립 관리

---

## 트러블슈팅

### 성향 분석 중복 태그 처리 오류
- **문제**: 동일 태그가 여러 질문에 걸쳐 중복 등장할 때 결과 부정확
- **원인**: `Set`으로 태그를 관리해 중복 선택을 1회로 카운트
- **해결**: `Map<String, Integer>` 가중치 합산 방식으로 전면 수정 — 동일 태그 반복 선택 시 합산 점수 누적
- **결과**: 모든 케이스에서 실제 최다 선택 태그가 최종 성향으로 정확히 결정

### 공공 데이터 순차 수집 지연
- **문제**: 여행지 상세 정보 순차 조회로 로딩 속도 현저히 저하
- **원인**: 단건 API 호출 반복 — 데이터 수에 비례해 응답 시간 누적
- **해결**: `ExecutorService` 6~12 스레드 병렬 처리 + 배치 INSERT 300건 단위
- **결과**: 기존 대비 **70~80% 성능 향상** 확인

---

## 프로젝트 구조

```
hifive/
└── src/
    └── main/
        ├── java/
        │   └── com/app/
        │       ├── controller/   # MainPage · Analysis · Admin · RestApi
        │       ├── service/      # AnalysisService · PlaceServiceImpl
        │       └── dao/          # TravelStylesDAO · PlaceDAO · UserTagMapDAO
        ├── resources/
        │   └── mybatis/mapper/   # SQL mapper XML
        └── webapp/
            └── WEB-INF/
                └── views/        # JSP 페이지
```
