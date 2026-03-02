<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 공지사항 수정</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
<style>
    /* ... 등록 폼과 동일한 스타일 ... */
    .admin-wrapper { display: flex; min-height: 100vh; }
    .admin-sidebar { width: 250px; background-color: #f8f9fa; padding: 20px; border-right: 1px solid #ddd; }
    .admin-content { flex: 1; padding: 20px; }
    .admin-sidebar ul { list-style: none; padding: 0; }
    .admin-sidebar ul li { margin-bottom: 15px; }
    .admin-sidebar ul li a { text-decoration: none; color: #333; font-weight: bold; }
    .admin-sidebar ul li a:hover { color: #007bff; }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: bold; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
    textarea.form-control { height: 300px; resize: vertical; }
    .btn-submit { background-color: #ffc107; color: #333; border: none; padding: 12px 20px; border-radius: 4px; cursor: pointer; font-size: 16px; }
    .btn-cancel { background-color: #6c757d; color: white; padding: 12px 20px; border-radius: 4px; text-decoration: none; }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
    
    <div class="admin-wrapper">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

        <div class="admin-content">
            <h1>공지사항 수정</h1>
            
            <form action="${pageContext.request.contextPath}/admin/notice/modify" method="post">
                <%-- CSRF 토큰 --%>
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <%-- 수정 시 필수: PK 값 --%>
                <input type="hidden" name="noticeNo" value="${notice.noticeNo}">
                
                <div class="form-group">
                    <label>제목</label>
                    <input type="text" name="title" class="form-control" value="${notice.title}" required>
                </div>
                <div class="form-group">
                    <label>내용</label>
                    <textarea name="content" class="form-control" required>${notice.content}</textarea>
                </div>
                
                <button type="submit" class="btn-submit">수정하기</button>
                <a href="${pageContext.request.contextPath}/admin/notice/management" class="btn-cancel">취소</a>
            </form>
        </div>
    </div>
    
</body>
</html>