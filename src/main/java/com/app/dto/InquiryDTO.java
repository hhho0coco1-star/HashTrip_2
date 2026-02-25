package com.app.dto;

import lombok.Data;

@Data
public class InquiryDTO {
	
	private Long inquiryNo;
    private Long userNo;        
    private String inquiryType; // 문의 유형
    private String inquiryTitle; // 문의 제목
    private String inquiryContent; // 문의 내용
    private String inquiryEmail; // 답변 받을 email
    private String inquiryDate; // 작성 일자
    private String replyContent; // 답변 내용
    private String replyDate; // 답변 일자
    private String status; // 답변 상태
}
