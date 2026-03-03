<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="requestUri" value="${pageContext.request.requestURI}" />
<c:set var="currentPath" value="${fn:substringAfter(requestUri, ctx)}" />
<c:set var="isAdminRole" value="${headerCanAdmin eq true}" />

<c:set var="homeActive" value="" />
<c:if test="${empty currentPath or currentPath eq '/' or currentPath eq '/main' or currentPath eq '/hashTrip'}">
    <c:set var="homeActive" value="is-active" />
</c:if>

<c:set var="routesActive" value="" />
<c:if test="${fn:startsWith(currentPath, '/routes')}">
    <c:set var="routesActive" value="is-active" />
</c:if>

<c:set var="planActive" value="" />
<c:if test="${fn:startsWith(currentPath, '/planner') or fn:startsWith(currentPath, '/plan')}">
    <c:set var="planActive" value="is-active" />
</c:if>

<c:set var="mypageActive" value="" />
<c:if test="${fn:startsWith(currentPath, '/mypage')}">
    <c:set var="mypageActive" value="is-active" />
</c:if>

<c:set var="adminActive" value="" />
<c:if test="${fn:startsWith(currentPath, '/hashTrip/admin') or fn:startsWith(currentPath, '/admin')}">
    <c:set var="adminActive" value="is-active" />
</c:if>

<nav class="main-header">
    <div class="header-container">
        <a class="header-logo" href="<c:url value='/hashTrip' />">
            <strong>#Trip</strong>
        </a>

        <div class="header-menu-wrapper">
            <ul class="nav-menu">
                <li>
                    <a href="<c:url value='/hashTrip' />" class="${homeActive}">홈</a>
                </li>
                <li>
                    <a href="<c:url value='/routes' />" class="${routesActive}">추천 루트</a>
                </li>
                <li>
                    <a href="<c:url value='/planner' />" class="${planActive}">여행 일정</a>
                </li>
                <li>
                    <a href="<c:url value='/mypage' />" class="${mypageActive}">마이페이지</a>
                </li>
                <c:if test="${isAdminRole}">
                    <li>
                        <a href="<c:url value='/hashTrip/admin' />" class="${adminActive}">관리자 페이지</a>
                    </li>
                </c:if>
            </ul>

            <div class="user-auth">
                <c:choose>
                    <c:when test="${pageContext.request.userPrincipal == null}">
                        <a href="<c:url value='/auth/login' />" class="btn-login">로그인</a>
                        <a href="<c:url value='/auth/signup' />" class="btn-signup">회원가입</a>
                    </c:when>
                    <c:otherwise>
                        <span class="user-info">
                            <strong><c:out value="${empty headerDisplayName ? pageContext.request.userPrincipal.name : headerDisplayName}" /></strong>님 환영합니다.
                        </span>
                        <form class="logout-form" action="<c:url value='/auth/logout' />" method="post">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <button type="submit" class="btn-logout">로그아웃</button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
