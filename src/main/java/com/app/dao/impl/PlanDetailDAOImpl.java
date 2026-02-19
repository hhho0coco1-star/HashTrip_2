package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.PlanDetailDAO;
import com.app.dto.PlanDetailDTO;

@Repository
public class PlanDetailDAOImpl implements PlanDetailDAO {

	private static final String GET_PLAN_DETAILS_BY_PLAN_NO_STATEMENT_ID = "plan_detail_mapper.getPlanDetailsByPlanNo";
	private static final String GET_STEP_NAMES_BY_PLAN_NO_STATEMENT_ID = "plan_detail_mapper.getStepNamesByPlanNo";
	private static final String GET_TAG_NAMES_BY_PLAN_NO_STATEMENT_ID = "plan_detail_mapper.getTagNamesByPlanNo";
	private static final String GET_TAG_CATEGORIES_BY_PLAN_NO_STATEMENT_ID = "plan_detail_mapper.getTagCategoriesByPlanNo";
	private static final String GET_REPRESENTATIVE_MEMO_BY_PLAN_NO_STATEMENT_ID = "plan_detail_mapper.getRepresentativeMemoByPlanNo";

    @Autowired
    private SqlSessionTemplate sqlSessionTemplate;

    @Override
    public List<PlanDetailDTO> getPlanDetailsByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectList(GET_PLAN_DETAILS_BY_PLAN_NO_STATEMENT_ID, planNo);
    }

    @Override
    public List<String> getStepNamesByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectList(GET_STEP_NAMES_BY_PLAN_NO_STATEMENT_ID, planNo);
    }

    @Override
    public List<String> getTagNamesByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectList(GET_TAG_NAMES_BY_PLAN_NO_STATEMENT_ID, planNo);
    }

    @Override
    public List<String> getTagCategoriesByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectList(GET_TAG_CATEGORIES_BY_PLAN_NO_STATEMENT_ID, planNo);
    }

    @Override
    public String getRepresentativeMemoByPlanNo(Long planNo) {
        return sqlSessionTemplate.selectOne(GET_REPRESENTATIVE_MEMO_BY_PLAN_NO_STATEMENT_ID, planNo);
    }
}
