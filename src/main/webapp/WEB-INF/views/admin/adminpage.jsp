<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
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
                    <h1>관리자 대시보드</h1>
                    <p>상단 메뉴에서 관리 항목을 선택해 주세요.</p>
                </div>
            </div>
        </div>
    </div>

</body>
</html>