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
}
