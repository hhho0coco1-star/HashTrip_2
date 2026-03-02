<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>#Trip</title>

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/common.css">

<style type="text/css">
/* ... 기존 <style> 태그 내용 그대로 유지 ... */
.faq-wrapper { background-color: #f9f9f9; padding: 80px 20px; min-height: 100vh; }
.faq-container { max-width: 850px; margin: 0 auto; }
.faq-header { text-align: center; margin-bottom: 50px; }
.faq-header h1 { font-size: 32px; color: #222; margin-bottom: 10px; }
.faq-header p { color: #666; }
.faq-item { background: #fff; margin-bottom: 15px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05); overflow: hidden; }
.faq-question { width: 100%; padding: 20px 25px; display: flex; align-items: center; background: none; border: none; cursor: pointer; text-align: left; transition: background 0.3s; }
.faq-question:hover { background-color: #f0f7ff; }
.category { font-size: 12px; color: #007bff; font-weight: bold; margin-right: 15px; min-width: 70px; }
.faq-question .text { flex: 1; font-size: 16px; font-weight: 600; color: #333; }
.arrow-icon { font-style: normal; color: #ccc; transition: transform 0.3s; }
.faq-answer { padding: 0 25px; max-height: 0; overflow: hidden; transition: all 0.3s ease-out; background-color: #fafafa; }
.faq-answer p { padding: 20px 0; font-size: 15px; color: #555; line-height: 1.6; margin: 0; }
.faq-item.active .faq-answer { max-height: 300px; border-top: 1px solid #eee; }
.faq-item.active .arrow-icon { transform: rotate(180deg); }
.faq-footer { margin-top: 40px; text-align: center; color: #888; font-size: 14px; }
.faq-footer a { color: #007bff; text-decoration: none; font-weight: bold; }
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<div class="faq-wrapper">
		<div class="faq-container">
			<div class="faq-header">
				<h1>자주 묻는 질문</h1>
				<p>#Trip 서비스 이용에 대해 궁금한 점을 해결해 드립니다.</p>
			</div>

			<div class="faq-list">
				<%-- ⭐ DB 데이터를 반복문으로 출력 --%>
				<c:forEach var="faq" items="${faqList}">
					<div class="faq-item">
						<button class="faq-question">
							<%-- DB에서 가져온 category 값 --%>
							<span class="category">${faq.category}</span>
							<%-- DB에서 가져온 question 값 --%>
							<span class="text">${faq.question}</span>
							<i class="arrow-icon">▼</i>
						</button>
						<div class="faq-answer">
							<%-- DB에서 가져온 answer 값 --%>
							<p>${faq.answer}</p>
						</div>
					</div>
				</c:forEach>
			</div>

			<div class="faq-footer">
				<p>
					원하는 답변을 찾지 못하셨나요?
					<c:choose>
						<c:when test="${not empty usersDTO and not empty usersDTO.userNo}">
							<a href="/hashTrip/contact">1:1 문의하기</a>를 이용해 주세요.
						</c:when>
						<c:otherwise>
							<a href="javascript:void(0);" onclick="checkLogin()">1:1 문의하기</a>를 이용해 주세요.
						</c:otherwise>
					</c:choose>
				</p>
			</div>
		</div>
	</div>

	<script type="text/javascript">
		// JavaScript는 기존과 동일하게 작동합니다.
		document.querySelectorAll('.faq-question').forEach(button => {
		    button.addEventListener('click', () => {
		        const faqItem = button.parentElement;
		        faqItem.classList.toggle('active');
		    });
		});
		
		function checkLogin() {
			if(confirm("로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?")) {
			location.href = "${pageContext.request.contextPath}/auth/login";
			}
		}
	</script>
</body>
</html>