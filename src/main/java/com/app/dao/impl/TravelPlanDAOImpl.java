package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.TravelPlanDAO;
import com.app.dto.TravelPlanDTO;

@Repository
public class TravelPlanDAOImpl implements TravelPlanDAO {

	private static final String GET_PUBLIC_TRAVEL_PLANS_STATEMENT_ID = "travel_plan_mapper.getPublicTravelPlans";
	private static final String GET_TRAVEL_PLAN_BY_ID_STATEMENT_ID = "travel_plan_mapper.getTravelPlanById";
	private static final String GET_TRAVEL_PLANS_BY_USER_NO_STATEMENT_ID = "travel_plan_mapper.getTravelPlansByUserNo";

    @Autowired
    private SqlSessionTemplate sqlSessionTemplate;

    @Override
    public List<TravelPlanDTO> getPublicTravelPlans() {
        return sqlSessionTemplate.selectList(GET_PUBLIC_TRAVEL_PLANS_STATEMENT_ID);
    }

    @Override
    public TravelPlanDTO getTravelPlanById(Long planNo) {
        return sqlSessionTemplate.selectOne(GET_TRAVEL_PLAN_BY_ID_STATEMENT_ID, planNo);
    }

    @Override
    public List<TravelPlanDTO> getTravelPlansByUserNo(Long userNo) {
        return sqlSessionTemplate.selectList(GET_TRAVEL_PLANS_BY_USER_NO_STATEMENT_ID, userNo);
    }
}
