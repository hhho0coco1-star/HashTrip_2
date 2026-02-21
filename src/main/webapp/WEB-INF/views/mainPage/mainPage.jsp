<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>#Trip</title>

<style type="text/css">
/* 1. 스크롤 스냅 활성화 */
html {
	scroll-snap-type: y proximity; /* 강제 고정 대신 근접했을 때만 고정 */
	scroll-behavior: smooth; /* 부드러운 스크롤 */
}

body {
	margin: 0;
	padding: 0;
}

/* 2. 각 섹션을 화면 전체 크기로 설정 */
section {
	scroll-snap-align: start;
	scroll-snap-stop: always; /* 스크롤 한 번에 여러 섹션을 지나치지 않도록 방지 */
	height: 100vh;
	width: 100%;
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
	/* [추가] 헤더 높이가 보통 60px 정도이므로 그만큼 위쪽 여백을 줍니다 */
	padding-top: 60px;
}

/* 헤더가 고정(sticky)되어 있다면 스냅 위치가 어긋날 수 있으므로 
   헤더 높이만큼 여백을 고려하거나, 헤더를 제외하고 구성하는 것이 좋습니다. */

/* ================== 1. 상단 헤더바 영역 ================== */
.main-header {
	background-color: #ffffff;
	border-bottom: 1px solid #eee;
	padding: 10px 0;
	position: sticky;
	top: 0;
	z-index: 1000;
}

.header-container {
	display: flex;
	justify-content: space-between;
	align-items: center;
	max-width: 1200px;
	margin: 0 auto;
	padding: 0 20px;
}

.header-logo {
	font-size: 24px;
	text-decoration: none;
	flex: 1;
}

.header-menu-wrapper {
	flex: 2;
	display: flex;
	justify-content: center;
}

.nav-menu {
	display: flex;
	list-style: none;
	margin: 0;
	padding: 0;
	gap: 30px;
}

.nav-menu li a {
	text-decoration: none;
	color: #333;
	font-weight: 500;
}

.nav-menu li a:hover {
	color: #007bff;
}

.user-auth {
	flex: 1;
	display: flex;
	justify-content: flex-end;
	align-items: center;
	gap: 15px;
}

.btn-login, .btn-signup, .btn-logout {
	text-decoration: none;
	font-size: 14px;
	padding: 6px 12px;
	border-radius: 4px;
}

.btn-login {
	color: #555;
}

.btn-signup {
	background-color: #007bff;
	color: #fff;
}

.user-info {
	font-size: 14px;
	color: #666;
}

/* ================== 2. 성향 분석 영역 ================== */
.analysis-section {
	background: linear-gradient(135deg, #f0f7ff 0%, #ffffff 100%);
	padding: 80px 0;
	display: flex;
	justify-content: center;
}

.analysis-container {
	max-width: 1200px;
	width: 100%;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 20px;
}

.analysis-content {
	flex: 1;
}

.badge {
	background-color: #e7f1ff;
	color: #007bff;
	padding: 5px 12px;
	border-radius: 20px;
	font-size: 14px;
	font-weight: 600;
	margin-bottom: 20px;
	display: inline-block;
}

.analysis-content h1 {
	font-size: 42px;
	color: #222;
	margin-bottom: 20px;
	line-height: 1.2;
}

.analysis-content p {
	font-size: 18px;
	color: #666;
	line-height: 1.6;
	margin-bottom: 40px;
}

.btn-analysis {
	display: inline-block;
	background-color: #007bff;
	color: white;
	padding: 16px 32px;
	font-size: 18px;
	font-weight: 600;
	text-decoration: none;
	border-radius: 8px;
	transition: transform 0.2s, background-color 0.2s;
	box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
}

.btn-analysis:hover {
	background-color: #0056b3;
	transform: translateY(-3px);
}

.sub-text {
	margin-top: 15px;
	font-size: 13px;
	color: #999;
}

/* ================== 3. 지도 및 플로팅 카드 애니메이션 ================== */
.analysis-image {
	flex: 1;
	display: flex;
	justify-content: center;
	position: relative;
	height: 450px; /* 지도가 보일 수 있도록 높이 확보 */
}

.map-background {
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	width: 100%;
	height: 100%;
	background-image: url('/img/korea.png');
	background-size: contain;
	background-repeat: no-repeat;
	background-position: center;
	opacity: 0.2;
	filter: grayscale(100%) brightness(1.1);
	z-index: 1;
	animation: map-fade 2s ease-in-out forwards;
}

.floating-card {
	position: absolute;
	background: white;
	padding: 12px 22px;
	border-radius: 50px;
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.06);
	font-weight: bold;
	font-size: 15px;
	z-index: 10;
	animation: floating 4s infinite ease-in-out;
}

