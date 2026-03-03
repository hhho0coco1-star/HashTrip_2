<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
    <main class="auth-page">
    <div class="auth-container signup-container">
        <div class="auth-logo">
            <h1>회원가입</h1>
            <p>필수 정보를 입력하고 가입을 완료해 주세요.</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <p class="auth-message error">${errorMessage}</p>
        </c:if>

        <p class="required-guide"><span class="required-mark">*</span> 항목은 필수항목입니다.</p>

        <form id="signupForm" class="signup-form" action="${pageContext.request.contextPath}/auth/signup" method="post" enctype="multipart/form-data">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <div class="input-group">
                <label>아이디 <span class="required-mark" aria-hidden="true">*</span></label>
                <input type="text" name="userId" maxlength="100" required>
            </div>

            <div class="input-group">
                <label>이메일 <span class="required-mark" aria-hidden="true">*</span></label>
                <input type="email" name="email" maxlength="100" required>
            </div>

            <div class="input-group">
                <label>비밀번호 <span class="required-mark" aria-hidden="true">*</span></label>
                <input id="password" type="password" name="password" minlength="8" maxlength="100" required>
            </div>

            <div class="input-group">
                <label>비밀번호 확인 <span class="required-mark" aria-hidden="true">*</span></label>
                <input id="confirmPassword" type="password" name="confirmPassword" minlength="8" maxlength="100" required>
                <p id="passwordMismatchMessage" class="field-message error" style="display:none;">
                    비밀번호가 일치하지 않습니다.
                </p>
            </div>

            <div class="input-group">
                <label>이름 <span class="required-mark" aria-hidden="true">*</span></label>
                <input type="text" name="userName" maxlength="100" required>
            </div>

            <div class="input-group">
                <label>닉네임 <span class="required-mark" aria-hidden="true">*</span></label>
                <input type="text" name="userNickName" maxlength="20" required>
            </div>

            <div class="input-group">
                <label>연락처 <span class="required-mark" aria-hidden="true">*</span></label>
                <input type="text" name="userPhoneNumber" maxlength="50" placeholder="010-0000-0000" required>
            </div>

            <div class="input-group">
                <label>생년월일 <span class="required-mark" aria-hidden="true">*</span></label>
                <input type="text" name="userRegistrationNo" maxlength="100" placeholder="YYYYMMDD" required>
            </div>

            <div class="input-group full-width">
                <label>프로필 이미지 등록 (선택)</label>
                <input id="signupProfileImage" type="file" name="profileImage" accept="image/*">
                <p class="input-help">이미지 파일만 업로드 가능 (최대 5MB)</p>
                <img id="signupProfilePreview" class="profile-preview" alt="프로필 미리보기">
            </div>

            <div class="input-group">
                <label>성별 (선택)</label>
                <select name="userGender">
                    <option value="">선택 안 함</option>
                    <option value="M">남성</option>
                    <option value="F">여성</option>
                </select>
            </div>

            <div class="input-group">
                <label>우편번호 (선택)</label>
                <input type="text" name="userZipCode" maxlength="6">
            </div>

            <div class="input-group full-width">
                <label>기본 주소 (선택)</label>
                <input type="text" name="userBaseAddress" maxlength="255">
            </div>

            <div class="input-group full-width">
                <label>상세 주소 (선택)</label>
                <input type="text" name="userDetailAddress" maxlength="255">
            </div>

            <button id="signupSubmitBtn" type="submit" class="auth-btn">가입하기</button>
        </form>

        <div class="auth-links">
            <a href="${pageContext.request.contextPath}/auth/login">로그인으로 돌아가기</a>
        </div>
    </div>
    </main>
    <script>
        (function() {
            const input = document.getElementById("signupProfileImage");
            const preview = document.getElementById("signupProfilePreview");
            if (!input || !preview) return;

            input.addEventListener("change", function() {
                const file = input.files && input.files[0];
                if (!file || !file.type || file.type.indexOf("image/") !== 0) {
                    preview.classList.remove("is-show");
                    preview.removeAttribute("src");
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(event) {
                    preview.src = event.target && event.target.result ? String(event.target.result) : "";
                    preview.classList.add("is-show");
                };
                reader.readAsDataURL(file);
            });
        })();
    </script>
    <jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />

    <script>
        (function() {
            var passwordInput = document.getElementById("password");
            var confirmInput = document.getElementById("confirmPassword");
            var mismatchMessage = document.getElementById("passwordMismatchMessage");
            var submitButton = document.getElementById("signupSubmitBtn");
            var signupForm = document.getElementById("signupForm");

            function validatePasswordMatch() {
                var password = passwordInput.value;
                var confirmPassword = confirmInput.value;
                var isMismatch = confirmPassword.length > 0 && password !== confirmPassword;

                mismatchMessage.style.display = isMismatch ? "block" : "none";
                confirmInput.setCustomValidity(isMismatch ? "비밀번호가 일치하지 않습니다." : "");
                submitButton.disabled = isMismatch;
            }

            passwordInput.addEventListener("input", validatePasswordMatch);
            confirmInput.addEventListener("input", validatePasswordMatch);

            signupForm.addEventListener("submit", function(event) {
                validatePasswordMatch();
                if (!signupForm.checkValidity()) {
                    event.preventDefault();
                }
            });
        })();
    </script>
</body>
</html>
