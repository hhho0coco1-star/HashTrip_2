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
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<div class="admin-page">
		<div class="admin-shell">
			<jsp:include page="/WEB-INF/views/fragments/admin-top-nav.jsp">
				<jsp:param name="activeMenu" value="users" />
			</jsp:include>

		<div class="admin-wrapper">
		<div class="admin-content">
			<h1>회원 목록</h1>

			<div class="search-area">

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
				</form>

				<div class="sort-area">
					<a class="sort-link ${orderBy == 'desc' ? 'is-active' : ''}"
						href="?page=${currentPage}&searchType=${searchType}&keyword=${keyword}&orderBy=desc">최신순</a>
					<span class="sort-divider">|</span>
					<a class="sort-link ${orderBy == 'asc' ? 'is-active' : ''}"
						href="?page=${currentPage}&searchType=${searchType}&keyword=${keyword}&orderBy=asc">오래된순</a>
				</div>

			</div>

			<table>
				<thead>
					<tr>
						<th class="col-no">No</th>
						<th class="col-type">Type</th>
						<th class="col-name">이름</th>
						<th class="col-nick">닉네임</th>
						<th class="col-email">이메일</th>
						<th class="col-phone">전화번호</th>
						<th class="col-sns">SNS</th>
						<th class="col-status">상태</th>
						<th class="col-date">가입일</th>
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
									<td><c:choose>
											<%-- 1. MASTER 계정은 수정 불가 --%>
											<c:when test="${user.userType == 'MASTER'}">
												<span class="badge-master">마스터</span>
											</c:when>

											<%-- 2. 로그인 사용자가 MASTER일 때만 사용자/관리자 전환 가능 --%>
											<c:when test="${canChangeUserType}">
												<select onchange="changeType(${user.userNo}, this.value)">
													<option value="LOCAL"
														${user.userType == 'LOCAL' ? 'selected' : ''}>사용자</option>
													<option value="ADMIN"
														${user.userType == 'ADMIN' ? 'selected' : ''}>관리자</option>
												</select>
											</c:when>

											<%-- 3. MASTER가 아닌 관리자는 조회만 가능 --%>
											<c:otherwise>
												<c:choose>
													<c:when test="${user.userType == 'ADMIN'}">
														<span>관리자</span>
													</c:when>
													<c:otherwise>
														<span>사용자</span>
													</c:otherwise>
												</c:choose>
											</c:otherwise>
										</c:choose></td>
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

			<div class="paging-area">
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
