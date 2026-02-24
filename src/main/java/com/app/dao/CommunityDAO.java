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
}
