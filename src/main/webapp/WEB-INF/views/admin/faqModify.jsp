<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - FAQ 수정</title>
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

            <div class="admin-wrapper">
                <div class="admin-content">
                    <h1>FAQ 수정</h1>

                    <form class="admin-form" action="${pageContext.request.contextPath}/admin/faq/modify" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="faqNo" value="${faq.faqNo}">

                        <div class="form-group">
                            <label>카테고리</label>
                            <input type="text" name="category" value="${faq.category}" required>
                        </div>
                        <div class="form-group">
                            <label>질문</label>
                            <input type="text" name="question" value="${faq.question}" required>
                        </div>
                        <div class="form-group">
                            <label>답변</label>
                            <textarea name="answer" required>${faq.answer}</textarea>
                        </div>
                        <div class="form-group">
                            <label>노출 순서</label>
                            <input type="number" name="orderNo" value="${faq.orderNo}">
                        </div>
                        <button type="submit" class="btn btn-edit">수정하기</button>
                        <a href="${pageContext.request.contextPath}/hashTrip/admin/faq" class="btn btn-cancel">취소</a>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>