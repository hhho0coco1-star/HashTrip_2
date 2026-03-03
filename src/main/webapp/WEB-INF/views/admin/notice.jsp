<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 공지사항 관리</title>
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
                    <h1>공지사항 관리</h1>
                    <a href="${pageContext.request.contextPath}/admin/notice/registerForm" class="btn btn-register">새 공지 등록</a>

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
                                    <td class="col-title">${notice.title}</td>
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
        </div>
    </div>

</body>
</html>