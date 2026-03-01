<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta name="_csrf" content="${_csrf.token}" />
<meta name="_csrf_header" content="${_csrf.headerName}" />
<meta charset="UTF-8">
<title>관리자 페이지(회원목록)</title>
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

/* 회원 상태에 따른 행 색상 구분 */
.row-normal {
	background-color: #ffffff;
} /* 정상 */
.row-suspended {
	background-color: #fff3cd;
} /* 정지 (연한 노랑) */
.row-deleted {
	background-color: #f8d7da;
} /* 탈퇴 (연한 빨강) */

/* 테이블 스타일 */
.admin-content table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 20px;
	table-layout: fixed; /* 💡 셀 너비 고정 */
}

.admin-content th, .admin-content td {
	border: 1px solid #ddd;
	padding: 10px;
	text-align: center;
	font-size: 14px;
	/* 💡 텍스트 숨김 및 말줄임표 처리 */
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.admin-content th {
	background-color: #f8f9fa;
}

/* 💡 이메일 열 특별 처리 (너비 조정) */
.col-email {
	width: 20%;
}

/* 스타일 추가 예시 */
.badge-master {
	background-color: #e7f0ff;
	color: #007bff;
	padding: 3px 8px;
	border-radius: 4px;
	font-size: 12px;
}

.badge-me {
	background-color: #eee;
	color: #555;
	padding: 3px 8px;
	border-radius: 4px;
	font-size: 12px;
}
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<div class="admin-wrapper">
		<jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

		<div class="admin-content">
			<h1>회원 목록</h1>

			<div class="search-area"
				style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">

				<div class="sort-area">
					<a
						href="?page=${currentPage}&searchType=${searchType}&keyword=${keyword}&orderBy=desc"
						style="text-decoration: none; font-weight: ${orderBy == 'desc' ? 'bold' : 'normal'}; color: ${orderBy == 'desc' ? '#007bff' : '#333'};">최신순</a>
					| <a
						href="?page=${currentPage}&searchType=${searchType}&keyword=${keyword}&orderBy=asc"
						style="text-decoration: none; font-weight: ${orderBy == 'asc' ? 'bold' : 'normal'}; color: ${orderBy == 'asc' ? '#007bff' : '#333'};">오래된순</a>
				</div>

				<form
					action="${pageContext.request.contextPath}/hashTrip/admin/users"
					method="get">
					<select name="searchType">
						<option value="name" ${searchType == 'name' ? 'selected' : ''}>이름</option>
						<option value="nickname"
							${searchType == 'nickname' ? 'selected' : ''}>닉네임</option>
						<option value="email" ${searchType == 'email' ? 'selected' : ''}>이메일</option>
						<option value="phone" ${searchType == 'phone' ? 'selected' : ''}>전화번호</option>
					</select> <input type="text" name="keyword" value="${keyword}"
						placeholder="검색어를 입력하세요"> <input type="hidden"
						name="orderBy" value="${orderBy}">
					<button type="submit">검색</button>
					<%-- 					<a href="${pageContext.request.contextPath}/hashTrip/admin/users" --%>
					<!-- 						style="margin-left: 10px; text-decoration: none; color: inherit;">전체보기</a> -->
				</form>
			</div>

			<table>
				<thead>
					<tr>
						<th style="width: 5%;">No</th>
						<th style="width: 10%;">Type</th>
						<th style="width: 10%;">이름</th>
						<th style="width: 10%;">닉네임</th>
						<th class="col-email">이메일</th>
						<th style="width: 15%;">전화번호</th>
						<th style="width: 8%;">SNS</th>
						<th style="width: 8%;">상태</th>
						<th style="width: 12%;">가입일</th>
					</tr>
				</thead>
				<tbody>
					<c:choose>
						<c:when test="${empty userList}">
							<tr>
								<td colspan="9">등록된 회원이 없습니다.</td>
							</tr>
						</c:when>
						<c:otherwise>
							<c:forEach var="user" items="${userList}">
								<%-- 💡 상태에 따라 클래스명 적용 --%>
								<c:set var="rowClass" value="row-normal" />
								<c:if test="${user.userStatus == '정지'}">
									<c:set var="rowClass" value="row-suspended" />
								</c:if>
								<c:if test="${user.userStatus == '탈퇴'}">
									<c:set var="rowClass" value="row-deleted" />
								</c:if>

								<tr class="${rowClass}">
									<td>${user.userNo}</td>
							<td>
							    <c:choose>
							        <%-- 1. 마스터 관리자(4번)인 행은 수정 불가 --%>
							        <c:when test="${user.userNo == 4}">
							            <span class="badge-master" style="color: blue; font-weight: bold;">마스터</span>
							        </c:when>
							
							        <%-- 2. 나머지 모든 행은 일단 SELECT 박스 노출 --%>
							        <c:otherwise>
							            <select onchange="changeType(${user.userNo}, this.value)">
							                <option value="LOCAL" ${user.userType == 'LOCAL' ? 'selected' : ''}>사용자</option>
							                <option value="ADMIN" ${user.userType == 'ADMIN' ? 'selected' : ''}>관리자</option>
							            </select>
							        </c:otherwise>
							    </c:choose>
							</td>
									<td>${user.userName}</td>
									<td>${user.userNickName}</td>
									<td title="${user.authEmail}">${user.authEmail}</td>
									<td>${user.userPhoneNumber}</td>
									<td>${user.authSnsType}</td>
									<td>${user.userStatus}</td>
									<td>${user.userCreatedAt}</td>
								</tr>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</tbody>
			</table>

			<div class="paging-area"
				style="text-align: center; margin-top: 20px;">
				<c:if test="${currentPage > 1}">
					<a
						href="?page=1&searchType=${searchType}&keyword=${keyword}&orderBy=${orderBy}">[처음]</a>
					<a
						href="?page=${currentPage - 1}&searchType=${searchType}&keyword=${keyword}&orderBy=${orderBy}">[이전]</a>
				</c:if>

				<c:forEach var="i" begin="1" end="${totalPage}">
					<c:choose>
						<c:when test="${i == currentPage}">
							<strong>${i}</strong>
						</c:when>
						<c:otherwise>
							<a
								href="?page=${i}&searchType=${searchType}&keyword=${keyword}&orderBy=${orderBy}">${i}</a>
						</c:otherwise>
					</c:choose>
				</c:forEach>

				<c:if test="${currentPage < totalPage}">
					<a
						href="?page=${currentPage + 1}&searchType=${searchType}&keyword=${keyword}&orderBy=${orderBy}">[다음]</a>
					<a
						href="?page=${totalPage}&searchType=${searchType}&keyword=${keyword}&orderBy=${orderBy}">[끝]</a>
				</c:if>
			</div>

		</div>
	</div>

	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script>
		function changeType(userNo, newType) {
			// CSRF 토큰 정보 가져오기
			var token = $("meta[name='_csrf']").attr("content");
			var header = $("meta[name='_csrf_header']").attr("content");

			$
					.ajax({
						url : "${pageContext.request.contextPath}/hashTrip/admin/updateType",
						type : "POST",
						data : {
							userNo : userNo,
							userType : newType
						},
						beforeSend : function(xhr) {
							// 💡 이 부분이 핵심: 헤더에 CSRF 토큰 추가
							xhr.setRequestHeader(header, token);
						},
						success : function(res) {
							if (res === "success") {
								alert("변경되었습니다.");
							} else {
								alert("권한이 없거나 마스터 계정은 변경할 수 없습니다.");
								location.reload();
							}
						},
						error : function(xhr, status, error) {
							console.log("에러 발생: " + xhr.status); // 403 등이 찍힘
							alert("오류가 발생했습니다.");
						}
					});
		}
	</script>
</body>
</html>