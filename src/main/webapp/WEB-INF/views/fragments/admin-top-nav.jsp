<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<nav class="admin-top-nav" aria-label="관리자 메뉴">
    <div class="admin-top-nav-inner">
        <a href="${pageContext.request.contextPath}/hashTrip/admin/users"
           class="admin-top-nav-link ${param.activeMenu == 'users' ? 'is-active' : ''}">
            회원관리
        </a>
        <a href="${pageContext.request.contextPath}/hashTrip/admin/inquiry"
           class="admin-top-nav-link ${param.activeMenu == 'inquiry' ? 'is-active' : ''}">
            1:1 문의
        </a>
        <a href="${pageContext.request.contextPath}/hashTrip/admin/faq"
           class="admin-top-nav-link ${param.activeMenu == 'faq' ? 'is-active' : ''}">
            FAQ
        </a>
        <a href="${pageContext.request.contextPath}/hashTrip/admin/notice"
           class="admin-top-nav-link ${param.activeMenu == 'notice' ? 'is-active' : ''}">
            공지사항
        </a>
    </div>
</nav>