/* 개별 카드 위치 설정 - 지도 레이아웃에 맞춰 분산 */
.floating-card:nth-of-type(1) {
	top: 10%;
	left: 10%;
	color: #007bff;
	animation-delay: 0s;
}

.floating-card:nth-of-type(2) {
	top: 35%;
	right: 5%;
	color: #ff4757;
	animation-delay: 0.5s;
	font-size: 18px;
}

.floating-card:nth-of-type(3) {
	bottom: 20%;
	left: 15%;
	color: #2ed573;
	animation-delay: 1.2s;
}

.floating-card:nth-of-type(4) {
	top: 25%;
	left: 45%;
	color: #ffa502;
	animation-delay: 0.8s;
}

.floating-card:nth-of-type(5) {
	bottom: 45%;
	left: 5%;
	color: #747d8c;
	animation-delay: 1.5s;
	font-size: 13px;
}

.floating-card:nth-of-type(6) {
	top: 65%;
	right: 20%;
	color: #a4b0be;
	animation-delay: 2s;
}

.floating-card:nth-of-type(7) {
	bottom: 5%;
	right: 30%;
	color: #5352ed;
	animation-delay: 0.3s;
}

/* 애니메이션 키프레임 (하나로 통합) */
@
keyframes floating { 0%, 100% {
	transform: translate(0, 0);
}

50






%
{
transform






:






translate






(






0
,
-15px






)






;
}
}
@
keyframes map-fade {from { opacity:0;
	transform: translate(-50%, -48%);
}

to {
	opacity: 0.2;
	transform: translate(-50%, -50%);
}

}
.sub-text {
	/* 기존에 가지고 계신 스타일 코드들... (font-size, color 등) */
	transition: opacity 0.5s ease-in-out; /* 이 줄만 추가해 주세요! */
	opacity: 1;
}

/* 페이드 아웃 상태를 위한 클래스 */
.fade-out {
	opacity: 0;
}

/* ================== 4. 여행지 추천 영역 ================== */
/* 검색창 스타일 */
.search-bar-wrapper {
	max-width: 500px;
	margin: 0 auto 50px auto; /* 중앙 정렬 및 하단 여백 */
}

.search-input-box {
	position: relative;
	display: flex;
	align-items: center;
	background: #fff;
	border: 2px solid #007bff;
	border-radius: 50px;
	padding: 5px 20px;
	box-shadow: 0 4px 15px rgba(0, 123, 255, 0.1);
	transition: all 0.3s ease;
}

.search-input-box:focus-within {
	box-shadow: 0 4px 20px rgba(0, 123, 255, 0.2);
	transform: translateY(-2px);
}

.search-input-box input {
	border: none;
	outline: none;
	width: 100%;
	padding: 12px 10px;
	font-size: 16px;
}

.search-icon {
	font-style: normal;
	font-size: 18px;
	margin-right: 10px;
}

/* ================== 4. 여행지 추천 영역 (슬라이더 통합) ================== */
.recommend-section {
	padding-top: 30px !important;
	padding-bottom: 80px;
	background-color: #ffffff;
}

.recommend-container {
	max-width: 1200px;
	width: 100%;
	margin: 0 auto;
	padding: 0 20px;
	box-sizing: border-box;
}

/* 슬라이더 외부 감싸기 */
.recommend-wrapper {
	position: relative;
	width: 100%;
	overflow: hidden; /* 영역 밖 카드 숨김 */
	padding: 10px 5px;
}

/* 1. 창문 역할: 넘치는 카드를 가립니다 */
.recommend-wrapper {
    position: relative;
    width: 100%;
    overflow: hidden; /* [필수] 이게 없으면 카드가 옆으로 무한히 보입니다 */
    padding: 20px 0;
}

/* 2. 기차 트랙: 카드들이 한 줄로 서게 합니다 */
.recommend-cards {
    display: flex;
    flex-wrap: nowrap; /* [필수] 카드가 아래로 안 떨어지게 */
    width: max-content; /* [필수] 내용물만큼 옆으로 길어지게 */
    transition: transform 0.5s ease-out;
    gap: 20px;
}

