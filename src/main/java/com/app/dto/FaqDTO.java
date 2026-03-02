package com.app.dto;

import lombok.Data;

@Data
public class FaqDTO { // 자주묻는질문 DTO

	private int faqNo;
    private String category;
    private String question;
    private String answer;
    private int orderNo;
    
}
