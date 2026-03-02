package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.FaqDAO;
import com.app.dto.FaqDTO;

@Repository
public class FaqDAOImpl implements FaqDAO{

	@Autowired 
	SqlSessionTemplate sqlSessionTemplate;
	
	private static final String NS = "faq_mapper.";
	
	@Override
    public List<FaqDTO> selectAllFaq() { 
		return sqlSessionTemplate.selectList(NS + "selectAll"); 
	}
	
    @Override
    public FaqDTO selectFaqByNo(int faqNo) { 
    	return sqlSessionTemplate.selectOne(NS + "selectOne", faqNo); 
    }
    
    @Override
    public int insertFaq(FaqDTO faqDTO) { 
    	return sqlSessionTemplate.insert(NS + "insert", faqDTO); 
    }
    
    @Override
    public int updateFaq(FaqDTO faqDTO) { 
    	return sqlSessionTemplate.update(NS + "update", faqDTO); 
    }
    
    @Override
    public int deleteFaq(int faqNo) { 
    	return sqlSessionTemplate.delete(NS + "delete", faqNo); 
    }
    
}