/* 3. 카드 자체: 뒤지게 커지지 않도록 너비를 딱 고정합니다 */
.travel-card {
    /* 1200px 컨테이너에서 3개를 보여주려면 한 카드당 386px 정도가 적당합니다 */
	flex: 0 0 calc(33.333% - 14px);
    width: 386px; 
    background: #fff;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.05);
}

/* 4. 아까 성공한 이미지 높이 유지 */
.card-image {
    height: 220px;
    background-size: cover;
    background-position: center;
}

.card-info {
	padding: 20px;
}

.card-info h3 {
	margin: 0 0 10px 0;
	font-size: 18px;
}

.card-info p {
	color: #777;
	font-size: 14px;
	margin-bottom: 0;
}


/* 슬라이더 컨트롤 버튼 */
.slider-btn {
	position: absolute;
	top: 50%;
	transform: translateY(-50%);
	background: white;
	border: 1px solid #eee;
	width: 44px;
	height: 44px;
	border-radius: 50%;
	cursor: pointer;
	z-index: 10;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
	transition: all 0.3s;
}

.slider-btn:hover {
	background: #007bff;
	color: white;
	border-color: #007bff;
}

.prev-btn {
	left: -10px;
}

.next-btn {
	right: -10px;
}

/* 추천 섹션 전체의 상단 여백 줄이기 */
.recommend-section {
	/* 기존 80px에서 20px~40px 정도로 대폭 줄임 */
	padding-top: 30px !important;
	padding-bottom: 80px;
	background-color: #ffffff;
	scroll-snap-align: start;
	height: 100vh; /* 전체 화면 높이 유지 */
	box-sizing: border-box;
}

.recommend-container {
	max-width: 1200px; /* 부모 넓이를 충분히 넓게 잡아주세요 */
	width: 100%;
	margin: 0 auto;
	padding: 0 20px;
	box-sizing: border-box; /* 패딩이 넓이에 영향을 주지 않도록 설정 */
}

/* 제목 영역의 위쪽 마진 제거 */
.section-title {
	text-align: center;
	margin-top: 0; /* 위쪽 마진을 아예 없앰 */
	margin-bottom: 30px; /* 검색창과의 간격 */
}

.section-title h2 {
	margin-top: 0; /* h2 태그 자체의 기본 마진 제거 */
	font-size: 32px;
	line-height: 1.2;
}

.recommend-cards {
	display: flex;
	transition: transform 0.6s cubic-bezier(0.25, 1, 0.5, 1);
	gap: 20px;
	flex-wrap: nowrap; /* 카드가 아래로 떨어지지 않게 고정 */
	width: max-content; /* [이게 없으면 절대 안 움직여!] */
}

/* 카드 너비 고정 */
.travel-card {
	flex: 0 0 370px; /* 한 화면에 3개 유지 */
	box-sizing: border-box;
}

/* ================== 5. footer ================== */
.main-footer {
	background-color: #ffffff;
	color: #333;
	border-top: 1px solid #eee;
	padding: 25px 0 15px 0;
	scroll-snap-align: end;
}

.footer-container {
	max-width: 1200px;
	margin: 0 auto;
	padding: 0 20px;
}

.footer-top {
	display: flex;
	justify-content: space-between;
	align-items: flex-start; /* 상단 정렬 */
	flex-wrap: wrap;
	margin-bottom: 15px; /* 카피라이트와의 간격 최소화 */
	gap: 20px;
}

.footer-brand {
	flex: 1.5;
	min-width: 200px;
}

.footer-logo {
	font-size: 20px; /* 로고 크기도 조금 더 작게 */
	font-weight: 800;
	color: #007bff;
	margin-bottom: 5px; /* 간격 축소 */
}

.brand-desc {
	font-size: 13px;
	font-weight: 600;
	margin: 0; /* 마진 제거 */
	color: #444;
}

.brand-sub {
	font-size: 12px;
	color: #888;
}

/* 메뉴 영역 간격 압축 */
.footer-links h3 {
	font-size: 13px;
	font-weight: 700;
	margin-bottom: 8px; /* 제목 아래 간격 축소 */
	color: #222;
}

.footer-links ul li {
	margin-bottom: 4px; /* 리스트 사이 간격 최소화 */
}

