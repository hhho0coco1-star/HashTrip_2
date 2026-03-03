<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 1:1 문의 관리</title>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<div class="admin-page">
		<div class="admin-shell">
			<jsp:include page="/WEB-INF/views/fragments/admin-top-nav.jsp">
				<jsp:param name="activeMenu" value="inquiry" />
			</jsp:include>

		<div class="admin-wrapper">
			<div class="admin-content">
			<h1>1:1 문의 내역</h1>

			<form
				action="${pageContext.request.contextPath}/hashTrip/admin/inquiry"
				method="get" class="search-form">
				<div class="form-row">
					<div class="form-group">
						<label for="searchCategory">문의 유형 : </label> <select
							id="searchCategory" name="inquiryType">
							<option value="">전체</option>
							<option value="서비스"
								${param.inquiryType == '서비스' ? 'selected' : ''}>서비스 이용
								문의</option>
							<option value="계정/로그인"
								${param.inquiryType == '계정/로그인' ? 'selected' : ''}>계정/로그인
								관련</option>
							<option value="오류" ${param.inquiryType == '오류' ? 'selected' : ''}>오류
								제보</option>
							<option value="제휴" ${param.inquiryType == '제휴' ? 'selected' : ''}>제휴
								및 건의사항</option>
							<option value="기타" ${param.inquiryType == '기타' ? 'selected' : ''}>기타</option>
						</select>
					</div>

					<div class="form-group">
						<label for="searchStatus">처리 상태 : </label> <select id="searchStatus"
							name="status">
							<option value="">전체</option>
							<option value="N" ${param.status == 'N' ? 'selected' : ''}>대기</option>
							<option value="Y" ${param.status == 'Y' ? 'selected' : ''}>완료</option>
						</select>
					</div>

					<div class="form-group">
						<label for="searchType">검색 조건 : </label> <select name="searchType">
							<option value="title"
								${param.searchType == 'title' ? 'selected' : ''}>제목</option>
							<option value="authId"
								${param.searchType == 'authId' ? 'selected' : ''}>아이디</option>
						</select> <input type="text" name="keyword" value="${param.keyword}"
							placeholder="검색어를 입력하세요">
						<button type="submit" class="btn-search">검색</button>
					</div>
				</div>
			</form>

			<table>
				<thead>
					<tr>
						<th class="col-no">No</th>
						<th class="col-inquiry-type">문의유형</th>
						<th class="col-title">제목</th>
						<th class="col-writer">작성자</th>
						<th class="col-auth-id">아이디</th>
						<th class="col-inquiry-date">문의일</th>
						<th class="col-state">상태</th>
						<th class="col-reply-date">답변일</th>
					</tr>
				</thead>
				<tbody>
					<c:choose>
						<c:when test="${empty inquiryList}">
							<tr>
								<td colspan="8">문의 내역이 없습니다.</td>
							</tr>
						</c:when>
						<c:otherwise>
							<c:forEach var="inquiry" items="${inquiryList}">
								<tr>
									<td>${inquiry.inquiryNo}</td>
									<td>${inquiry.inquiryType}</td>
									<td class="text-left"><a href="javascript:void(0);"
										onclick="toggleDetail('${inquiry.inquiryNo}')">
											${inquiry.inquiryTitle} </a></td>
									<td>${inquiry.userName}</td>
									<td>${inquiry.userAuthId}</td>
									<td><fmt:formatDate value="${inquiry.inquiryDate}"
											pattern="yyyy-MM-dd HH:mm" /></td>
									<td><c:choose>
											<c:when test="${inquiry.status == 'Y'}">
												<span class="status-badge status-completed">완료</span>
											</c:when>
											<c:when test="${inquiry.status == 'N'}">
												<span class="status-badge status-pending">대기</span>
											</c:when>
											<c:otherwise>
												<span class="status-badge">${inquiry.status}</span>
											</c:otherwise>
										</c:choose></td>
									<td><c:if test="${not empty inquiry.replyDate}">
											<fmt:formatDate value="${inquiry.replyDate}"
												pattern="yyyy-MM-dd HH:mm" />
										</c:if> <c:if test="${empty inquiry.replyDate}">-</c:if></td>
								</tr>

								<tr id="detail-${inquiry.inquiryNo}" class="inquiry-detail-row">
									<td colspan="8" class="inquiry-detail-cell">
										<div id="detailBody-${inquiry.inquiryNo}">로딩 중...</div>
									</td>
								</tr>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</tbody>
			</table>
			</div>
		</div>
		</div>
	</div>

	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script type="text/javascript">
		// 💡 모달 함수 대신 아코디언 함수 사용
		function toggleDetail(inquiryNo) {
			let $detailRow = $('#detail-' + inquiryNo);
			let $detailBody = $('#detailBody-' + inquiryNo);

			// 이미 열려있으면 닫기
			if ($detailRow.is(':visible')) {
				$detailRow.hide();
				return;
			}

			// AJAX 호출하여 상세 데이터 가져오기
			$
					.ajax({
						url : '${pageContext.request.contextPath}/admin/inquiry/detail',
						type : 'GET',
						data : {
							inquiryNo : inquiryNo
						},
						success : function(htmlData) {
							// 💡 받은 HTML 데이터를 바로 적용
							$detailBody.html(htmlData);
							$detailRow.show();
						}
					});
		}

		$(function() {
			const openInquiryNo = '${openInquiryNo}';
			if (openInquiryNo) {
				toggleDetail(openInquiryNo);
			}
		});
	</script>

</body>
</html>
