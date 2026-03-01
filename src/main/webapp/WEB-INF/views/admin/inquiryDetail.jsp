<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<p><strong>내용:</strong> <br> ${inquiry.inquiryContent}</p>
<p><strong>이메일:</strong> ${inquiry.inquiryEmail}</p>                
<hr>                
<form action="${pageContext.request.contextPath}/admin/inquiry/reply" method="post">
    <input type="hidden" name="inquiryNo" value="${inquiry.inquiryNo}">                
    <textarea name="replyContent" style="width:100%; height:100px;" placeholder="답변 내용을 입력하세요" required>${inquiry.replyContent}</textarea>                
    
    <div style="text-align: right; margin-top:5px;">                
        <button type="submit">답변 저장</button>                
    </div>
</form>