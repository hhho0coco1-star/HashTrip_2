<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>여행 일정 — #HiFive</title>
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;600;700;800&family=Gmarket+Sans:wght@300;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/planner/planner-list.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <div class="planner-page">
        <div class="planner-list-wrap">
            <div class="planner-page-header">
                <div class="planner-page-badge">MY PLANS</div>
                <div class="planner-page-header-row">
                    <h2 class="planner-page-title">📋 여행 일정</h2>
                    <a class="planner-btn-new" href="${pageContext.request.contextPath}/planner/new">+ 새 여행 만들기</a>
                </div>
                <p class="planner-page-subtitle">나의 여행 일정을 관리하고 수정해 보세요</p>
            </div>

            <c:if test="${not empty plannerMessage}">
                <div class="planner-msg planner-msg-ok"><c:out value="${plannerMessage}"/></div>
            </c:if>
            <c:if test="${not empty plannerError}">
                <div class="planner-msg planner-msg-err"><c:out value="${plannerError}"/></div>
            </c:if>

            <%-- 필터: 전체 / 계획 중 / 여행 중 / 완료 --%>
            <div class="planner-filter-bar">
                <a class="planner-filter-chip ${empty activeStatus ? 'active' : ''}" href="${pageContext.request.contextPath}/planner">전체</a>
                <a class="planner-filter-chip ${activeStatus == 'PLANNING' ? 'active' : ''}" href="${pageContext.request.contextPath}/planner?status=PLANNING">계획 중</a>
                <a class="planner-filter-chip ${activeStatus == 'COMPLETED' ? 'active' : ''}" href="${pageContext.request.contextPath}/planner?status=COMPLETED">완료</a>
            </div>

            <c:choose>
                <c:when test="${empty myPlans}">
                    <div class="planner-empty">
                        <div class="empty-icon">📋</div>
                        <p>
                            <c:choose>
                                <c:when test="${activeStatus == 'PLANNING'}">계획 중인 일정이 없어요</c:when>
                                <c:when test="${activeStatus == 'RECORDING'}">여행 중인 일정이 없어요</c:when>
                                <c:when test="${activeStatus == 'COMPLETED'}">완료된 일정이 없어요</c:when>
                                <c:otherwise>저장된 일정이 없어요</c:otherwise>
                            </c:choose>
                        </p>
                        <a class="planner-btn-new planner-btn-new-empty" href="${pageContext.request.contextPath}/planner/new">새 여행 만들기</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="planner-plan-grid">
                        <c:forEach var="plan" items="${myPlans}">
                            <c:set var="planTitle" value="${plan.planTitle}" />
                            <div class="planner-plan-card">
                                <a class="planner-plan-card-link" href="${pageContext.request.contextPath}/planner/${plan.planNo}/edit">
                                    <div class="planner-plan-head">
                                        <div class="planner-plan-pin">📌</div>
                                        <div class="planner-plan-info">
                                            <c:choose>
                                                <c:when test="${not empty planTitle and fn:length(planTitle) > 12}">
                                                    <div class="planner-plan-title" title="${planTitle}">
                                                        <c:out value="${fn:substring(planTitle, 0, 12)}"/>...
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="planner-plan-title">
                                                        <c:out value="${planTitle}"/>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="planner-plan-meta-row">
                                                <c:if test="${not empty plan.planStartDate && not empty plan.planEndDate}">
                                                    <span class="planner-plan-dates">
                                                        <fmt:formatDate value="${plan.planStartDate}" pattern="M/d"/> ~
                                                        <fmt:formatDate value="${plan.planEndDate}" pattern="M/d"/>
                                                    </span>
                                                </c:if>
                                                <span class="planner-plan-status planner-status-${plan.planStatus}">
                                                    <c:choose>
                                                        <c:when test="${plan.planStatus eq 'PLANNING'}">계획 중</c:when>
                                                        <c:when test="${plan.planStatus eq 'RECORDING'}">여행 중</c:when>
                                                        <c:when test="${plan.planStatus eq 'COMPLETED'}">완료</c:when>
                                                        <c:otherwise><c:out value="${plan.planStatus}"/></c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    <%-- 일정 순서 + 썸네일 --%>
                                    <c:if test="${not empty plan.planDetails}">
                                        <div class="planner-plan-steps">
                                            <div class="planner-step-thumbs">
                                                <c:forEach var="detail" items="${plan.planDetails}" varStatus="st">
                                                    <div class="planner-step-thumb" title="<c:out value='${detail.placeName}' default='장소'/>">
                                                        <c:choose>
                                                            <c:when test="${not empty detail.placeThumbnailUrl}">
                                                                <img src="${detail.placeThumbnailUrl}" alt="" />
                                                                <span class="planner-step-order">${st.index + 1}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="planner-step-thumb-placeholder">${st.index + 1}</div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <c:if test="${!st.last}">
                                                        <span class="planner-step-arrow">→</span>
                                                    </c:if>
                                                </c:forEach>
                                            </div>
                                            <div class="planner-step-names">
                                                <c:forEach var="detail" items="${plan.planDetails}" varStatus="st">
                                                    <span class="planner-step-name"><c:out value="${detail.placeName}" default="장소"/></span><c:if test="${!st.last}"><span class="planner-step-arrow">→</span></c:if>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty plan.createdAt or not empty plan.updatedAt}">
                                        <div class="planner-plan-meta planner-plan-meta-dates">
                                            <c:if test="${not empty plan.createdAt}">작성 <fmt:formatDate value="${plan.createdAt}" pattern="dd.MM.yy"/></c:if><c:if test="${not empty plan.createdAt and not empty plan.updatedAt}"> · </c:if><c:if test="${not empty plan.updatedAt}">수정 <fmt:formatDate value="${plan.updatedAt}" pattern="dd.MM.yy"/></c:if>
                                        </div>
                                    </c:if>
                                </a>
                                <form class="planner-plan-delete-form" action="${pageContext.request.contextPath}/planner/${plan.planNo}/delete" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <button type="submit" class="planner-btn-delete" onclick="return confirm('이 일정을 삭제하시겠습니까?');">삭제</button>
                                </form>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />
</body>
</html>
