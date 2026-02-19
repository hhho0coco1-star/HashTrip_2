<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>여행 계획</title>
<link rel="stylesheet"
	href="<c:url value='/resources/plan/static/plan.css'/>">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

</head>
<body>
	<form action="/plan" method="post">
	<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
		<div class="container">
			<!-- 헤더 -->
			<div class="plan-header">
				<input type="text" class="trip-title-input" id="tripTitle" name="planTitle"
					placeholder="여행 제목을 입력하세요"> <span class="status-badge"
					id="statusBadge"  name="planStatus">계획 중</span>
			</div>

			<!-- 여행 기간 섹션 추가 -->
			<div class="trip-period-section">
				<div class="period-row">
					<div class="period-item">
						<label>🛫 여행 시작일</label> <input type="date" id="tripStartDate" name="planStartDate"
							onchange="updateTripPeriod()">
					</div>
					<div class="period-item">
						<label>🛬 여행 종료일</label> <input type="date" id="tripEndDate" name="planEndDate"
							onchange="updateTripPeriod()">
					</div>
					<div class="period-summary" id="periodSummary">
						<!-- 여행 기간 요약 표시 -->
					</div>
				</div>
			</div>

			</header>

			<!-- 장소 추가 버튼 (계획/기록 상태에서) -->
			<div id="addPlaceSection" class="add-place-section">
				<button type="button" id="addPlaceBtn" class="btn btn-primary">
					<i class="fas fa-map-marker-alt"></i> 장소 선택
				</button>
				<span id="addPlaceHint" class="add-place-hint hidden">여행 중 새
					장소 추가</span>
			</div>

			<!-- 타임라인 -->

			<!-- 진행 상황 표시 (기록 중일 때만 표시) -->
			<div id="progressSection" class="progress-section hidden">
				<div class="progress-info">
					<span id="progressText">0 / 0 완료</span> <span id="progressPercent">0%</span>
				</div>
				<div class="progress-bar">
					<div id="progressFill" class="progress-fill" style="width: 0%"></div>
				</div>
			</div>

			<div class="timeline-container">
				<div id="placeList" class="place-list">
					<!-- 장소 카드가 여기에 동적으로 추가됨 -->
				</div>
			</div>

			<!-- 총 리뷰 섹션 (기록 상태에서만) -->
			<div id="reviewSection" class="review-section hidden">
				<h2>총 리뷰</h2>
				<div class="total-rating">
					<span>전체 만족도</span>
					<div id="totalStars" class="star-rating" data-rating="0">
						<i class="far fa-star" data-value="1"></i> <i class="far fa-star"
							data-value="2"></i> <i class="far fa-star" data-value="3"></i> <i
							class="far fa-star" data-value="4"></i> <i class="far fa-star"
							data-value="5"></i>
					</div>
				</div>
				<textarea id="totalReview" class="total-review-input"
					placeholder="여행 후기를 작성하세요"></textarea>
				<div class="representative-photo">
					<label>대표 사진 선택</label>
					<div id="photoSelector" class="photo-selector"></div>
				</div>
			</div>

			<!-- 하단 버튼 -->
			<div class="action-buttons">
				<div class="visibility-toggle">
					<label> <input type="checkbox" id="isPublic" name="planIsPublic" value="Y"> 공개
					</label>
				</div>
				<button type="button" id="startTripBtn" class="btn btn-success">여행 시작!</button>
				<button type="button" id="completeTripBtn" class="btn btn-complete hidden">여행
					완료</button>
				<button id="saveBtn" class="btn btn-save">저장</button>
			</div>
		</div>

		<!-- 지도 모달 -->
		<div id="mapModal" class="modal hidden">
			<div class="modal-content">
				<div class="modal-header">
					<h2>장소 선택</h2>
					<button type="button" id="closeMapModal" class="close-btn">&times;</button>
				</div>
				<div class="modal-body">
					<div class="search-box">
						<input type="text" id="placeSearch" placeholder="장소 검색">
						<button type="button" id="searchBtn">
							<i class="fas fa-search"></i>
						</button>
					</div>
					<div id="map" class="map-container"></div>
					<div id="searchResults" class="search-results"></div>
				</div>
				<div class="modal-footer">
					<button type="button" id="confirmPlace" class="btn btn-primary">선택 완료</button>
				</div>
			</div>
		</div>
	</form>

	<script
		src="//dapi.kakao.com/v2/maps/sdk.js?appkey=c0f942806f26f0fe25ab08a3eacbea9d&libraries=services"></script>
	<script src="<c:url value='/resources/plan/static/plan.js'/>"></script>
</body>
</html>