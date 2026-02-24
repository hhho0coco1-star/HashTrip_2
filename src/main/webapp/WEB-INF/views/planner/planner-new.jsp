<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_parameter" content="${_csrf.parameterName}"/>
    <title>새 여행 만들기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/planner/planner.css">
</head>
<body class="planner-new-body">
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <main class="planner-new-shell">
        <div class="planner-new-wrap">
            <h1 class="planner-new-title">새 여행 만들기</h1>

            <c:if test="${not empty plannerError}">
                <div class="planner-alert planner-alert-err"><c:out value="${plannerError}"/></div>
            </c:if>

            <form id="plannerNewForm" action="${pageContext.request.contextPath}/planner" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <input type="hidden" id="planDetailsJson" name="planDetailsJson" value="" />
                <input type="hidden" id="planStartDate" name="planStartDate" value="" />
                <input type="hidden" id="planEndDate" name="planEndDate" value="" />

                <div id="wizardSteps" class="planner-wizard">
                    <%-- Step 1: 어떻게 만들까요? --%>
                    <div id="step1Panel" class="planner-wizard-panel planner-wizard-active">
                        <section class="planner-section planner-step planner-question-card">
                            <h2 class="planner-step-title">어떻게 만들까요?</h2>
                            <div class="planner-option-group planner-option-cards">
                                <label class="planner-option-card">
                                    <input type="radio" name="createMode" value="route" checked />
                                    <span class="planner-option-card-inner">루트 추천 받기</span>
                                </label>
                                <label class="planner-option-card">
                                    <input type="radio" name="createMode" value="direct" />
                                    <span class="planner-option-card-inner">직접 장소 추가</span>
                                </label>
                            </div>
                            <div class="planner-wizard-nav">
                                <button type="button" id="btnStep1Next" class="planner-btn planner-btn-primary">다음</button>
                            </div>
                        </section>
                    </div>

                    <%-- Step 2 (route only): 어떤 태그로 검색할까요? --%>
                    <div id="step2Panel" class="planner-wizard-panel hidden">
                        <section class="planner-section planner-step planner-question-card">
                            <h2 class="planner-step-title">어떤 태그로 검색할까요?</h2>
                            <div class="planner-option-group planner-option-cards">
                                <label class="planner-option-card">
                                    <input type="radio" name="tagMode" value="myTags" checked />
                                    <span class="planner-option-card-inner">나의 태그로 검색</span>
                                </label>
                                <label class="planner-option-card planner-option-disabled" title="준비 중입니다. 곧 이용하실 수 있어요.">
                                    <input type="radio" name="tagMode" value="newTags" disabled />
                                    <span class="planner-option-card-inner">새로운 태그로 검색 <span class="planner-option-badge">준비 중</span></span>
                                </label>
                            </div>
                            <p class="planner-tooltip-hint">나의 태그는 마이페이지에서 설정한 취향 태그로, 맞는 루트를 추천받을 수 있어요.</p>
                            <div class="planner-wizard-nav">
                                <button type="button" id="btnStep2Prev" class="planner-btn planner-btn-ghost">이전</button>
                                <button type="button" id="btnStep2Next" class="planner-btn planner-btn-primary">다음</button>
                            </div>
                        </section>
                    </div>

                    <%-- Step 3 (route only): 어디로 갈까요? --%>
                    <div id="step3Panel" class="planner-wizard-panel hidden">
                        <section class="planner-section planner-step planner-question-card">
                            <h2 class="planner-step-title">어디로 갈까요?</h2>
                            <p class="planner-hint">선택한 장소 태그와 맞는 루트를 우선해서 보여드려요.</p>
                            <div class="planner-tag-list" id="placeTagList">
                                <c:forEach var="tag" items="${placeTagList}">
                                    <label class="planner-tag-chip">
                                        <input type="checkbox" name="placeTag" value="${tag.tagCode}" data-name="${tag.tagName}" />
                                        <span><c:out value="${tag.tagName}"/></span>
                                    </label>
                                </c:forEach>
                            </div>
                            <div class="planner-wizard-nav">
                                <button type="button" id="btnStep3Prev" class="planner-btn planner-btn-ghost">이전</button>
                                <button type="button" id="btnSearchRoutes" class="planner-btn planner-btn-primary">추천 루트 보기</button>
                            </div>
                            <a href="${pageContext.request.contextPath}/routes" class="planner-link-inline" target="_blank">전체 루트 둘러보기</a>
                            <div id="routeResultArea" class="planner-route-result hidden"></div>
                        </section>
                    </div>

                    <%-- Direct path: 장소 추가 --%>
                    <div id="directPanel" class="planner-wizard-panel hidden">
                        <section class="planner-section planner-step planner-question-card">
                            <h2 class="planner-step-title">장소 추가</h2>
                            <button type="button" id="btnAddPlace" class="planner-btn planner-btn-primary">장소 검색해서 추가</button>
                            <div id="placeList" class="planner-place-list"></div>
                            <div class="planner-wizard-nav">
                                <button type="button" id="btnDirectPrev" class="planner-btn planner-btn-ghost">이전</button>
                            </div>
                        </section>
                    </div>
                </div>

                <section class="planner-section planner-actions">
                    <a href="${pageContext.request.contextPath}/planner" class="planner-btn planner-btn-ghost">목록</a>
                    <button type="submit" id="btnSaveNew" class="planner-btn planner-btn-save hidden" disabled>일정 저장</button>
                </section>
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
    </main>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />

    <script>window.appContextPath = '${pageContext.request.contextPath}';</script>
    <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=c0f942806f26f0fe25ab08a3eacbea9d&libraries=services"></script>
    <script src="${pageContext.request.contextPath}/js/planner/planner-new.js"></script>
</body>
</html>
