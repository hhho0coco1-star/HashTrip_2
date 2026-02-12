<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${pageTitle != null ? pageTitle : "유사도 기반 장소 추천"}</title>

  <!-- 프로젝트 리소스 경로에 맞게 수정 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/recommend.css"/>
</head>

<body>
<div class="wrap">

  <!-- ================= HERO ================= -->
  <section class="card hero">
    <c:if test="${not empty hero.badge}">
      <div class="badge">${hero.badge}</div>
    </c:if>

    <h1 class="hero__title">
      <span class="hero__name">${hero.userDisplayName}</span>님과<br/>
      유사도 <span class="accent">${hero.similarityPercent}%</span>
      <span class="hero__suffix">${hero.suffix}</span>
    </h1>

    <c:if test="${not empty hero.subtext}">
      <p class="hero__subtext">${hero.subtext}</p>
    </c:if>

    <div class="hero-meta">
      <c:forEach var="chip" items="${hero.metaChips}">
        <div class="chip">
          <c:choose>
            <c:when test="${chip.type eq 'live'}">
              <span class="chip__icon">📍</span>
              <span class="chip__text">${chip.text}</span>
              <span class="chip__badge">LIVE</span>
            </c:when>
            <c:otherwise>
              <span class="chip__dot"></span>
              <span class="chip__text">${chip.text}</span>
            </c:otherwise>
          </c:choose>
        </div>
      </c:forEach>
    </div>
  </section>

  <!-- ================= MAP SECTION ================= -->
  <section class="card section">
    <h2 class="section__title">${mapSectionTitle != null ? mapSectionTitle : "한국 지도 · 지역별 인기 장소"}</h2>

    <div class="map-box">
      <!-- 실제 지도 SDK 붙이기 전까지는 빈 상태 -->
      <c:choose>
        <c:when test="${empty mapPins}">
          <div class="map-empty">
            <div class="map-empty__icon">🗺️</div>
            <div class="map-empty__text">지도 데이터가 없습니다</div>
            <div class="map-empty__hint">지역을 선택하면 추천 장소가 갱신됩니다.</div>
          </div>
        </c:when>
        <c:otherwise>
          <!-- 나중에 지도 SDK 붙일 때:
               - 이 div에 data-*로 핀 정보를 주거나
               - hidden json을 내려서 JS에서 렌더 -->
          <div id="map" class="map-real"
               data-selected-region="${selectedRegionId}"
               aria-label="map canvas">
            <div class="map-real__hint">지도 SDK 연결 영역</div>
          </div>

          <!-- 핀 데이터는 DOM에 남겨두고 JS가 읽게 할 수도 있음 -->
          <div class="sr-only" aria-hidden="true">
            <c:forEach var="pin" items="${mapPins}">
              <span
                data-pin-id="${pin.id}"
                data-place-id="${pin.placeId}"
                data-lat="${pin.lat}"
                data-lng="${pin.lng}"
                data-label="${pin.label}"
                data-region="${pin.regionId}">
              </span>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- 지역 탭: 클릭 시 서버로 regionId를 보내는 구조 가정 -->
    <div class="region-tabs" aria-label="region tabs">
      <c:forEach var="r" items="${regions}">
        <a
          class="tab ${r.id eq selectedRegionId ? 'active' : ''}"
          href="${pageContext.request.contextPath}/recommend?regionId=${r.id}">
          ${r.label}
        </a>
      </c:forEach>
    </div>
  </section>

  <!-- ================= FILTERS ================= -->
  <section class="card filterbar" aria-label="filters">
    <div class="filterbar__row">
      <c:forEach var="cat" items="${categories}">
        <a
          class="filter-chip ${cat.id eq selectedCategoryId ? 'active' : ''}"
          href="${pageContext.request.contextPath}/recommend?regionId=${selectedRegionId}&categoryId=${cat.id}">
          ${cat.label}
        </a>
      </c:forEach>
    </div>

    <!-- (선택) 정렬 드롭다운: 서버 사이드 정렬로 가정 -->
    <form class="filterbar__sort" method="get" action="${pageContext.request.contextPath}/recommend">
      <input type="hidden" name="regionId" value="${selectedRegionId}"/>
      <input type="hidden" name="categoryId" value="${selectedCategoryId}"/>
      <label class="sort__label" for="sort">정렬</label>
      <select class="sort__select" id="sort" name="sort">
        <c:forEach var="opt" items="${sortOptions}">
          <option value="${opt.id}" ${opt.id eq selectedSortId ? "selected" : ""}>${opt.label}</option>
        </c:forEach>
      </select>
      <button class="sort__btn" type="submit">적용</button>
    </form>
  </section>

  <!-- ================= RESULT GRID ================= -->
  <section class="grid" aria-label="place grid">

    <c:choose>
      <c:when test="${empty places}">
        <div class="empty card">
          <div class="empty__icon">🧭</div>
          <div class="empty__title">추천 결과가 없습니다</div>
          <div class="empty__desc">지역/필터를 변경해 다시 확인해보세요.</div>
        </div>
      </c:when>

      <c:otherwise>
        <c:forEach var="p" items="${places}">
          <article class="place">
            <div class="place-top" style="background:${not empty p.thumbnailBgColor ? p.thumbnailBgColor : '#5A8BED'}">
              <button class="heart ${p.liked ? 'on' : ''}" type="button" aria-label="like button">
                <c:choose>
                  <c:when test="${p.liked}">❤</c:when>
                  <c:otherwise>♡</c:otherwise>
                </c:choose>
              </button>

              <div class="match">${p.matchPercent}% Match</div>

              <div class="thumb" aria-hidden="true">
                <c:choose>
                  <c:when test="${not empty p.thumbnailEmoji}">
                    ${p.thumbnailEmoji}
                  </c:when>
                  <c:otherwise>📍</c:otherwise>
                </c:choose>
              </div>
            </div>

            <div class="place-body">
              <c:if test="${not empty p.badgeLabel}">
                <div class="tag">#${p.badgeLabel}</div>
              </c:if>

              <!-- 상세페이지 링크: /place/{id} 형태 가정 -->
              <h3 class="place-title">
                <a class="place-link"
                   href="${pageContext.request.contextPath}/place/${p.id}">
                  ${p.title}
                </a>
              </h3>

              <div class="meta">
                <span>📍 ${p.regionLabel}</span>
                <span class="sep">•</span>
                <span>${p.personaLabel}<c:if test="${not empty p.mbti}"> / ${p.mbti}</c:if></span>
              </div>

              <p class="desc">
                <c:out value="${p.summary}"/>
              </p>

              <div class="rating">
                <span><span class="star">★</span> ${p.ratingScore}</span>
                <span>(${p.reviewCount})</span>
              </div>
            </div>
          </article>
        </c:forEach>
      </c:otherwise>
    </c:choose>

  </section>

</div>

<!--
  ※ JS는 최소화
  - 실제 좋아요 토글/지도핀 클릭/무한스크롤은 추후
  - 지금은 서버사이드 렌더링 + 링크 이동이 유지보수에 유리
-->
</body>
</html>
