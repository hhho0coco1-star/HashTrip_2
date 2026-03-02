package com.app.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.FaqDAO;
import com.app.dto.FaqDTO;
import com.app.service.FaqService;

@Service
public class FaqServiceImpl implements FaqService{

	@Autowired
    private FaqDAO faqDAO;
	
	@Override
    public List<FaqDTO> getFaqList() { return faqDAO.selectAllFaq(); }
	
    @Override
    public FaqDTO getFaqDetail(int faqNo) { return faqDAO.selectFaqByNo(faqNo); }
    
    @Override
    public void registerFaq(FaqDTO faqDTO) { faqDAO.insertFaq(faqDTO); }
    
    @Override
    public void modifyFaq(FaqDTO faqDTO) { faqDAO.updateFaq(faqDTO); }
    
    @Override
    public void removeFaq(int faqNo) { faqDAO.deleteFaq(faqNo); }
    
}
