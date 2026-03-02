<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - FAQ 등록</title>
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
    
    /* 폼 스타일 */
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
    .form-group input, .form-group textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
    .form-group textarea { height: 150px; resize: none; }
    .btn-submit { background-color: #007bff; color: white; border: none; padding: 10px 15px; border-radius: 4px; cursor: pointer; }
    
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
    
    <div class="admin-wrapper">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

        <div class="admin-content">
            <h1>FAQ 등록</h1>
            
            <form action="${pageContext.request.contextPath}/admin/faq/register" method="post">
            	<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <div class="form-group">
                    <label>카테고리</label>
                    <input type="text" name="category" required placeholder="예: 서비스 이용">
                </div>
                <div class="form-group">
                    <label>질문</label>
                    <input type="text" name="question" required>
                </div>
                <div class="form-group">
                    <label>답변</label>
                    <textarea name="answer" required></textarea>
                </div>
                <div class="form-group">
                    <label>노출 순서</label>
                    <input type="number" name="orderNo" value="0">
                </div>
                <button type="submit" class="btn-submit">등록하기</button>
                <a href="${pageContext.request.contextPath}/hashTrip/admin/faq"
                style="margin-left: 10px; text-decoration: none">목록으로</a>
            </form>
        </div>
    </div>
    
</body>
</html>