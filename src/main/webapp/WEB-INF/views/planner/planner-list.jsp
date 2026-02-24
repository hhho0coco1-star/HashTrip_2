<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>여행 일정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/planner/planner-list.css">
</head>
<body class="planner-list-body">
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <main class="planner-list-shell">
        <div class="planner-list-wrap">
            <div class="planner-list-top">
                <h1 class="planner-list-title">여행 일정</h1>
                <a class="planner-btn-new" href="${pageContext.request.contextPath}/planner/new">새 여행 루트 만들기</a>
            </div>

            <c:if test="${not empty plannerMessage}">
                <div class="planner-msg planner-msg-ok"><c:out value="${plannerMessage}"/></div>
            </c:if>
            <c:if test="${not empty plannerError}">
                <div class="planner-msg planner-msg-err"><c:out value="${plannerError}"/></div>
            </c:if>

            <c:choose>
                <c:when test="${empty myPlans}">
                    <div class="planner-empty">저장된 일정이 없습니다. 새 여행 루트를 만들어 보세요.</div>
                </c:when>
                <c:otherwise>
                    <ul class="planner-list">
                        <c:forEach var="plan" items="${myPlans}">
                            <li class="planner-item">
                                <a class="planner-item-link" href="${pageContext.request.contextPath}/planner/${plan.planNo}/edit">
                                    <span class="planner-item-title"><c:out value="${plan.planTitle}"/></span>
                                    <c:if test="${not empty plan.planStartDate && not empty plan.planEndDate}">
                                        <span class="planner-item-dates">
                                            <fmt:formatDate value="${plan.planStartDate}" pattern="M/d"/> ~
                                            <fmt:formatDate value="${plan.planEndDate}" pattern="M/d"/>
                                        </span>
                                    </c:if>
                                    <span class="planner-item-status">
                                        <c:choose>
                                            <c:when test="${plan.planStatus eq 'PLANNING'}">계획 중</c:when>
                                            <c:when test="${plan.planStatus eq 'RECORDING'}">여행 중</c:when>
                                            <c:when test="${plan.planStatus eq 'COMPLETED'}">완료</c:when>
                                            <c:otherwise><c:out value="${plan.planStatus}"/></c:otherwise>
                                        </c:choose>
                                    </span>
                                </a>
                                <form class="planner-item-delete-form" action="${pageContext.request.contextPath}/planner/${plan.planNo}/delete" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <button type="submit" class="planner-btn-delete" onclick="return confirm('이 일정을 삭제하시겠습니까?');">삭제</button>
                                </form>
                            </li>
                        </c:forEach>
                    </ul>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />
</body>
</html>
