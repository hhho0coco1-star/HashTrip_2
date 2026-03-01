<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<nav class="admin-sidebar">
    <h3>관리 메뉴</h3>
    <ul>
        <li><a href="${pageContext.request.contextPath}/hashTrip/admin/users">회원 목록</a></li>
        <li><a href="${pageContext.request.contextPath}/hashTrip/admin/inquiry">1:1 문의</a></li>
        <li><a href="${pageContext.request.contextPath}/hashTrip/admin/faq">자주 묻는 질문</a></li>
        <li><a href="${pageContext.request.contextPath}/hashTrip/admin/notice">공지사항</a></li>
    </ul>
</nav>