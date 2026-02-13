<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${route.title} — 상세 일정</title>
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@400;600;700;800&family=Gmarket+Sans:wght@500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/routes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/routeDetail.css">
</head>
<body style="background-color: var(--bg-gray-50);">

<nav class="navbar scrolled">
    <div class="logo" onclick="location.href='${pageContext.request.contextPath}/routes'">#HiFive</div>
</nav>

<main class="detail-container">
    <header class="detail-header">
        <div class="type-badge" style="background:none; padding-left:0; color:var(--text-tertiary);">COURSE DETAIL</div>
        <div class="title-row">
            <h1 class="route-title">${route.title}</h1>
            <button class="btn-like-raw" id="main-heart" onclick="toggleHeart(this)">🤍</button>
        </div>
        <p class="personal-desc" style="margin-top:15px;">
            <strong>${route.userName}</strong> 님의 추천 코스: ${route.description}
        </p>
    </header>

    <section>
        <c:forEach var="step" items="${route.steps}" varStatus="status">
            <div class="step-card">
                <div style="display:flex; align-items:center; gap:20px;">
                    <div class="step-number-box" style="width:40px; height:40px; background:var(--bg-gray-100); border-radius:12px; display:flex; align-items:center; justify-content:center; font-weight:800; color:var(--primary-blue);">
                        ${status.count}
                    </div>
                    <div style="font-size:1.2rem; font-weight:700;">${step}</div>
                </div>
                <button class="btn-place-save" onclick="showToast('${step} 저장 완료!')">📍 저장</button>
            </div>
        </c:forEach>
    </section>

    <div class="action-center-row">
        <button class="btn-detail-action btn-back-light" onclick="history.back()">뒤로가기</button>
        <button class="btn-detail-action btn-review-main" onclick="showToast('리뷰 작성 창을 엽니다.')">✍️ 리뷰쓰기</button>
    </div>

    <section class="review-container">
        <h3 style="font-family:'Gmarket Sans'; margin-bottom:30px;">여행자 리뷰 <span style="color:var(--primary-blue);">3</span></h3>
        
        <div class="review-item">
            <div style="font-weight:700; margin-bottom:8px;">🏕️ 캠핑마스터 <span style="color:#FFD700; margin-left:8px;">★★★★★</span></div>
            <div style="color:var(--text-secondary); line-height:1.6;">정말 완벽한 동선이었어요! 덕분에 가족들과 좋은 추억 만들었습니다.</div>
        </div>
        <div class="review-item">
            <div style="font-weight:700; margin-bottom:8px;">🏃 익스트림러버 <span style="color:#FFD700; margin-left:8px;">★★★★☆</span></div>
            <div style="color:var(--text-secondary); line-height:1.6;">두 번째 장소에서 대기시간이 좀 있었지만 전체적으로 훌륭합니다.</div>
        </div>
    </section>
</main>

<div class="toast" id="toast"></div>

<script>
    function toggleHeart(btn) {
        if(btn.innerText === '🤍') {
            btn.innerText = '❤️';
            showToast('이 루트를 찜했습니다! ❤️');
        } else {
            btn.innerText = '🤍';
            showToast('찜하기 취소');
        }
    }

    function showToast(msg) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.classList.add('show');
        setTimeout(() => t.classList.remove('show'), 2200);
    }
</script>
</body>
</html>