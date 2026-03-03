<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 공지사항 수정</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin.css">
</head>
<body>

    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

    <div class="admin-page">
        <div class="admin-shell">
            <jsp:include page="/WEB-INF/views/fragments/admin-top-nav.jsp">
                <jsp:param name="activeMenu" value="notice" />
            </jsp:include>

            <div class="admin-wrapper">
                <div class="admin-content">
                    <h1>공지사항 수정</h1>

                    <form class="admin-form" action="${pageContext.request.contextPath}/admin/notice/modify" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="noticeNo" value="${notice.noticeNo}">

                        <div class="form-group">
                            <label>제목</label>
                            <input type="text" name="title" class="form-control" value="${notice.title}" required>
                        </div>
                        <div class="form-group">
                            <label>내용</label>
                            <textarea name="content" class="form-control" required>${notice.content}</textarea>
                        </div>

                        <button type="submit" class="btn btn-edit">수정하기</button>
                        <a href="${pageContext.request.contextPath}/hashTrip/admin/notice" class="btn btn-cancel">취소</a>
                    </form>
                </div>
            </div>
        </div>
    </div>

</body>
</html>