.footer-links ul li a {
	color: #666;
	font-size: 12px; /* 폰트 크기 살짝 축소 */
}

/* 하단 카피라이트 영역 압축 */
.footer-bottom {
	border-top: 1px solid #f4f4f4;
	padding-top: 10px; /* 위쪽 라인과의 간격 축소 */
	text-align: center;
}

.footer-bottom p {
	font-size: 11px;
	color: #aaa;
	margin: 0;
}
</style>

</head>
<body>

	<!-- header -->
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<!-- header -->

	<!-- 성향 분석 -->
	<section class="analysis-section">
		<div class="analysis-container">
			<div class="analysis-content">
				<span class="badge">Travel Type Test</span>
				<h1>나의 여행 성향이 궁금하다면?</h1>
				<p>
					10가지 카테고리 테스트로 나만의 여행자 유형을 찾고,<br> 비슷한 여행자들의 추천 루트를 발견해보세요.
				</p>
				<div class="analysis-action">
					<a href="/hashTrip/analysis" class="btn-analysis">여행유형 테스트 시작하기</a>
					<p id="changing-text" class="sub-text">* 당신의 마음이 머물고 싶어 하는 그곳으로
						안내해 드릴게요.</p>
				</div>
			</div>

			<div class="analysis-image">
				<div class="map-background"></div>

				<div class="floating-card type-1">#제주도</div>
				<div class="floating-card type-2">#힐링</div>
				<div class="floating-card type-3">#액티비티</div>
				<div class="floating-card type-1">#맛집탐방</div>
				<div class="floating-card type-2">#인생샷</div>
				<div class="floating-card type-3">#차박</div>
				<div class="floating-card type-1">#혼자여행</div>
			</div>
		</div>
	</section>
	<!-- 성향 분석 -->

	<!-- 추천 여행지 -->
	<section class="recommend-section">
		<div class="recommend-container">
			<div class="section-title">
				<h2>지금 인기 있는 #Trip 추천 여행지</h2>
			</div>

			<div class="search-bar-wrapper">
				<div class="search-input-box">
					<i class="search-icon">🔍</i> <input type="text"
						id="destinationSearch" placeholder="어디로 떠나고 싶으신가요?">
				</div>
			</div>

			<div class="recommend-wrapper">
				<button class="slider-btn prev-btn" id="prevBtn">❮</button>
				<button class="slider-btn next-btn" id="nextBtn">❯</button>

				<div class="recommend-cards" id="sliderTrack">
					<c:forEach var="place" items="${places}">
						<div class="travel-card">
							<div class="card-image" style="background-image: url('${place.placeThumbnailUrl}');"></div>
							<div class="card-info">
								<h3>${place.placeName}</h3>
								<p>${place.placeAddress}</p>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</div>
	</section>
	<!-- 추천 여행지 -->

	<!-- footer -->
	<footer class="main-footer">
		<div class="footer-container">
			<div class="footer-top">
				<div class="footer-brand">
					<h2 class="footer-logo">#Trip</h2>
					<p class="brand-desc">취향 기반 여행 유형 분석 플랫폼</p>
					<p class="brand-sub">나만의 완벽한 여행을 찾아드립니다.</p>
				</div>

				<div class="footer-links">
					<h3>법적 고지</h3>
					<ul>
						<li><a href="/hashTrip/privacy">개인정보처리방침</a></li>
						<li><a href="/hashTrip/terms">이용약관</a></li>
						<li><a href="/hashTrip/location">위치기반서비스</a></li>
					</ul>
				</div>

				<div class="footer-links">
					<h3>고객 지원</h3>
					<ul>
						<li><a href="/hashTrip/faq">자주 묻는 질문</a></li>
						<li><a href="/hashTrip/contact">1:1 문의</a></li>
						<li><a href="/hashTrip/notice">공지사항</a></li>
					</ul>
				</div>
			</div>

			<div class="footer-bottom">
				<p>&copy; 2026 #Trip. All rights reserved.</p>
			</div>
		</div>
	</footer>
	<!-- footer -->

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function() {
    const track = document.querySelector('#sliderTrack');
    const searchInput = document.querySelector('#destinationSearch');
    const textElement = document.querySelector('#changing-text');
    
    let slideIndex = 0;
    const moveDistance = 390; // 카드 370px + 간격 20px

    // [1] 슬라이더 이동 및 버튼 상태 업데이트 함수
    function updateSlider() {
        if (!track) return;
        const visibleCards = track.querySelectorAll('.travel-card');
        const maxIndex = Math.max(0, visibleCards.length - 3);

        if (slideIndex > maxIndex) slideIndex = maxIndex;
        if (slideIndex < 0) slideIndex = 0;

        track.style.transform = "translateX(-" + (slideIndex * moveDistance) + "px)";
        
        // 버튼 활성화/비활성화 제어
        const prevBtn = document.querySelector('#prevBtn');
        const nextBtn = document.querySelector('#nextBtn');
        if(prevBtn) prevBtn.style.opacity = (slideIndex === 0) ? "0.3" : "1";
        if(nextBtn) nextBtn.style.opacity = (slideIndex >= maxIndex || visibleCards.length <= 3) ? "0.3" : "1";
    }

    // [2] Ajax 검색 함수 (엔터 칠 때 실행)
  function performSearch() {
        const keyword = searchInput.value.trim();
        $.ajax({
            url: "${pageContext.request.contextPath}/hashTrip/searchApi", 
            type: "GET",
            data: { "keyword": keyword },
            dataType: "json",
            success: function(data) {
                console.log("데이터 확인:", data);
                var track = document.getElementById('sliderTrack');
                track.innerHTML = ""; 

                if (!data || data.length === 0) {
                    alert("검색 결과가 없습니다.");
                    return;
                }

                for (var i = 0; i < data.length; i++) {
                    var place = data[i];
                    
                    // 이름, 주소, 이미지 경로를 안전하게 가져오기
                    var name = place.placeName || place.PLACE_NAME || "이름 없음";
                    var address = place.placeAddress || place.PLACE_ADDRESS || "주소 없음";
                    var thumb = place.placeThumbnailUrl || place.PLACE_THUMBNAIL_URL || "";

                    // [핵심] 백틱(`) 대신 따옴표와 + 기호를 사용해서 JSP와의 충돌을 원천 차단합니다.
                    var cardHtml = 
                        '<div class="travel-card">' +
                            '<div class="card-image" style="background-image: url(\'' + thumb + '\');"></div>' +
                            '<div class="card-info">' +
                                '<h3>' + name + '</h3>' +
                                '<p>' + address + '</p>' +
                            '</div>' +
                        '</div>';
                        
                    track.insertAdjacentHTML('beforeend', cardHtml);
                }

                slideIndex = 0;
                updateSlider();
            },
            error: function(xhr) {
                alert("에러 발생: " + xhr.status);
            }
        });
    }

    // [3] 엔터키 이벤트 리스너
    if (searchInput) {
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                performSearch();
            }
        });
    }

    // [4] 슬라이더 화살표 버튼 클릭 이벤트
    document.querySelector('#nextBtn').addEventListener('click', function() {
        const visibleCards = track.querySelectorAll('.travel-card');
        if (slideIndex < (visibleCards.length - 3)) {
            slideIndex++;
            updateSlider();
        }
    });

    document.querySelector('#prevBtn').addEventListener('click', function() {
        if (slideIndex > 0) {
            slideIndex--;
            updateSlider();
        }
    });

    // [5] 텍스트 로테이션 (니가 준 7개 문구 전체)
    const messages = [
        "* 지금 가장 핫한 MZ 여행 트렌드, 당신의 유형은 무엇인가요?",
        "* 당신도 몰랐던 당신의 숨겨진 여행 DNA를 찾아보세요.",
        "* 지금 이 순간, 당신에게 가장 필요한 여행의 온도는?",
        "* 지금 이 계절, 당신의 마음이 머물고 싶은 온도는?",
        "* 설레는 여행의 시작, 당신의 취향에서부터 출발합니다.",
        "* 2026년 첫 여행, 실패 없는 선택을 위한 가이드라인",
        "* 당신이 길치여도 괜찮아요. 취향이 길을 안내할 테니까요."
    ];
    let msgIdx = 0;
    setInterval(() => {
        if(!textElement) return;
        textElement.classList.add('fade-out');
        setTimeout(() => {
            msgIdx = (msgIdx + 1) % messages.length;
            textElement.textContent = messages[msgIdx];
            textElement.classList.remove('fade-out');
        }, 500);
    }, 4000);

    // 초기 로딩 시 슬라이더 상태 확인
    updateSlider();
});
</script>

</body>
</html>