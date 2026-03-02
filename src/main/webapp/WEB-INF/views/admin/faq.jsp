<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - FAQ 관리</title>
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
    
    /* FAQ 관리 특화 스타일 */
    .faq-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    .faq-table th, .faq-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    .faq-table th { background-color: #f4f4f4; }
    .btn { padding: 5px 10px; text-decoration: none; border-radius: 4px; font-size: 14px; }
    .btn-edit { background-color: #ffc107; color: #333; }
    .btn-delete { background-color: #dc3545; color: white; }
    .btn-register { background-color: #28a745; color: white; padding: 10px 15px; float: right; margin-bottom: 10px; }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
    
    <div class="admin-wrapper">
        <%-- 사이드바 --%>
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

        <%-- 메인 내용 영역 (FAQ 관리) --%>
        <div class="admin-content">
            <h1>FAQ 관리</h1>
            <a href="${pageContext.request.contextPath}/admin/faq/registerForm" class="btn btn-register">새 질문 등록</a>
            
            <table class="faq-table">
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>카테고리</th>
                        <th>질문</th>
                        <th>순서</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="faq" items="${faqList}">
                        <tr>
                            <td>${faq.faqNo}</td>
                            <td>${faq.category}</td>
                            <td>${faq.question}</td>
                            <td>${faq.orderNo}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/faq/modify?faqNo=${faq.faqNo}" class="btn btn-edit">수정</a>
                                <a href="${pageContext.request.contextPath}/admin/faq/remove?faqNo=${faq.faqNo}" 
                                   class="btn btn-delete" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
</body>
</html>