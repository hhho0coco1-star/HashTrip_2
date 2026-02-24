<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일정 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/planner/planner.css">
</head>
<body class="planner-edit-body">
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <main class="planner-edit-shell">
        <div class="planner-edit-wrap">
            <c:if test="${not empty plannerMessage}">
                <div class="planner-alert planner-alert-ok"><c:out value="${plannerMessage}"/></div>
            </c:if>
            <c:if test="${not empty plannerError}">
                <div class="planner-alert planner-alert-err"><c:out value="${plannerError}"/></div>
            </c:if>

            <form id="plannerEditForm" action="${pageContext.request.contextPath}/planner/${plan.planNo}" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <input type="hidden" id="planDetailsJson" name="planDetailsJson" value="" />

                <header class="planner-edit-header">
                    <input type="text" class="planner-title-input" id="planTitle" name="planTitle"
                           placeholder="여행 제목" value="<c:out value='${plan.planTitle}'/>" />
                    <a class="planner-back-link" href="${pageContext.request.contextPath}/planner">목록</a>
                </header>

                <section class="planner-period">
                    <label>시작일</label>
                    <input type="date" id="planStartDate" name="planStartDate" value="<fmt:formatDate value='${plan.planStartDate}' pattern='yyyy-MM-dd'/>" />
                    <label>종료일</label>
                    <input type="date" id="planEndDate" name="planEndDate" value="<fmt:formatDate value='${plan.planEndDate}' pattern='yyyy-MM-dd'/>" />
                </section>

                <section class="planner-add-place">
                    <button type="button" id="btnAddPlace" class="planner-btn planner-btn-primary">장소 추가</button>
                </section>

                <section class="planner-timeline">
                    <div id="placeListByDay" class="planner-days"></div>
                </section>

                <div class="planner-edit-actions">
                    <a href="${pageContext.request.contextPath}/planner" class="planner-btn planner-btn-ghost">목록</a>
                    <button type="submit" id="btnSave" class="planner-btn planner-btn-save">저장</button>
                </div>
            </form>
        </div>

        <div id="mapModal" class="planner-modal hidden">
            <div class="planner-modal-content">
                <div class="planner-modal-header">
                    <h2>장소 선택</h2>
                    <button type="button" id="closeMapModal" class="planner-modal-close">&times;</button>
                </div>
                <div class="planner-modal-body">
                    <div class="planner-search-box">
                        <input type="text" id="placeSearch" placeholder="장소 검색" />
                        <button type="button" id="searchBtn">검색</button>
                    </div>
                    <div id="map" class="planner-map-container"></div>
                    <div id="searchResults" class="planner-search-results"></div>
                </div>
                <div class="planner-modal-footer">
                    <button type="button" id="confirmPlace" class="planner-btn planner-btn-primary">선택 완료</button>
                </div>
            </div>
        </div>

        <div id="replaceModal" class="planner-modal hidden">
            <div class="planner-modal-content">
                <div class="planner-modal-header">
                    <h2>다른 여행지로 교체</h2>
                    <button type="button" id="closeReplaceModal" class="planner-modal-close">&times;</button>
                </div>
                <div class="planner-modal-body">
                    <p class="planner-replace-hint">근처 여행지를 선택하세요 (반경 <input type="number" id="replaceRadius" value="10" min="1" max="50" /> km)</p>
                    <div id="replacePlaceList" class="planner-replace-list"></div>
                </div>
            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />

    <script type="application/json" id="initial-plan-data"><c:out value="${empty planDetailsJson ? '[]' : planDetailsJson}" escapeXml="false"/></script>
    <script>window.appContextPath = '${pageContext.request.contextPath}';</script>
    <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=c0f942806f26f0fe25ab08a3eacbea9d&libraries=services"></script>
    <script src="${pageContext.request.contextPath}/js/planner/planner-edit.js"></script>
</body>
</html>
