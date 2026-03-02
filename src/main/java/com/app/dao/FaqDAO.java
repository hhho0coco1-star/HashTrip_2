package com.app.dao;

import java.util.List;

import com.app.dto.FaqDTO;

public interface FaqDAO {
	
	List<FaqDTO> selectAllFaq();
	
    FaqDTO selectFaqByNo(int faqNo);
    
    int insertFaq(FaqDTO faqDTO);
    
    int updateFaq(FaqDTO faqDTO);
    
    int deleteFaq(int faqNo);

}
