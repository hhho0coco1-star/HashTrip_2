<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>#Trip</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
<style type="text/css">
/* ... 기존 <style> 태그 내용 그대로 유지 ... */
.notice-wrapper { background-color: #f9f9f9; padding: 60px 20px; min-height: 80vh; }
.notice-container { max-width: 1000px; margin: 0 auto; }
.notice-header { text-align: center; margin-bottom: 40px; }
.notice-header h1 { font-size: 32px; color: #222; margin-bottom: 10px; }
.notice-table-container { background: #fff; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); overflow: hidden; }
.notice-table { width: 100%; border-collapse: collapse; }
.notice-table th { background-color: #fcfcfc; border-bottom: 1px solid #eee; padding: 15px 20px; font-size: 14px; color: #555; text-align: center; }
.notice-table td { padding: 20px; border-bottom: 1px solid #eee; }
.col-num { width: 10%; text-align: center; }
.col-title { width: 75%; text-align: left; }
.col-date { width: 15%; text-align: center; color: #999; }
@keyframes fadeIn {from { opacity:0; transform: translateY(-5px); } to { opacity: 1; transform: translateY(0); } }
.notice-content-row { display: none; background-color: #fafafa; }
.notice-content-inner { padding: 30px 60px; line-height: 1.8; color: #555; font-size: 15px; animation: fadeIn 0.3s ease-in-out; }
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />
	<div class="notice-wrapper">
		<div class="notice-container">
			<div class="notice-header">
				<h1>공지사항</h1>
				<p>클릭하여 상세 내용을 확인하세요.</p>
			</div>

			<div class="notice-table-container">
				<table class="notice-table">
					<thead>
						<tr>
							<th class="col-num">번호</th>
							<th class="col-title">제목</th>
							<th class="col-date">등록일</th>
						</tr>
					</thead>
					<tbody>
						<%-- ⭐ DB 데이터를 반복문으로 출력 --%>
						<c:forEach var="notice" items="${noticeList}">
							<tr class="notice-row">
								<td class="col-num">${notice.noticeNo}</td>
								<td class="col-title">${notice.title}</td>
								<%-- 날짜 형식 포맷팅 (fmt 태그 사용) --%>
								<td class="col-date">
									<fmt:formatDate value="${notice.createdAt}" pattern="yyyy.MM.dd" />
								</td>
							</tr>
							<tr class="notice-content-row">
								<td colspan="3">
									<div class="notice-content-inner">
										<%-- DB에서 가져온 content 값 (HTML 태그가 포함되어 있으므로 escapeXml="false") --%>
										<p><c:out value="${notice.content}" escapeXml="false" /></p>
									</div>
								</td>
							</tr>
						</c:forEach>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<script type="text/javascript">
	// JavaScript는 기존과 동일하게 작동합니다.
	document.querySelectorAll('.notice-content-row').forEach(row => {
	    row.style.display = 'none';
	});

	document.querySelectorAll('.notice-row').forEach(row => {
	    row.addEventListener('click', () => {
	        const contentRow = row.nextElementSibling;
	        const isVisible = contentRow.style.display === 'table-row';
	        
	        // 나머지는 모두 닫기
	        document.querySelectorAll('.notice-content-row').forEach(content => {
	            content.style.display = 'none';
	        });
	        document.querySelectorAll('.notice-row').forEach(r => {
	            r.classList.remove('active');
	        });

	        // 클릭한 것만 토글
	        if (!isVisible) {
	            contentRow.style.display = 'table-row';
	            row.classList.add('active');
	        }
	    });
	});
	</script>
</body>
</html>