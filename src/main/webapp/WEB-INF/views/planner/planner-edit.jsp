<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일정 수정 — #HiFive</title>
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;600;700;800&family=Gmarket+Sans:wght@300;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/routes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/planner/planner.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <div class="page-container">
        <div class="routes-wrap planner-edit-wrap">
            <c:if test="${not empty plannerMessage}">
                <div class="planner-alert planner-alert-ok"><c:out value="${plannerMessage}"/></div>
            </c:if>
            <c:if test="${not empty plannerError}">
                <div class="planner-alert planner-alert-err"><c:out value="${plannerError}"/></div>
            </c:if>

            <form id="plannerEditForm" action="${pageContext.request.contextPath}/planner/${plan.planNo}" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <input type="hidden" id="planDetailsJson" name="planDetailsJson" value="" />

                <div class="routes-header planner-edit-header-wrap">
                    <div class="section-badge">EDIT PLAN</div>
                    <div class="routes-header-row planner-edit-header">
                        <input type="text" class="planner-title-input" id="planTitle" name="planTitle"
                               placeholder="여행 제목" value="<c:out value='${plan.planTitle}'/>" />
                        <a class="btn-cta-outline" href="${pageContext.request.contextPath}/planner">목록</a>
                    </div>
                </div>

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
                    <a href="${pageContext.request.contextPath}/planner" class="btn-cta-outline">목록</a>
                    <button type="submit" id="btnSave" class="planner-btn planner-btn-save">저장</button>
                    <button type="button" id="btnCompleteReview" class="planner-btn planner-btn-complete"><c:choose><c:when test="${hasCompleteReview}">리뷰 수정</c:when><c:otherwise>여행 완료! 리뷰 작성하기</c:otherwise></c:choose></button>
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
                    <div id="searchResults" class="planner-search-results planner-replace-list"></div>
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
                    <div id="replaceMap" class="planner-replace-map hidden"></div>
                    <p class="planner-replace-hint">근처 여행지를 선택하세요 (반경 <input type="number" id="replaceRadius" value="10" min="1" max="50" /> km)</p>
                    <button type="button" id="replaceSearchBtn" class="planner-btn planner-btn-primary">검색</button>
                    <div id="replacePlaceList" class="planner-replace-list"></div>
                </div>
                <div class="planner-modal-footer">
                    <p class="planner-replace-footer-hint">장소를 선택한 뒤 버튼을 눌러 주세요.</p>
                    <button type="button" id="replaceConfirmBtn" class="planner-btn planner-btn-primary" disabled>장소 선택</button>
                </div>
            </div>
        </div>

        <div id="completeReviewModal" class="planner-modal hidden">
            <div class="planner-modal-content planner-complete-review-modal">
                <div class="planner-modal-header">
                    <h2 id="completeReviewModalTitle"><c:choose><c:when test="${hasCompleteReview}">리뷰 수정</c:when><c:otherwise>여행 완료 · 리뷰 작성</c:otherwise></c:choose></h2>
                    <button type="button" id="closeCompleteReviewModal" class="planner-modal-close">&times;</button>
                </div>
                <form id="completeReviewForm" action="${pageContext.request.contextPath}/planner/${plan.planNo}/complete-review" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    <div class="planner-modal-body">
                        <p class="planner-complete-intro">다녀오신 루트를 확인하고 리뷰와 별점을 남겨 주세요. 공개하시면 추천 루트에 등록됩니다.</p>
                        <div class="planner-complete-field">
                            <label for="completeReviewPlanTitle">제목</label>
                            <input type="text" id="completeReviewPlanTitle" name="planTitle" value="<c:out value='${plan.planTitle}'/>" placeholder="여행 제목" class="planner-complete-title-input" />
                        </div>
                        <div class="planner-complete-route">
                            <h3 class="planner-complete-route-title">여행 루트</h3>
                            <div id="completeReviewRouteSummary" class="planner-complete-route-steps"></div>
                        </div>
                        <div class="planner-complete-field">
                            <label for="reviewContent">리뷰</label>
                            <textarea id="reviewContent" name="reviewContent" rows="4" placeholder="여행 후기를 적어 주세요." required><c:out value="${existingReview.reviewContent}"/></textarea>
                        </div>
                        <div class="planner-complete-field">
                            <label>별점</label>
                            <div class="planner-complete-stars" id="completeReviewStars">
                                <input type="radio" name="rating" id="star5" value="5" ${(existingReview == null || existingReview.rating == 5) ? 'checked' : ''} /><label for="star5">★</label>
                                <input type="radio" name="rating" id="star4" value="4" ${existingReview != null && existingReview.rating == 4 ? 'checked' : ''} /><label for="star4">★</label>
                                <input type="radio" name="rating" id="star3" value="3" ${existingReview != null && existingReview.rating == 3 ? 'checked' : ''} /><label for="star3">★</label>
                                <input type="radio" name="rating" id="star2" value="2" ${existingReview != null && existingReview.rating == 2 ? 'checked' : ''} /><label for="star2">★</label>
                                <input type="radio" name="rating" id="star1" value="1" ${existingReview != null && existingReview.rating == 1 ? 'checked' : ''} /><label for="star1">★</label>
                            </div>
                        </div>
                        <div class="planner-complete-field planner-complete-public">
                            <input type="hidden" name="planIsPublic" id="planIsPublicValue" value="${plan.planIsPublic == 'Y' ? 'Y' : 'N'}" />
                            <label><input type="checkbox" id="planIsPublicComplete" value="Y" ${plan.planIsPublic == 'Y' ? 'checked' : ''} /> 공개 (추천 루트에 등록)</label>
                        </div>
                    </div>
                    <div class="planner-modal-footer">
                        <button type="button" id="cancelCompleteReview" class="planner-btn planner-btn-ghost">취소</button>
                        <button type="submit" id="completeReviewSubmitBtn" class="planner-btn planner-btn-primary"><c:choose><c:when test="${hasCompleteReview}">리뷰 수정</c:when><c:otherwise>완료하고 리뷰 등록</c:otherwise></c:choose></button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />

    <script type="application/json" id="initial-plan-data"><c:out value="${empty planDetailsJson ? '[]' : planDetailsJson}" escapeXml="false"/></script>
    <script>window.appContextPath = '${pageContext.request.contextPath}';</script>
    <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=c0f942806f26f0fe25ab08a3eacbea9d&libraries=services"></script>
    <script src="${pageContext.request.contextPath}/js/planner/planner-edit.js"></script>
</body>
</html>
