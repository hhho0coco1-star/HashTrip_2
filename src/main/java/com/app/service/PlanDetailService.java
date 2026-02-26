package com.app.service;

import java.util.List;

import com.app.dto.PlanDetailDTO;

public interface PlanDetailService {

    List<PlanDetailDTO> findPlanDetails(Long planNo);

    List<String> findStepNames(Long planNo);

    List<String> findTagNames(Long planNo);

    List<String> findTagCategories(Long planNo);

    String findRepresentativeMemo(Long planNo);

    String findRepresentativeImageUrl(Long planNo);

    /**
     * 루트에 포함된 여행지의 주소/이름에 지역이 포함된 plan_no 목록 (지역 필터용)
     */
    List<Long> findPlanNosByRegion(String region);
}
