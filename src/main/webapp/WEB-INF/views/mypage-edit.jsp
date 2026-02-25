<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>회원정보 수정</title>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
</head>
<body>
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

	<div class="mypage-edit-wrap">
		<section class="edit-card">
			<div class="edit-card-head">
				<h1>회원정보 수정</h1>
				<p>프로필 정보를 최신 상태로 유지해 주세요.</p>
			</div>

			<c:if test="${not empty message}">
				<div class="alert success"><c:out value="${message}" /></div>
			</c:if>
			<c:if test="${not empty errorMessage}">
				<div class="alert error"><c:out value="${errorMessage}" /></div>
			</c:if>

			<form class="edit-form-grid" method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/mypage/edit">
				<c:if test="${not empty _csrf}">
					<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
				</c:if>

				<c:set var="profileImageUrl" value="${usersDTO.userProfileImg}" />
				<c:if test="${not empty profileImageUrl and fn:startsWith(profileImageUrl, '/')}">
					<c:choose>
						<c:when test="${not empty pageContext.request.contextPath and pageContext.request.contextPath ne '/' and !fn:startsWith(profileImageUrl, pageContext.request.contextPath)}">
							<c:set var="profileImageUrl" value="${pageContext.request.contextPath}${profileImageUrl}" />
						</c:when>
						<c:otherwise>
							<c:set var="profileImageUrl" value="${profileImageUrl}" />
						</c:otherwise>
					</c:choose>
				</c:if>

				<c:if test="${not empty profileImageUrl}">
					<div class="edit-field full profile-preview-group">
						<label>현재 프로필 사진</label>
						<img id="currentProfileImage" class="edit-profile-preview" src="${fn:escapeXml(profileImageUrl)}" alt="프로필 사진">
					</div>
				</c:if>

				<div class="edit-field full">
					<label for="profileImage">프로필 사진</label>
					<input id="profileImage" name="profileImage" type="file" accept="image/*">
					<p class="edit-field-help">이미지 파일만 업로드 가능 (최대 5MB)</p>
				</div>

				<div class="edit-field">
					<label for="userName">이름</label>
					<input id="userName" name="userName" type="text" value="<c:out value='${usersDTO.userName}' />" required>
				</div>

				<div class="edit-field">
					<label for="userNickName">닉네임</label>
					<input id="userNickName" name="userNickName" type="text" value="<c:out value='${usersDTO.userNickName}' />" required>
				</div>

				<div class="edit-field">
					<label for="userGender">성별</label>
					<select id="userGender" name="userGender">
						<option value="">선택 안 함</option>
						<option value="M" ${usersDTO.userGender == 'M' ? 'selected' : ''}>남성</option>
						<option value="F" ${usersDTO.userGender == 'F' ? 'selected' : ''}>여성</option>
					</select>
				</div>

				<div class="edit-field">
					<label for="userPhoneNumber">휴대폰 번호</label>
					<input id="userPhoneNumber" name="userPhoneNumber" type="text" value="<c:out value='${usersDTO.userPhoneNumber}' />">
				</div>

				<div class="edit-field">
					<label for="userRegistrationNo">주민등록번호</label>
					<input id="userRegistrationNo" name="userRegistrationNo" type="text" value="<c:out value='${usersDTO.userRegistrationNo}' />">
				</div>

				<div class="edit-field">
					<label for="userZipCode">우편번호</label>
					<input id="userZipCode" name="userZipCode" type="text" value="<c:out value='${usersDTO.userZipCode}' />">
				</div>

				<div class="edit-field full">
					<label for="userBaseAddress">기본 주소</label>
					<input id="userBaseAddress" name="userBaseAddress" type="text" value="<c:out value='${usersDTO.userBaseAddress}' />">
				</div>

				<div class="edit-field full">
					<label for="userDetailAddress">상세 주소</label>
					<input id="userDetailAddress" name="userDetailAddress" type="text" value="<c:out value='${usersDTO.userDetailAddress}' />">
				</div>

				<div class="edit-actions full">
					<button class="btn primary" type="submit">회원정보 저장</button>
					<a class="btn secondary" href="${pageContext.request.contextPath}/mypage">취소</a>
				</div>
			</form>
		</section>

		<section class="edit-card password-card">
			<div class="edit-card-head">
				<h2>비밀번호 변경</h2>
				<p>현재 비밀번호 확인 후 새 비밀번호로 변경합니다.</p>
			</div>

			<c:if test="${not empty passwordMessage}">
				<div class="alert success"><c:out value="${passwordMessage}" /></div>
			</c:if>
			<c:if test="${not empty passwordErrorMessage}">
				<div class="alert error"><c:out value="${passwordErrorMessage}" /></div>
			</c:if>

			<form class="edit-form-grid" method="post" action="${pageContext.request.contextPath}/mypage/password">
				<c:if test="${not empty _csrf}">
					<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
				</c:if>

				<div class="edit-field full">
					<label for="currentPassword">현재 비밀번호</label>
					<input id="currentPassword" name="currentPassword" type="password" required autocomplete="current-password">
				</div>

				<div class="edit-field">
					<label for="newPassword">새 비밀번호</label>
					<input id="newPassword" name="newPassword" type="password" required minlength="8" autocomplete="new-password">
				</div>

				<div class="edit-field">
					<label for="confirmPassword">새 비밀번호 확인</label>
					<input id="confirmPassword" name="confirmPassword" type="password" required minlength="8" autocomplete="new-password">
				</div>

				<div class="edit-actions full">
					<button class="btn primary" type="submit">비밀번호 변경</button>
				</div>
			</form>
		</section>
	</div>

	<script>
		(function() {
			const profileInput = document.getElementById("profileImage");
			if (!profileInput) return;

			profileInput.addEventListener("change", function() {
				const file = profileInput.files && profileInput.files[0];
				if (!file) return;
				if (!file.type || file.type.indexOf("image/") !== 0) return;

				let preview = document.getElementById("currentProfileImage");
				if (!preview) {
					const group = document.createElement("div");
					group.className = "edit-field full profile-preview-group";

					const label = document.createElement("label");
					label.textContent = "업로드 미리보기";
					group.appendChild(label);

					preview = document.createElement("img");
					preview.id = "currentProfileImage";
					preview.className = "edit-profile-preview";
					preview.alt = "프로필 사진 미리보기";
					group.appendChild(preview);

					const form = profileInput.closest("form");
					const firstField = form ? form.querySelector(".edit-field") : null;
					if (form && firstField) {
						form.insertBefore(group, firstField);
					}
				}

				const reader = new FileReader();
				reader.onload = function(event) {
					preview.src = event.target && event.target.result ? String(event.target.result) : "";
				};
				reader.readAsDataURL(file);
			});
		})();
	</script>

	<jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />
</body>
</html>
