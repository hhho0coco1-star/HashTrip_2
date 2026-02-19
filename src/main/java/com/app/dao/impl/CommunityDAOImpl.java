package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.CommunityDAO;
import com.app.dto.CommunityDTO;

@Repository
public class CommunityDAOImpl implements CommunityDAO {

	private static final String GET_COMMUNITY_REVIEWS_BY_PLAN_NO_STATEMENT_ID = "community_mapper.getCommunityReviewsByPlanNo";
	private static final String INSERT_COMMUNITY_REVIEW_STATEMENT_ID = "community_mapper.insertCommunityReview";

    @Autowired
    private SqlSessionTemplate sqlSessionTemplate;

    @Override
    public List<CommunityDTO> getCommunityReviewsByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectList(GET_COMMUNITY_REVIEWS_BY_PLAN_NO_STATEMENT_ID, planNo);
    }

    @Override
    public int insertCommunityReview(CommunityDTO review) {
        return sqlSessionTemplate.insert(INSERT_COMMUNITY_REVIEW_STATEMENT_ID, review);
    }
}
