<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<nav class="main-header">
    <div class="header-container">
        <a class="header-logo" href="/hashTrip">
            <strong style="color: #007bff;">#Trip</strong>
        </a>

        <div class="header-menu-wrapper">
            <ul class="nav-menu">
                <li><a href="/hashTrip">홈</a></li>
                <li><a href="/test1">추천 루트</a></li>
                <li><a href="/test2">여행 일정</a></li>
                <li><a href="/test3">마이페이지</a></li>
            </ul>

            <div class="user-auth">
                <c:choose>
                    <c:when test="${empty sessionScope.loginUser}">
                        <a href="/login" class="btn-login">로그인</a>
                        <a href="/signup" class="btn-signup">회원가입</a>
                    </c:when>
                    <c:otherwise>
                        <span class="user-info">
                            <strong>${sessionScope.loginUser.user_nickName}</strong>님 환영합니다!
                        </span>
                        <a href="/logout" class="btn-logout">로그아웃</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>