package com.app.dao;

import java.util.List;

import com.app.dto.PlanDetailDTO;

public interface PlanDetailDAO {

    int insertPlanDetail(PlanDetailDTO planDetail);

    List<PlanDetailDTO> getPlanDetailsByPlanNo(Long planNo);

    PlanDetailDTO getPlanDetailByPlanDetailNo(Long planDetailNo);

    int getMaxVisitOrderByPlanNo(Long planNo);

    int deletePlanDetailsByPlanNo(Long planNo);

    List<String> getStepNamesByPlanNo(Long planNo);

    List<String> getTagNamesByPlanNo(Long planNo);

    List<String> getTagCategoriesByPlanNo(Long planNo);

    String getRepresentativeMemoByPlanNo(Long planNo);

    /** 루트에 포함된 여행지의 주소/이름에 지역 키워드가 포함된 plan_no 목록 */
    List<Long> getPlanNosByRegion(String region);
}
