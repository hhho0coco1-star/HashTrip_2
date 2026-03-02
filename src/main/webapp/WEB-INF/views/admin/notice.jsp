<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 공지사항 관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
<style>
    /* 기존 스타일 유지 */
    .admin-wrapper { display: flex; min-height: 100vh; }
    .admin-sidebar { width: 250px; background-color: #f8f9fa; padding: 20px; border-right: 1px solid #ddd; }
    .admin-content { flex: 1; padding: 20px; }
    .admin-sidebar ul { list-style: none; padding: 0; }
    .admin-sidebar ul li { margin-bottom: 15px; }
    .admin-sidebar ul li a { text-decoration: none; color: #333; font-weight: bold; }
    .admin-sidebar ul li a:hover { color: #007bff; }
    
    /* 공지사항 관리 테이블 스타일 */
    .notice-table { width: 100%; border-collapse: collapse; margin-top: 20px; table-layout: fixed; }
    .notice-table th, .notice-table td { border: 1px solid #ddd; padding: 12px; text-align: center; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .notice-table th { background-color: #f4f4f4; }
    
    /* 컬럼 너비 */
    .col-no { width: 8%; }
    .col-title { width: 45%; text-align: left; }
    .col-date { width: 15%; }
    .col-view { width: 10%; }
    .col-action { width: 22%; }
    
    .btn { padding: 6px 12px; text-decoration: none; border-radius: 4px; font-size: 13px; display: inline-block; }
    .btn-edit { background-color: #ffc107; color: #333; }
    .btn-delete { background-color: #dc3545; color: white; }
    .btn-register { background-color: #28a745; color: white; padding: 10px 15px; float: right; margin-bottom: 15px; text-decoration: none; border-radius: 4px; }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
    
    <div class="admin-wrapper">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

        <div class="admin-content">
            <h1>공지사항 관리</h1>
            <a href="${pageContext.request.contextPath}/admin/notice/registerForm" class="btn-register">새 공지 등록</a>
            
            <table class="notice-table">
                <thead>
                    <tr>
                        <th class="col-no">번호</th>
                        <th class="col-title">제목</th>
                        <th class="col-date">작성일</th>
                        <th class="col-view">조회수</th>
                        <th class="col-action">관리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="notice" items="${noticeList}">
                        <tr>
                            <td>${notice.noticeNo}</td>
                            <td class="col-title" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${notice.title}</td>
                            <td><fmt:formatDate value="${notice.createdAt}" pattern="yyyy-MM-dd" /></td>
                            <td>${notice.viewCount}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/notice/modify?noticeNo=${notice.noticeNo}" class="btn btn-edit">수정</a>
                                <a href="${pageContext.request.contextPath}/admin/notice/remove?noticeNo=${notice.noticeNo}" 
                                   class="btn btn-delete" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty noticeList}">
                        <tr>
                            <td colspan="5">등록된 공지사항이 없습니다.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    
</body>
</html>