<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>여행지 상세</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/place/detail-demo.css">
</head>
<body>
	<div class="page-shell">
		<header class="appbar">
			<button class="ghost-btn" type="button" onclick="history.back()">뒤로</button>
			<h1>여행지 상세</h1>
			<button class="ghost-btn" type="button">공유</button>
		</header>

		<c:choose>
			<c:when test="${empty place}">
				<main class="layout">
					<section class="panel not-found-panel">
						<h4>장소를 찾을 수 없습니다</h4>
						<p>place_no: ${placeNo} 데이터가 없습니다.</p>
					</section>
				</main>
			</c:when>
			<c:otherwise>
				<c:set var="heroImageUrl" value="${place.placeThumbnailUrl}" />
				<c:if test="${empty heroImageUrl and not empty photoUrlList}">
					<c:set var="heroImageUrl" value="${photoUrlList[0]}" />
				</c:if>
				<c:set var="photoHeroClass" value="photo-hero" />
				<c:if test="${empty heroImageUrl}">
					<c:set var="photoHeroClass" value="photo-hero photo-hero-fallback" />
				</c:if>

				<main class="layout">
					<section class="photo-section">
						<div class="${photoHeroClass}"
							 <c:if test="${not empty heroImageUrl}">
								style="background-image:
									radial-gradient(circle at 10% 18%, rgba(255, 255, 255, 0.25), transparent 40%),
									radial-gradient(circle at 88% 84%, rgba(255, 255, 255, 0.2), transparent 30%),
									linear-gradient(145deg, rgba(23, 47, 79, 0.5), rgba(36, 95, 167, 0.35)),
									url('${heroImageUrl}');"
							</c:if>>
							<div class="hero-label">대표 사진</div>
							<h2><c:out value="${place.placeName}" /></h2>
						</div>

						<div class="thumb-row">
							<c:choose>
								<c:when test="${not empty photoUrlList}">
									<c:forEach var="photoUrl" items="${photoUrlList}" varStatus="status">
										<c:if test="${status.count <= 8}">
											<div class="thumb-card thumb-card-image">
												<img src="${photoUrl}" alt="여행지 사진 ${status.count}">
											</div>
										</c:if>
									</c:forEach>
								</c:when>
								<c:when test="${not empty place.placeThumbnailUrl}">
									<div class="thumb-card thumb-card-image">
										<img src="${place.placeThumbnailUrl}" alt="대표 썸네일">
									</div>
								</c:when>
								<c:otherwise>
									<div class="thumb-card">사진 없음</div>
								</c:otherwise>
							</c:choose>
						</div>
					</section>

					<section class="place-head">
						<div>
							<p class="place-kind"><c:out value="${place.placeCategory}" /></p>
							<h3><c:out value="${place.placeName}" /></h3>
							<p class="place-meta"><c:out value="${place.placeAddress}" /></p>
						</div>
						<div class="place-score">
							<p class="score-title">평점</p>
							<p class="score-value">
								<c:choose>
									<c:when test="${not empty place.placeRating}">
										<fmt:formatNumber value="${place.placeRating}" pattern="0.0" />
									</c:when>
									<c:otherwise>-</c:otherwise>
								</c:choose>
							</p>
						</div>
					</section>

					<nav class="place-nav">
						<a href="#section-overview">기본정보</a>
						<a href="#section-map">지도</a>
						<a href="#section-review">리뷰</a>
					</nav>

					<section class="panel" id="section-overview">
						<div class="panel-head">
							<h4>기본 정보</h4>
							<span class="panel-head-sub">place_no: ${place.placeNo}</span>
						</div>
						<div class="detail-grid">
							<div class="detail-item">
								<p class="detail-label">카테고리</p>
								<p class="detail-value"><c:out value="${place.placeCategory}" /></p>
							</div>
							<div class="detail-item">
								<p class="detail-label">전화번호</p>
								<p class="detail-value">
									<c:choose>
										<c:when test="${not empty place.placeNumber}">
											<c:out value="${place.placeNumber}" />
										</c:when>
										<c:otherwise>-</c:otherwise>
									</c:choose>
								</p>
							</div>
							<div class="detail-item">
								<p class="detail-label">주소</p>
								<p class="detail-value">
									<c:choose>
										<c:when test="${not empty place.placeAddress}">
											<c:out value="${place.placeAddress}" />
										</c:when>
										<c:otherwise>-</c:otherwise>
									</c:choose>
								</p>
							</div>
							<div class="detail-item">
								<p class="detail-label">좌표</p>
								<p class="detail-value">
									<c:choose>
										<c:when test="${not empty place.placeLatitude and not empty place.placeLongitude}">
											${place.placeLatitude}, ${place.placeLongitude}
										</c:when>
										<c:otherwise>-</c:otherwise>
									</c:choose>
								</p>
							</div>
						</div>

						<div class="tag-row">
							<c:choose>
								<c:when test="${not empty tagNameList}">
									<c:forEach var="tagName" items="${tagNameList}">
										<span class="tag-chip"><c:out value="${tagName}" /></span>
									</c:forEach>
								</c:when>
								<c:otherwise>
									<p class="place-meta">매핑된 태그가 없습니다.</p>
								</c:otherwise>
							</c:choose>
						</div>
					</section>

					<section class="panel map-panel" id="section-map">
						<div class="panel-head">
							<h4>지도 위치</h4>
							<c:choose>
								<c:when test="${not empty place.placeLatitude and not empty place.placeLongitude}">
									<button class="text-btn" type="button" id="kakao-navi-btn">길찾기</button>
								</c:when>
								<c:otherwise>
									<button class="text-btn" type="button" disabled>길찾기</button>
								</c:otherwise>
							</c:choose>
						</div>
						<div id="kakao-map" class="map-canvas"
							 data-lat="${place.placeLatitude}"
							 data-lng="${place.placeLongitude}"
							 data-name="${fn:escapeXml(place.placeName)}">
						</div>
						<p class="map-status" id="map-status">
							<c:choose>
								<c:when test="${not empty place.placeAddress}">
									<c:out value="${place.placeAddress}" />
								</c:when>
								<c:otherwise>주소 정보가 없습니다.</c:otherwise>
							</c:choose>
						</p>
					</section>

					<section class="panel" id="section-review">
						<div class="panel-head">
							<h4>리뷰</h4>
							<span class="panel-head-sub">place_no: ${placeNo} | ${fn:length(reviewList)}개</span>
						</div>

						<c:choose>
							<c:when test="${not empty reviewList}">
								<div class="review-list">
									<c:forEach var="review" items="${reviewList}">
										<article class="review-card">
											<div class="review-top">
												<p class="review-author"><c:out value="${review.createdBy}" /></p>
												<p class="review-date">
													<c:choose>
														<c:when test="${not empty review.createdAt}">
															<fmt:formatDate value="${review.createdAt}" pattern="yyyy-MM-dd HH:mm" />
														</c:when>
														<c:otherwise>-</c:otherwise>
													</c:choose>
												</p>
											</div>
											<p class="review-content">
												<c:choose>
													<c:when test="${not empty review.commentContent}">
														<c:out value="${review.commentContent}" />
													</c:when>
													<c:otherwise>(내용 없음)</c:otherwise>
												</c:choose>
											</p>
											<div class="review-meta">
												<span>comment_no: ${review.commentNo}</span>
												<span>log_no: ${review.logNo}</span>
												<span>place_no: ${review.placeNo}</span>
											</div>
										</article>
									</c:forEach>
								</div>
							</c:when>
							<c:otherwise>
								<p class="place-meta">등록된 리뷰가 없습니다.</p>
							</c:otherwise>
						</c:choose>
					</section>
				</main>
			</c:otherwise>
		</c:choose>
	</div>

	<script>
		(function() {
			const mapElement = document.getElementById("kakao-map");
			const mapStatusElement = document.getElementById("map-status");
			const naviButton = document.getElementById("kakao-navi-btn");

			if (!mapElement) {
				return;
			}

			const appKey = "${kakaoMapAppKey}";
			const lat = Number(mapElement.dataset.lat);
			const lng = Number(mapElement.dataset.lng);
			const placeName = mapElement.dataset.name || "destination";

			if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
				if (mapStatusElement) {
					mapStatusElement.textContent = "좌표 정보가 없어 지도를 표시할 수 없습니다.";
				}
				return;
			}

			if (naviButton) {
				naviButton.addEventListener("click", function() {
					const encodedName = encodeURIComponent(placeName);
					const url = "https://map.kakao.com/link/to/" + encodedName + "," + lat + "," + lng;
					window.open(url, "_blank");
				});
			}

			if (!appKey) {
				if (mapStatusElement) {
					mapStatusElement.textContent = "KAKAO_MAP_APP_KEY 설정 후 카카오맵을 사용할 수 있습니다.";
				}
				return;
			}

			const script = document.createElement("script");
			script.src = "https://dapi.kakao.com/v2/maps/sdk.js?autoload=false&appkey=" + encodeURIComponent(appKey);
			script.async = true;
			script.onload = function() {
				if (!window.kakao || !window.kakao.maps) {
					if (mapStatusElement) {
						mapStatusElement.textContent = "카카오맵 로딩에 실패했습니다.";
					}
					return;
				}

				window.kakao.maps.load(function() {
					const position = new window.kakao.maps.LatLng(lat, lng);
					const map = new window.kakao.maps.Map(mapElement, {
						center: position,
						level: 3
					});

					const marker = new window.kakao.maps.Marker({
						position: position
					});
					marker.setMap(map);
				});
			};
			script.onerror = function() {
				if (mapStatusElement) {
					mapStatusElement.textContent = "카카오맵 스크립트를 불러오지 못했습니다.";
				}
			};
			document.head.appendChild(script);
		})();
	</script>
</body>
</html>
