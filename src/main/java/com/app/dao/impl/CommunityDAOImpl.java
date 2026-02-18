package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.CommunityDAO;
import com.app.dto.CommunityDTO;

@Repository
public class CommunityDAOImpl implements CommunityDAO {

    @Autowired
    private SqlSessionTemplate sqlSessionTemplate;

    @Override
    public List<CommunityDTO> getCommunityReviewsByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectList("community_mapper.getCommunityReviewsByPlanNo", planNo);
    }

    @Override
    public int insertCommunityReview(CommunityDTO review) {
        return sqlSessionTemplate.insert("community_mapper.insertCommunityReview", review);
    }
}
