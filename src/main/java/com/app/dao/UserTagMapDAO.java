package com.app.dao;

import java.util.List;
import java.util.Map;

import com.app.dto.TravelStyleDTO;
import com.app.dto.UserTagMapDTO;

public interface UserTagMapDAO {

	void deleteByUserId(Long userNo); // 기존 결과 삭제

	void insertTag(UserTagMapDTO dto); // 태그 저장

	List<UserTagMapDTO> findByUserId(Long userNo); // 마이페이지 조회
	
	int insertTravelStyle(TravelStyleDTO travelStyleDTO); // 성향 결과 저장
	
	Map<String, Object> getTravelAnalysisData(Long userNo); // 성향 결과 출력
	
	void deleteTravelStyleByUserNo(Long userNo); // 성향 결과 기존 값 삭제
}
