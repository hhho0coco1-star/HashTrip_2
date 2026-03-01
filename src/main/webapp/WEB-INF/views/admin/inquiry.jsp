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
<style>
/* 관리자 페이지 레이아웃 스타일 */
.admin-wrapper {
	display: flex;
	min-height: 100vh;
}

.admin-sidebar {
	width: 250px;
	background-color: #f8f9fa;
	padding: 20px;
	border-right: 1px solid #ddd;
}

.admin-content {
	flex: 1;
	padding: 20px;
}

.admin-sidebar ul {
	list-style: none;
	padding: 0;
}

.admin-sidebar ul li {
	margin-bottom: 15px;
}

.admin-sidebar ul li a {
	text-decoration: none;
	color: #333;
	font-weight: bold;
}

.admin-sidebar ul li a:hover {
	color: #007bff;
}

/* 문의 테이블 스타일 */
.admin-content table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 20px;
	table-layout: fixed; /* 셀 너비 고정 */
}

.admin-content th, .admin-content td {
	border: 1px solid #ddd;
	padding: 12px;
	text-align: center;
	font-size: 14px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.admin-content th {
	background-color: #f8f9fa;
}

/* 상태별 배지 스타일 */
.status-badge {
	padding: 5px 10px;
	border-radius: 4px;
	font-size: 12px;
	font-weight: bold;
}

.status-pending {
	background-color: #ffeeba;
	color: #856404;
} /* 대기 */
.status-completed {
	background-color: #d4edda;
	color: #155724;
} /* 완료 */
</style>
</head>
<body>

	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<div class="admin-wrapper">
		<%-- 관리자 전용 메뉴바 (사이드바) --%>
		<jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

		<div class="admin-content">
			<h1>1:1 문의 내역</h1>

			<form action="${pageContext.request.contextPath}/hashTrip/admin/inquiry"
				method="get" class="search-form">
				<div class="form-row">
					<div class="form-group">
						<label for="searchCategory">문의 유형</label> <select
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
						<label for="searchStatus">처리 상태</label> <select id="searchStatus"
							name="status">
							<option value="">전체</option>
							<option value="N" ${param.status == 'N' ? 'selected' : ''}>대기</option>
							<option value="Y" ${param.status == 'Y' ? 'selected' : ''}>완료</option>
						</select>
					</div>

					<div class="form-group">
						<label for="searchType">검색 조건</label> <select name="searchType">
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
						<th style="width: 5%;">No</th>
						<th style="width: 10%;">문의유형</th>
						<th style="width: 15%;">제목</th>
						<th style="width: 10%;">작성자</th>
						<th style="width: 10%;">아이디</th>
						<th style="width: 15%;">문의일</th>
						<th style="width: 10%;">상태</th>
						<th style="width: 15%;">답변일</th>
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
									<td
										style="text-align: left; overflow: hidden; text-overflow: ellipsis;">
										<a
										href="${pageContext.request.contextPath}/admin/inquiry/detail?no=${inquiry.inquiryNo}">
											${inquiry.inquiryTitle} </a>
									</td>
									<td>${inquiry.userName}</td>
									<td>${inquiry.userAuthId}</td>
									<td><fmt:formatDate value="${inquiry.inquiryDate}"
											pattern="yyyy-MM-dd HH:mm" /></td>
									<td><span
										class="status-badge ${inquiry.status == '완료' ? 'status-completed' : 'status-pending'}">
											${inquiry.status} </span></td>
									<td><c:if test="${not empty inquiry.replyDate}">
											<fmt:formatDate value="${inquiry.replyDate}"
												pattern="yyyy-MM-dd HH:mm" />
										</c:if> <c:if test="${empty inquiry.replyDate}">-</c:if></td>
								</tr>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</tbody>
			</table>
		</div>
	</div>

</body>
</html>