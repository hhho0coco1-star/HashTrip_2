package com.app.dao;

import java.util.List;

import com.app.dto.CommunityDTO;

public interface CommunityDAO {

    List<CommunityDTO> getCommunityReviewsByPlanNo(Long planNo);

    CommunityDTO getCommunityReviewByPlanNoAndUserNo(Long planNo, Long userNo);

    int insertCommunityReview(CommunityDTO review);

    int updateCommunityReview(CommunityDTO review);

    int countCommunityReviewsByAuthId(String authId);

    List<CommunityDTO> getCommunityReviewsByAuthIdPaged(String authId, int startRow, int endRow, String sortType);

    /**
     * 특정 일정(planNo)에 연결된 커뮤니티 리뷰 전체 삭제.
     */
    int deleteCommunityReviewsByPlanNo(Long planNo);
}
