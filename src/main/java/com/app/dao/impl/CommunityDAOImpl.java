package com.app.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    @Override
    public int hasPlanLike(Long planNo, Long userNo) {
        Integer count = sqlSessionTemplate.selectOne("community_mapper.hasPlanLike", buildLikeParam(planNo, userNo));
        return count == null ? 0 : count;
    }

    @Override
    public int insertPlanLike(Long planNo, Long userNo) {
        return sqlSessionTemplate.insert("community_mapper.insertPlanLike", buildLikeParam(planNo, userNo));
    }

    @Override
    public int deletePlanLike(Long planNo, Long userNo) {
        return sqlSessionTemplate.delete("community_mapper.deletePlanLike", buildLikeParam(planNo, userNo));
    }

    @Override
    public int countPlanLikes(Long planNo) {
        Integer count = sqlSessionTemplate.selectOne("community_mapper.countPlanLikes", planNo);
        return count == null ? 0 : count;
    }

    private Map<String, Object> buildLikeParam(Long planNo, Long userNo) {
        Map<String, Object> param = new HashMap<>();
        param.put("planNo", planNo);
        param.put("userNo", userNo);
        return param;
    }
}
