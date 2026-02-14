package com.app.dao;

import java.util.List;

import com.app.dto.CommunityDTO;

public interface CommunityDAO {

    List<CommunityDTO> getCommunityReviewsByPlanNo(Long planNo);

    int insertCommunityReview(CommunityDTO review);

    int hasPlanLike(Long planNo, Long userNo);

    int insertPlanLike(Long planNo, Long userNo);

    int deletePlanLike(Long planNo, Long userNo);

    int countPlanLikes(Long planNo);
}
