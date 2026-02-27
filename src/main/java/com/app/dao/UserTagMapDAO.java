package com.app.dao;

import java.util.List;

import com.app.dto.TravelStyleDTO;
import com.app.dto.UserTagMapDTO;

public interface UserTagMapDAO {

	void deleteByUserId(Long userNo); // 기존 결과 삭제

	void insertTag(UserTagMapDTO dto); // 태그 저장

	List<UserTagMapDTO> findByUserId(Long userNo); // 마이페이지 조회
	
	public String getFinalAnalysisResult(Long userNo); // 성형 결과 출력
	
	int insertTravelStyle(TravelStyleDTO travelStyleDTO); // 성향 결과 저장
}
