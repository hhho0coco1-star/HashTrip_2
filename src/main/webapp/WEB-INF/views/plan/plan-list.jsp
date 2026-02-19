<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 일정 목록</title>
    <style>
        body { margin: 0; font-family: 'Noto Sans KR', sans-serif; background: #f8fafc; color: #0f172a; }
        .wrap { max-width: 920px; margin: 0 auto; padding: 28px 16px 48px; }
        .top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .title { font-size: 28px; font-weight: 700; }
        .btn-new { display: inline-block; padding: 10px 16px; border-radius: 10px; background: #2563eb; color: #fff; text-decoration: none; font-weight: 600; }
        .msg { margin: 12px 0; padding: 10px 12px; border-radius: 8px; font-size: 14px; }
        .msg.ok { border: 1px solid #86efac; background: #f0fdf4; color: #166534; }
        .msg.err { border: 1px solid #fda4af; background: #fff1f2; color: #9f1239; }
        .list { display: grid; gap: 10px; }
        .item { display: flex; justify-content: space-between; align-items: center; padding: 16px; border: 1px solid #e2e8f0; border-radius: 12px; background: #fff; text-decoration: none; color: inherit; }
        .item:hover { border-color: #93c5fd; box-shadow: 0 6px 20px rgba(37, 99, 235, 0.08); }
        .name { font-size: 16px; font-weight: 600; }
        .status { font-size: 13px; font-weight: 700; padding: 6px 10px; border-radius: 999px; }
        .st-planning { background: #dbeafe; color: #1d4ed8; }
        .st-recording { background: #ccfbf1; color: #0f766e; }
        .st-completed { background: #ede9fe; color: #6d28d9; }
        .st-default { background: #e2e8f0; color: #334155; }
        .empty { padding: 36px; text-align: center; border: 1px dashed #cbd5e1; border-radius: 12px; background: #fff; color: #475569; }
    </style>
</head>
<body>
<div class="wrap">
    <div class="top">
        <div class="title">내 일정 목록</div>
        <a class="btn-new" href="${pageContext.request.contextPath}/plan/new">새 일정 작성</a>
    </div>

    <c:if test="${not empty planSaveMessage}">
        <div class="msg ok"><c:out value="${planSaveMessage}"/></div>
    </c:if>
    <c:if test="${not empty planSaveError}">
        <div class="msg err"><c:out value="${planSaveError}"/></div>
    </c:if>

    <c:choose>
        <c:when test="${empty myPlans}">
            <div class="empty">
                저장된 일정이 없습니다. 새 일정을 작성해 주세요.
            </div>
        </c:when>
        <c:otherwise>
            <div class="list">
                <c:forEach var="plan" items="${myPlans}">
                    <a class="item" href="${pageContext.request.contextPath}/plan/${plan.planNo}/edit">
                        <div class="name"><c:out value="${plan.planTitle}"/></div>
                        <c:choose>
                            <c:when test="${plan.planStatus eq 'PLANNING'}">
                                <span class="status st-planning">계획 중</span>
                            </c:when>
                            <c:when test="${plan.planStatus eq 'RECORDING'}">
                                <span class="status st-recording">기록 중</span>
                            </c:when>
                            <c:when test="${plan.planStatus eq 'COMPLETED'}">
                                <span class="status st-completed">완료</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status st-default"><c:out value="${plan.planStatus}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </a>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>