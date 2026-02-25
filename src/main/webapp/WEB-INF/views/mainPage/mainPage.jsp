<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>

	<!-- 추천 여행지 좋아요 기능 보안으로 인한 추가 -->
	<meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/mainPage.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
<meta charset="UTF-8">
<title>#Trip</title>

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
					<c:choose>
						<c:when test="${not empty usersDTO and not empty usersDTO.userNo}">
							<a href="/hashTrip/analysis" class="btn-analysis">여행유형 테스트 시작하기</a>
						</c:when>
						<c:otherwise>
							<a href="javascript:void(0);" onclick="checkLogin()" class="btn-analysis">여행유형 테스트 시작하기</a>
						</c:otherwise>
					</c:choose>
					<p id="changing-text" class="sub-text">* 당신의 마음이 머물고 싶어 하는 그곳으로
						안내해 드릴게요.</p>
				</div>
			</div>

			<div class="analysis-image">	
				<div class="map-background" ></div>

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
						
							<!-- ========= heart 기능 ========= -->
							<div class="card-image" style="background-image: url('${place.placeThumbnailUrl}');">
								<button type="button" class="like-btn" data-place-id="${place.placeNo }">
									<span class="heart-icon">♡</span>
								</button>
							</div>
							<!-- ========= heart 기능 ========= -->
							
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
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />
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

             // ... performSearch 함수 내부 ...
                for (var i = 0; i < data.length; i++) {
                    var place = data[i];
                    
                    var pNo = place.placeNo || place.PLACE_NO || 0;
                    var name = place.placeName || "이름 없음";
                    var address = place.placeAddress || "주소 없음";
                    var thumb = place.placeThumbnailUrl || "";
                    
                    // [추가] 서버에서 넘어온 좋아요 여부 확인 (필드명은 서버 DTO에 맞춰주세요)
                    // 예: place.isLiked가 true이거나 place.savedYn이 'Y'인 경우
                    var isLiked = (place.isLiked === true || place.savedYn === 'Y');
                    var activeClass = isLiked ? " active" : ""; // 클래스 추가 여부
                    var heartIcon = isLiked ? "♥" : "♡";        // 아이콘 모양 결정

                    var cardHtml = 
                        '<div class="travel-card">' +
                            '<div class="card-image" style="background-image: url(\'' + thumb + '\');">' +
                                // 클래스 부분에 activeClass를, 아이콘 부분에 heartIcon을 넣습니다.
                                '<button type="button" class="like-btn' + activeClass + '" data-place-id="' + pNo + '">' +
                                    '<span class="heart-icon">' + heartIcon + '</span>' +
                                '</button>' +
                            '</div>' +
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
    
    // ================= heart 좋아요 기능 =================

	document.addEventListener('click', function(e) {
    const btn = e.target.closest('.like-btn');
    if (btn) {
        e.preventDefault();
        
        // [추가] CSRF 토큰과 헤더 이름을 메타 태그에서 가져옵니다.
        const token = document.querySelector('meta[name="_csrf"]').getAttribute('content');
        const header = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');

        const placeNo = btn.getAttribute('data-place-id');
        const isLike = !btn.classList.contains('active');
        const sendData = { 
        		placeNo: placeNo, 
        		status: isLike ? 'Y' : 'N' 
        				};

        $.ajax({
            type: "POST",
            url: "${pageContext.request.contextPath}/customer/savePlace",
            contentType: "application/json",
            data: JSON.stringify(sendData),
            // [핵심] 헤더에 보안 토큰을 실어서 보냅니다.
            beforeSend: function(xhr) {
                xhr.setRequestHeader(header, token);
            },
            success: (res) => {
                console.log("서버 응답 확인:", res);

                // [수정] res.body의 값이 "SUCCESS"인지 확인
                if (res.body === "SUCCESS") {
                    btn.classList.toggle('active'); 
                    btn.querySelector('.heart-icon').textContent = isLike ? '♥' : '♡';
                    alert(isLike ? "나의 여행지로 저장되었습니다!" : "저장이 취소되었습니다.");
                } 
                // [수정] res.body의 값이 "LOGIN_REQUIRED"인지 확인
                else if (res.body === "LOGIN_REQUIRED") {
                    alert("로그인이 필요한 서비스입니다.");
                    location.href = "${pageContext.request.contextPath}/auth/login";
                } 
                else {
                    alert("알 수 없는 응답이 발생했습니다.");
                }
            },
            error: (err) => {
                if(err.status === 403) {
                    alert("보안 토큰이 만료되었거나 권한이 없습니다. 페이지를 새로고침 해주세요.");
                } else {
                    console.error("에러:", err);
                }
            }
        });
    }
	});
	});
	
	function checkLogin() {
		if(confirm("로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?")) {
		location.href = "${pageContext.request.contextPath}/auth/login";
		}
	}
    	
</script>

</body>
</html>