<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>#Trip</title>
<meta name="_csrf" content="${_csrf.token}" />
<meta name="_csrf_header" content="${_csrf.headerName}" />
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>

<style>
.result-section {
	background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.result-card {
	background: white;
	border-radius: 30px;
	padding: 50px;
	box-shadow: 0 20px 50px rgba(0, 0, 0, 0.1);
	max-width: 800px;
	width: 100%;
	text-align: center;
	transform: translateY(30px);
	opacity: 0;
	animation: fadeInUp 0.8s forwards;
}

.user-name {
	font-size: 1.2rem;
	color: #007bff;
	font-weight: bold;
	margin-bottom: 10px;
}

.main-sentence {
	font-size: 2.2rem;
	font-weight: 800;
	line-height: 1.4;
	color: #222;
	margin: 20px 0;
	word-break: keep-all;
}

.type-badge-container {
	display: flex;
	justify-content: center;
	gap: 10px;
	margin-bottom: 30px;
}

.type-badge {
	padding: 8px 20px;
	border-radius: 50px;
	background: #e7f1ff;
	color: #007bff;
	font-weight: 600;
	font-size: 0.9rem;
}

.action-buttons {
	margin-top: 40px;
	display: flex;
	gap: 15px;
	justify-content: center;
}

@
keyframes fadeInUp {to { transform:translateY(0);
	opacity: 1;
}
}
</style>

<body>

	<section class="result-section">
		<div class="result-card">
			<p class="user-name">${analysis.USER_NO}님의여행 스타일은?</p>

			<div class="type-badge-container">
				<span class="type-badge">#${analysis.ENERGY_TEXT}</span> <span
					class="type-badge">#${analysis.PLAN_TEXT}</span>
			</div>

			<h1 class="main-sentence" id="typeSentence">
				${analysis.FINAL_FULL_SENTENCE}</h1>

			<p style="color: #666; margin-top: 20px;">
				${analysis.PLACE_TEXT} 유형에 해당하는 당신을 위해<br> 딱 맞는 여행지를 찾아보았어요!
			</p>

			<div class="action-buttons">
				<a href="recommend" class="btn-analysis">맞춤 여행지 보러가기</a> <a
					href="main"
					style="text-decoration: none; color: #999; font-size: 0.9rem; align-self: center; margin-left: 20px;">다시
					테스트하기</a>
			</div>
		</div>
	</section>

	<script>
    // 페이지 로드 시 문구에 간단한 타이핑 효과 체감 주기 (선택 사항)
    document.addEventListener('DOMContentLoaded', function() {
        const sentence = document.getElementById('typeSentence');
        sentence.style.opacity = '0';
        setTimeout(() => {
            sentence.style.transition = 'opacity 1.5s';
            sentence.style.opacity = '1';
        }, 500);
    });
	</script>

</body>
</html>