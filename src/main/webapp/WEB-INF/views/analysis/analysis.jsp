<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>#Trip</title>
	<meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
<style>
/* 1. 기본 스타일 */
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

body {
	font-family: 'Pretendard', -apple-system, sans-serif;
	background-color: #f8f9fa;
	color: #333;
}

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

/* 2. 테스트 영역 */
.test-wrapper {
	max-width: 600px;
	margin: 50px auto;
	padding: 20px;
	background: #fff;
	border-radius: 20px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

/* 퍼센트 텍스트 추가를 위한 컨테이너 */
.progress-info {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10px;
	font-size: 14px;
	font-weight: 600;
	color: #888;
}

#percentNum {
	color: #007bff;
}

.progress-track {
	width: 100%;
	height: 8px;
	background: #eee;
	border-radius: 10px;
	margin-bottom: 30px;
	overflow: hidden;
}

.progress-bar {
	width: 0%;
	height: 100%;
	background: #007bff;
	transition: 0.4s;
}

.question-header {
	text-align: center;
	margin-bottom: 30px;
}

#qNumber {
	color: #007bff;
	font-weight: bold;
	font-size: 18px;
	display: block;
	margin-bottom: 10px;
}

#qTitle {
	font-size: 22px;
	word-break: keep-all;
	line-height: 1.4;
}

.q-guide {
	font-size: 13px;
	color: #bbb;
	margin-top: 8px;
}

/* 3. 카드 그리드 */
.answer-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 15px;
}

.answer-card {
	background: #fff;
	border: 2px solid #eee;
	border-radius: 15px;
	padding: 25px 10px;
	text-align: center;
	cursor: pointer;
	transition: 0.2s;
	display: flex;
	flex-direction: column;
	align-items: center;
}

.answer-card:hover {
	border-color: #007bff;
	background: #fcfdfe;
}

/* 선택되었을 때 스타일 */
.answer-card.selected {
	border-color: #007bff;
	background: #e7f3ff;
	outline: 1px solid #007bff;
}

.answer-card .icon {
	font-size: 40px;
	margin-bottom: 10px;
}

.answer-card .label {
	font-size: 16px;
	font-weight: 600;
	color: #444;
}

/* 4. 하단 버튼 */
.test-footer {
	margin-top: 40px;
	display: flex;
	gap: 10px;
}

.nav-btn {
	flex: 1;
	padding: 16px;
	border-radius: 12px;
	border: none;
	cursor: pointer;
	font-weight: bold;
	font-size: 16px;
	transition: 0.2s;
}

#prevBtn {
	background: #eee;
	color: #777;
}

#nextBtn {
	background: #007bff;
	color: #fff;
}

.nav-btn:disabled {
	opacity: 0.5;
	cursor: not-allowed;
}

/* 5. 로딩 화면 */
#loading-screen {
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(255, 255, 255, 0.98);
	z-index: 1000;
	display: none;
	flex-direction: column;
	justify-content: center;
	align-items: center;
}

.loading-icon {
	font-size: 60px;
	animation: bounce 1s infinite;
	margin-bottom: 20px;
}

@
keyframes bounce { 0%, 100% {
	transform: translateY(0);
}

50






%
{
transform






:






translateY




(






-20px






)




;
}
}
.loading-bar {
	width: 200px;
	height: 6px;
	background: #eee;
	border-radius: 10px;
	overflow: hidden;
	margin-top: 20px;
}

.loading-fill {
	width: 0%;
	height: 100%;
	background: #007bff;
	animation: fillProgress 3s forwards;
}

