<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${route.title} 상세 일정</title>
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
            <h1 class="route-title"><c:out value="${route.title}"/></h1>
        </div>
        <p class="personal-desc" style="margin-top:15px;">
            <strong><c:out value="${route.userName}"/></strong> 추천 코스: <c:out value="${route.description}"/>
        </p>
    </header>

    <section>
        <c:choose>
            <c:when test="${not empty routePlanDetails}">
                <c:forEach var="step" items="${routePlanDetails}" varStatus="status">
                    <div class="step-card<c:if test='${not empty step.placeNo}'> step-card-clickable</c:if>"
                         <c:if test="${not empty step.placeNo}">onclick="location.href='${pageContext.request.contextPath}/place/detail?place_no=${step.placeNo}'"</c:if>>
                        <div style="display:flex; align-items:center; gap:20px;">
                            <div class="step-number-box" style="width:40px; height:40px; background:var(--bg-gray-100); border-radius:12px; display:flex; align-items:center; justify-content:center; font-weight:800; color:var(--primary-blue);">
                                ${status.count}
                            </div>
                            <div style="font-size:1.2rem; font-weight:700;">
                                <c:out value="${empty step.placeName ? '경유지' : step.placeName}"/>
                            </div>
                        </div>
                        <c:if test="${not empty currentAuthId}">
                            <button class="btn-place-save" type="button" onclick="appendSinglePlaceToExistingPlan(event, ${route.id}, ${step.planDetailNo})">
                                이 장소만 추가
                            </button>
                        </c:if>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <c:forEach var="step" items="${route.steps}" varStatus="status">
                    <div class="step-card">
                        <div style="display:flex; align-items:center; gap:20px;">
                            <div class="step-number-box" style="width:40px; height:40px; background:var(--bg-gray-100); border-radius:12px; display:flex; align-items:center; justify-content:center; font-weight:800; color:var(--primary-blue);">
                                ${status.count}
                            </div>
                            <div style="font-size:1.2rem; font-weight:700;"><c:out value="${step}"/></div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="plan-actions-panel">
        <h3>내 일정에 담기</h3>
        <c:choose>
            <c:when test="${empty currentAuthId}">
                <div class="login-hint">
                    로그인하면 추천 일정을 내 일정으로 복사하거나 기존 일정에 추가할 수 있습니다.
                    <a href="${pageContext.request.contextPath}/auth/login">로그인</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="plan-action-row">
                    <input type="text" id="copy-plan-title" class="plan-action-input" placeholder="새 일정 제목 (비우면 자동 생성)">
                    <button type="button" class="btn-detail-action btn-copy-route" onclick="copyRouteToNewPlan(${route.id})">새 일정으로 복사</button>
                </div>
                <div class="plan-action-row">
                    <select id="target-plan-no" class="plan-action-select">
                        <option value="">기존 일정 선택</option>
                        <c:forEach var="myPlan" items="${myPlans}">
                            <option value="${myPlan.planNo}">
                                <c:out value="${myPlan.planTitle}"/> (#${myPlan.planNo})
                            </option>
                        </c:forEach>
                    </select>
                    <button type="button" class="btn-detail-action btn-append-route" onclick="appendRouteToExistingPlan(${route.id})">기존 일정에 코스 전체 추가</button>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="review-container">
        <h3 style="font-family:'Gmarket Sans'; margin-bottom:24px;">여행자 리뷰 <span style="color:var(--primary-blue);" id="review-count">${fn:length(reviews)}</span></h3>

        <form id="review-form" class="review-form" onsubmit="submitReview(event, ${route.id})">
            <textarea id="review-content" class="review-input" placeholder="코스 경험을 공유해 주세요." maxlength="2000" required></textarea>
            <div class="review-form-row">
                <div>
                    <label for="review-rating">평점</label>
                    <select id="review-rating" name="rating">
                        <option value="5">5점</option>
                        <option value="4">4점</option>
                        <option value="3">3점</option>
                        <option value="2">2점</option>
                        <option value="1">1점</option>
                    </select>
                </div>
                <button type="submit" class="btn-detail-action btn-review-main">리뷰 등록</button>
            </div>
        </form>

        <div id="review-list">
            <c:choose>
                <c:when test="${empty reviews}">
                    <div class="review-empty">첫 리뷰를 작성해보세요.</div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="review" items="${reviews}">
                        <div class="review-item">
                            <div class="review-head">
                                <strong><c:out value="${not empty review.createdBy ? review.createdBy : '익명'}"/></strong>
                                <span class="review-rating">평점 <c:out value="${not empty review.rating ? review.rating : 0}"/></span>
                            </div>
                            <div class="review-content"><c:out value="${review.reviewContent}"/></div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</main>

<div class="toast" id="toast"></div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    const csrfHeader = '${_csrf.headerName}';
    const csrfToken = '${_csrf.token}';

    function toAbsolutePath(path) {
        if (!path) return contextPath + '/auth/login';
        if (path.startsWith('http://') || path.startsWith('https://')) return path;
        if (path.startsWith(contextPath)) return path;
        return path.startsWith('/') ? (contextPath + path) : (contextPath + '/' + path);
    }

    function handleLoginRedirect(data) {
        if (data && data.loginRequired) {
            showToast(data.message || '로그인이 필요합니다.');
            setTimeout(function () {
                location.href = toAbsolutePath(data.redirectUrl || '/auth/login');
            }, 500);
            return true;
        }
        return false;
    }

    async function postForm(url, body) {
        const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
        if (csrfHeader && csrfToken) {
            headers[csrfHeader] = csrfToken;
        }

        const response = await fetch(url, {
            method: 'POST',
            headers,
            body
        });

        const text = await response.text();
        let data = null;
        try {
            data = text ? JSON.parse(text) : {};
        } catch (e) {
            data = {
                success: false,
                message: '서버 응답을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.'
            };
        }

        if (!response.ok && (!data || !data.message)) {
            data = data || {};
            data.success = false;
            data.message = '요청 처리 중 오류가 발생했습니다. (' + response.status + ')';
        }

        return { response, data };
    }

    async function submitReview(event, routeId) {
        event.preventDefault();

        const contentInput = document.getElementById('review-content');
        const ratingInput = document.getElementById('review-rating');
        const content = contentInput.value.trim();
        const rating = ratingInput.value;

        if (!content) {
            showToast('리뷰 내용을 입력해 주세요.');
            return;
        }

        try {
            const body = 'reviewContent=' + encodeURIComponent(content) + '&rating=' + encodeURIComponent(rating);
            const result = await postForm(contextPath + '/routes/' + routeId + '/reviews', body);
            const data = result.data;

            if (handleLoginRedirect(data)) return;
            if (!result.response.ok || !data.success) {
                showToast(data && data.message ? data.message : '리뷰 저장 중 오류가 발생했습니다.');
                return;
            }

            prependReview(data.review);
            document.getElementById('review-count').textContent = data.reviewCount;
            contentInput.value = '';
            ratingInput.value = '5';
            showToast('리뷰가 등록되었습니다.');
        } catch (e) {
            showToast('리뷰 저장 중 오류가 발생했습니다.');
        }
    }

    async function copyRouteToNewPlan(routeId) {
        const titleInput = document.getElementById('copy-plan-title');
        const body = 'planTitle=' + encodeURIComponent(titleInput ? titleInput.value.trim() : '');

        try {
            const result = await postForm(contextPath + '/routes/' + routeId + '/copy', body);
            const data = result.data;

            if (handleLoginRedirect(data)) return;
            if (!result.response.ok || !data.success) {
                showToast(data && data.message ? data.message : '일정 복사 중 오류가 발생했습니다.');
                return;
            }

            showToast(data.message || '새 일정으로 복사했습니다.');
            if (titleInput) titleInput.value = '';

            if (data.redirectUrl) {
                setTimeout(function () {
                    location.href = toAbsolutePath(data.redirectUrl);
                }, 700);
            }
        } catch (e) {
            showToast('일정 복사 중 오류가 발생했습니다.');
        }
    }

    async function appendRouteToExistingPlan(routeId) {
        const targetPlanNo = document.getElementById('target-plan-no').value;
        if (!targetPlanNo) {
            showToast('추가할 기존 일정을 선택해 주세요.');
            return;
        }

        try {
            const body = 'targetPlanNo=' + encodeURIComponent(targetPlanNo);
            const result = await postForm(contextPath + '/routes/' + routeId + '/append', body);
            const data = result.data;

            if (handleLoginRedirect(data)) return;
            if (!result.response.ok || !data.success) {
                showToast(data && data.message ? data.message : '일정 추가 중 오류가 발생했습니다.');
                return;
            }

            showToast(data.message || '기존 일정에 코스 전체를 추가했습니다.');
        } catch (e) {
            showToast('일정 추가 중 오류가 발생했습니다.');
        }
    }

    async function appendSinglePlaceToExistingPlan(event, routeId, sourcePlanDetailNo) {
        if (event && typeof event.stopPropagation === 'function') {
            event.stopPropagation();
        }

        const targetPlanNo = document.getElementById('target-plan-no').value;
        if (!targetPlanNo) {
            showToast('먼저 아래에서 기존 일정을 선택해 주세요.');
            return;
        }

        if (!sourcePlanDetailNo) {
            showToast('원본 장소 정보를 찾을 수 없습니다.');
            return;
        }

        try {
            const body = 'targetPlanNo=' + encodeURIComponent(targetPlanNo)
                + '&sourcePlanDetailNo=' + encodeURIComponent(sourcePlanDetailNo);

            const result = await postForm(contextPath + '/routes/' + routeId + '/append-place', body);
            const data = result.data;

            if (handleLoginRedirect(data)) return;
            if (!result.response.ok || !data.success) {
                showToast(data && data.message ? data.message : '장소 추가 중 오류가 발생했습니다.');
                return;
            }

            showToast(data.message || '선택한 장소를 기존 일정에 추가했습니다.');
        } catch (e) {
            showToast('장소 추가 중 오류가 발생했습니다.');
        }
    }

    function prependReview(review) {
        const list = document.getElementById('review-list');
        const empty = list.querySelector('.review-empty');
        if (empty) empty.remove();

        const name = review && review.createdBy ? review.createdBy : '익명';
        const rating = review && review.rating ? review.rating : 0;
        const content = review && review.reviewContent ? review.reviewContent : '';

        const item = document.createElement('div');
        item.className = 'review-item';
        item.innerHTML = ''
            + '<div class="review-head">'
            + '<strong>' + escapeHtml(name) + '</strong>'
            + '<span class="review-rating">평점 ' + escapeHtml(String(rating)) + '</span>'
            + '</div>'
            + '<div class="review-content">' + escapeHtml(content) + '</div>';

        list.prepend(item);
    }

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
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
