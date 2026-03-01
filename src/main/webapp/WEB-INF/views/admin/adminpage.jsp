<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
	<style>
        /* 관리자 페이지 레이아웃 스타일 */
        .admin-wrapper { display: flex; min-height: 100vh; }
        .admin-sidebar { width: 250px; background-color: #f8f9fa; padding: 20px; border-right: 1px solid #ddd; }
        .admin-content { flex: 1; padding: 20px; }
        .admin-sidebar ul { list-style: none; padding: 0; }
        .admin-sidebar ul li { margin-bottom: 15px; }
        .admin-sidebar ul li a { text-decoration: none; color: #333; font-weight: bold; }
        .admin-sidebar ul li a:hover { color: #007bff; }
    </style>
</head>
<body>

	<!-- 헤더바 -->
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<!-- 헤더바 -->
	
	<div class="admin-wrapper">
        <%-- 관리자 전용 메뉴바 (사이드바) --%>
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

        <%-- 메인 내용 영역 --%>
        <div class="admin-content">
            <h1>관리자 대시보드</h1>
            <p>원하는 메뉴를 선택해주세요.</p>
        </div>
    </div>
    
</body>
</html>