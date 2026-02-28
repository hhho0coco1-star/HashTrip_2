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
	font-size: 1.8 rem;
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

@keyframes fadeInUp {
	from { transform:translateY(30px); opacity: 0; }
	to { transform:translateY(0); opacity: 1; }
}
</style>

<body>

	<section class="result-section">
		<div class="result-card">
			<p class="user-name">여행 스타일은?</p>

			<h3 class="main-sentence" id="typeSentence">
				${finalResult}</h3>

			<p style="color: #666; margin-top: 20px;">
				당신을 위해 딱 맞는 여행지를 찾아보았어요!
			</p>

			<div class="action-buttons">
				<a href="recommend" class="btn-analysis" style="padding: 10px 20px; background-color: #007bff; color: white; border-radius: 10px; text-decoration: none;">추천 여행일정 보러가기</a>
				<a href="/hashTrip/analysis" class="btn-analysis" style="padding: 10px 20px; background-color: #007bff; color: white; border-radius: 10px; text-decoration: none;">다시 테스트하기</a>
			</div>
		</div>
	</section>

	<script>
    document.addEventListener('DOMContentLoaded', function() {
        const sentence = document.getElementById('typeSentence');
        sentence.style.opacity = '0';
        setTimeout(() => {
            sentence.style.transition = 'opacity 1.5s';
            sentence.style.opacity = '1';
        }, 300);
    });
	</script>

</body>
</html>