@
keyframes fillProgress {from { width:0%;
	
}

to {
	width: 100%;
}
}
</style>
</head>
<body>

	<!-- header -->
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<!-- header -->

	<div class="test-wrapper">
		<div class="progress-info">
			<span>진행률</span> <span><span id="percentNum">0</span>%</span>
		</div>
		<div class="progress-track">
			<div class="progress-bar" id="progressBar"></div>
		</div>

		<div class="question-header">
			<span id="qNumber">Q1.</span>
			<h2 id="qTitle">질문을 불러오는 중...</h2>
			<p class="q-guide">(중복 선택이 가능합니다)</p>
		</div>

		<div id="answerGrid" class="answer-grid"></div>

		<div class="test-footer">
			<button class="nav-btn" id="prevBtn" onclick="prevStep()" disabled>이전</button>
			<button class="nav-btn" id="nextBtn" onclick="nextStep()">다음
				단계로</button>
		</div>
	</div>

	<div id="loading-screen">
		<div class="loading-icon" id="loadingIcon">✈️</div>
		<h2 style="font-weight: 700; text-align: center;">
			당신의 여행 스타일을<br>분석하고 있습니다...
		</h2>

		<div class="loading-bar">
			<div class="loading-fill" id="loadingBarFill"></div>
		</div>

		<div
			style="margin-top: 15px; font-size: 24px; font-weight: bold; color: #007bff;">
			<span id="loading-percent">0</span>%
		</div>
	</div>

	<script>
	console.log(${usersDTO.userNo});
	const questions = [
	    { 
	        title: "지금 당장 떠난다면 보고 싶은 풍경은?", 
	        category: "LOCATION",
	        options: [
	            { text: "산·자연", icon: "⛰️", value: "LOC_NATURE_MT" },
	            { text: "바다·해변", icon: "🌊", value: "LOC_SEA_BEACH" },
	            { text: "도시·문화", icon: "🏙️", value: "LOC_CITY_CULTURE" },
	            { text: "시골·온천", icon: "🏡", value: "LOC_RURAL_COUNTRY" }
	        ] 
	    },
	    { 
	        title: "여행 계획 스타일은 어떤가요?", 
	        category: "PLANNING",
	        options: [
	            { text: "분 단위 계획형", icon: "📅", value: "PLAN_HIGH" },
	            { text: "주요 스팟만 선정", icon: "📍", value: "PLAN_MID" },
	            { text: "발길 닿는 대로 즉흥", icon: "👣", value: "SPONTANEOUS_HIGH" },
	            { text: "남이 짜준 대로", icon: "🤝", value: "DEPENDENT_STYLE" }
	        ] 
	    },
	    { 
	        title: "선호하는 이동 수단은?", 
	        category: "MOVE",
	        options: [
	            { text: "자가용·렌트카", icon: "🚗", value: "MOVE_CAR_RENT" },
	            { text: "대중교통", icon: "🚌", value: "MOVE_PUBLIC_TRANSIT" },
	            { text: "택시", icon: "🚕", value: "MOVE_TAXI" },
	            { text: "도보 여행", icon: "👟", value: "MOVE_WALK" }
	        ] 
	    },
	    { 
	        title: "숙소에서 가장 중요한 것은?", 
	        category: "STAY",
	        options: [
	            { text: "호텔·리조트", icon: "🏨", value: "STAY_HOTEL_RESORT" },
	            { text: "감성 에어비앤비", icon: "🏡", value: "STAY_PENSION_ROOM" },
	            { text: "자연 속 캠핑", icon: "⛺", value: "STAY_CAMPING_GLAMP" },
	            { text: "가성비 게하", icon: "🏠", value: "STAY_GUEST_SHARE" }
	        ] 
	    },
	    { 
	        title: "여행 중 지출 스타일은?", 
	        category: "BUDGET",
	        options: [
	            { text: "철저한 예산형", icon: "💰", value: "BUDGET_LOW" },
	            { text: "가성비 중심", icon: "⚖️", value: "BUDGET_VALUE" },
	            { text: "쓸 땐 쓰는 스타일", icon: "💎", value: "BUDGET_MID_SATISFY" },
	            { text: "플렉스 스타일", icon: "💳", value: "BUDGET_FLEX" }
	        ] 
	    },
	    { 
	        title: "함께 가고 싶은 파트너는?", 
	        category: "COMPANION",
	        options: [
	            { text: "혼자만의 여행", icon: "🙋", value: "COMP_SOLO" },
	            { text: "사랑하는 연인", icon: "👩‍❤️‍👨", value: "COMP_COUPLE" },
	            { text: "가족과 함께", icon: "👨‍👩‍👧‍👦", value: "COMP_FAMILY" },
	            { text: "즐거운 친구들", icon: "👯", value: "COMP_FRIENDS" }
	        ] 
	    },
	    { 
	        title: "여행의 꽃, 음식 스타일은?", 
	        category: "FOOD_STYLE",
	        options: [
	            { text: "유명 맛집 탐방", icon: "🍱", value: "FOOD_GOURMET" },
	            { text: "로컬 현지 음식", icon: "🥘", value: "FOOD_LOCAL" },
	            { text: "간편식·편의점", icon: "🥪", value: "FOOD_QUICK" },
	            { text: "직접 요리", icon: "🥩", value: "FOOD_MEAT_SEAFOOD" }
	        ] 
	    },
	    { 
	        title: "여행의 주된 목적은?", 
	        category: "PURPOSE",
	        options: [
	            { text: "완전한 휴식", icon: "🧘", value: "PURPOSE_REST" },
	            { text: "액티비티·체험", icon: "🧗", value: "PURPOSE_ACTIVITY" },
	            { text: "인생샷 남기기", icon: "📸", value: "PURPOSE_PHOTO" },
	            { text: "문화·역사 공부", icon: "🏛️", value: "PURPOSE_HISTORY_CULTURE" }
	        ] 
	    },
	    { 
	        title: "하루 일정의 강도는?", 
	        category: "INTENSITY",
	        options: [
	            { text: "숙소에서 힐링", icon: "🛌", value: "INTENSITY_VERY_LOW" },
	            { text: "여유로운 일정", icon: "🚶", value: "INTENSITY_LOW" },
	            { text: "바쁜 관광 일정", icon: "🏃", value: "INTENSITY_HIGH" },
	            { text: "밤까지 풀코스", icon: "🔥", value: "INTENSITY_VERY_HIGH" }
	        ] 
	    },
	    { 
	        title: "어떤 분위기를 선호하나요?", 
	        category: "MOOD",
	        options: [
	            { text: "북적이는 핫플", icon: "🔥", value: "MOOD_HOTPLACE" },
	            { text: "조용한 숨은 명소", icon: "🤫", value: "MOOD_STATIC" },
	            { text: "계절감이 있는 곳", icon: "🍂", value: "MOOD_SEASONAL" },
	            { text: "화려한 야경", icon: "🌃", value: "MOOD_NIGHT_VIEW" }
	        ] 
	    }
	];

    let currentStep = 0;
    // 중복 선택을 위해 배열 형태로 저장하도록 변경
    let userAnswers = {}; 

    function render() {
        const q = questions[currentStep];
        document.getElementById('qNumber').innerText = "Q" + (currentStep + 1) + ".";
        document.getElementById('qTitle').innerText = q.title;
        
        const grid = document.getElementById('answerGrid');
        grid.innerHTML = ''; 

        // 현재 단계의 답변 데이터가 없으면 빈 배열로 초기화
        if (!userAnswers[currentStep]) userAnswers[currentStep] = [];

        q.options.forEach((opt, idx) => {
            const card = document.createElement('div');
            card.className = 'answer-card';
            
            // 중복 선택 확인: 배열 안에 해당 index가 있는지 체크
            if (userAnswers[currentStep].includes(idx)) {
                card.classList.add('selected');
            }
            
            card.innerHTML = '<span class="icon">' + opt.icon + '</span><span class="label">' + opt.text + '</span>';
            
            card.onclick = function() {
                const answerIdx = userAnswers[currentStep].indexOf(idx);
                if (answerIdx > -1) {
                    // 이미 선택되어 있으면 제거 (토글)
                    userAnswers[currentStep].splice(answerIdx, 1);
                } else {
                    // 새로 선택하면 배열에 추가
                    userAnswers[currentStep].push(idx);
                }
                render(); // 화면 갱신
            };
            grid.appendChild(card);
        });

     // 프로그레스 바 및 퍼센트 수치 업데이트
     // currentStep + 1 대신 currentStep을 사용하여 0번 질문일 때 0%부터 시작하게 합니다.
     const progress = Math.floor((currentStep / questions.length) * 100);
     document.getElementById('progressBar').style.width = progress + "%";
     document.getElementById('percentNum').innerText = progress;

     document.getElementById('prevBtn').disabled = (currentStep === 0);
     document.getElementById('nextBtn').innerText = (currentStep === questions.length - 1) ? "분석 결과 보기" : "다음 단계로";
    }

    function nextStep() {
        // 중복 선택이므로 아무것도 안 골랐을 때 체크
        if (!userAnswers[currentStep] || userAnswers[currentStep].length === 0) {
            alert("최소 하나 이상의 답변을 선택해 주세요!");
            return;
        }
        
        if (currentStep < questions.length - 1) {
            currentStep++;
            render();
            window.scrollTo(0, 0);
        } else {
            showLoading();
        }
    }

    function prevStep() {
        if (currentStep > 0) {
            currentStep--;
            render();
        }
    }

    function showLoading() {
        // 1. 기존 질문지 영역 숨기고 로딩 화면 표시
        document.querySelector('.test-wrapper').style.display = 'none';
        const loadingScreen = document.getElementById('loading-screen');
        if (loadingScreen) loadingScreen.style.display = 'flex';
        
        const bar = document.getElementById('loadingBarFill'); // 로딩 바 게이지
        const percentText = document.getElementById('loading-percent'); // 퍼센트 숫자
        const iconBox = document.getElementById('loadingIcon'); // 비행기/가방 아이콘

        // 2. 아이콘 변경 타이머 (0.6초마다 아이콘이 바뀜)
        const icons = ["✈️", "🧳", "🏝️", "🏔️", "🗺️"];
        let i = 0;
        const iconInterval = setInterval(() => {
            if(iconBox) iconBox.innerText = icons[i % icons.length];
            i++;
        }, 600);

        // 3. 퍼센트 및 게이지 상승 애니메이션 (0% -> 100%)
        let gauge = 0;
        const gaugeInterval = setInterval(() => {
            gauge++;
            if (percentText) percentText.innerText = gauge;
            if (bar) bar.style.width = gauge + "%";

            if (gauge >= 100) {
                clearInterval(gaugeInterval);
                clearInterval(iconInterval); // 애니메이션 종료 시 아이콘 변경도 멈춤
            }
        }, 30); // 약 3초 동안 진행 (30ms * 100)

        // 4. 3.5초 후 서버로 데이터 전송 (애니메이션 완료 후 실행)
        setTimeout(() => {
            const resultData = [];
            for (let step in userAnswers) {
                const questionId = parseInt(step) + 1; // 질문 번호 (1번부터)
                
                userAnswers[step].forEach(optionIdx => {
                    resultData.push({
                        userNo: "${not empty usersDTO ? usersDTO.userNo : 0}", // 세션의 사용자 번호
                        questionId: questionId,
                        tagCode: questions[step].options[optionIdx].value // 'LOC_NATURE_MT' 등
                    });
                });
            }
            console.log("전송 데이터 확인:", JSON.stringify(resultData));
            
            // ★ [보안] Spring Security CSRF 토큰 읽기
            const tokenMeta = document.querySelector('meta[name="_csrf"]');
            const headerMeta = document.querySelector('meta[name="_csrf_header"]');
            
            if (!tokenMeta || !headerMeta) {
                console.error("CSRF 메타 태그가 없습니다. JSP 상단에 코드를 추가했는지 확인하세요.");
                alert("보안 토큰 오류가 발생했습니다.");
                return;
            }

            const token = tokenMeta.content;
            const header = headerMeta.content;

            // ★ [전송] fetch API를 이용한 POST 요청
            console.log('111111111111111');
            fetch("${pageContext.request.contextPath}/hashTrip/saveAnalysis", {
                method: "POST",
                headers: { 
                    "Content-Type": "application/json",
                    [header]: token  // CSRF 헤더 반드시 포함 (403 방어)
                },
                body: JSON.stringify(resultData)
            })
            .then(response => {
            	console.log('33333');
            	console.log(response);
                if(response.ok) {
                    // 저장 성공 시 결과 페이지로 이동
                    console.log('222222');
                    location.href = "${pageContext.request.contextPath}/hashTrip/analysisResult";
                    console.log('3333');
                } else {
                	console.log('44444');
                    // 403, 500 등 에러 발생 시
                    console.error("저장 실패 상태 코드:", response.status);
                    alert("저장 중 오류가 발생했습니다. (상태 코드: " + response.status + ")");
                    // 실패 시 다시 테스트 화면을 보여주려면 아래 코드 주석 해제
                    // loadingScreen.style.display = 'none';
                    // document.querySelector('.test-wrapper').style.display = 'block';
                }
            })
            .catch(err => {
            	console.log('55555');
                console.error("통신 에러:", err);
                alert("서버와 통신하는 중 문제가 발생했습니다.");
            });
        }, 3500);
    }

    window.onload = render;
</script>
</body>
</html>