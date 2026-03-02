package com.app.service;

import java.util.List;

import com.app.dto.FaqDTO;

public interface FaqService {

	List<FaqDTO> getFaqList();
	
    FaqDTO getFaqDetail(int faqNo);
    
    void registerFaq(FaqDTO faqDTO);
    
    void modifyFaq(FaqDTO faqDTO);
    
    void removeFaq(int faqNo);
    
}
