<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - FAQ 관리</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <div class="admin-page">
        <div class="admin-shell">
            <jsp:include page="/WEB-INF/views/fragments/admin-top-nav.jsp">
                <jsp:param name="activeMenu" value="faq" />
            </jsp:include>

        <%-- 메인 내용 영역 (FAQ 관리) --%>
        <div class="admin-wrapper">
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
        </div>
    </div>
    
</body>
</html>
