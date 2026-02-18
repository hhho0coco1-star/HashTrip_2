<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>추가 정보 입력</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
</head>
<body>

    <div class="auth-container">
        <div class="auth-logo">
            <h1>추가 정보 입력</h1>
            <p>소셜 로그인 계정은 연락처와 생년월일 입력이 필요합니다.</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <p class="auth-message error">${errorMessage}</p>
        </c:if>

        <form action="${pageContext.request.contextPath}/mypage/additional-info" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <div class="input-group">
                <label>연락처 (필수)</label>
                <input type="text" name="userPhoneNumber" maxlength="50"
                    placeholder="010-0000-0000" value="${userPhoneNumber}" required>
            </div>

            <div class="input-group">
                <label>생년월일 (필수)</label>
                <input type="date" name="birthDate" value="${birthDate}" required>
            </div>

            <button type="submit" class="auth-btn">저장하기</button>
        </form>
    </div>

</body>
</html>
