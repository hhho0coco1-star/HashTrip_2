package com.app.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.PlanDetailDAO;
import com.app.dto.PlanDetailDTO;

@Service
public class PlanDetailServiceImpl implements PlanDetailService {

    @Autowired
    private PlanDetailDAO planDetailDAO;

    @Override
    public List<PlanDetailDTO> findPlanDetails(Long planNo) {
        return planDetailDAO.getPlanDetailsByPlanNo(planNo);
    }

    @Override
    public List<String> findStepNames(Long planNo) {
        return planDetailDAO.getStepNamesByPlanNo(planNo);
    }

    @Override
    public List<String> findTagNames(Long planNo) {
        return planDetailDAO.getTagNamesByPlanNo(planNo);
    }

    @Override
    public List<String> findTagCategories(Long planNo) {
        return planDetailDAO.getTagCategoriesByPlanNo(planNo);
    }

    @Override
    public String findRepresentativeMemo(Long planNo) {
        return planDetailDAO.getRepresentativeMemoByPlanNo(planNo);
    }

    @Override
    public List<Long> findPlanNosByRegion(String region) {
        return planDetailDAO.getPlanNosByRegion(region);
    }

	@Override
	public String findRepresentativeImageUrl(Long planNo) {
		return planDetailDAO.getRepresentativeImageUrlByPlanNo(planNo);
	}
    
    
}
