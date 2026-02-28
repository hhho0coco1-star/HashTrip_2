package com.app.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.app.dao.UserTagMapDAO;
import com.app.dto.TravelStyleDTO;
import com.app.dto.UserTagMapDTO;
import com.app.service.UserTagMapService;

@Service
public class UserTagMapServiceImpl implements UserTagMapService {

    @Autowired
    private UserTagMapDAO userTagMapDAO; // 작성하신 DAOImpl 주입

    @Override
    @Transactional // 모든 과정이 하나의 트랜잭션으로 묶여야 안전합니다.
    public String processUserAnalysis(Long userNo, List<UserTagMapDTO> selections) {
        
        if (userNo == null || userNo <= 0) return null;

        // 1. 기존 데이터 초기화 및 신규 태그 저장
        userTagMapDAO.deleteByUserId(userNo);
        for (UserTagMapDTO dto : selections) {
            dto.setUserNo(userNo);
            userTagMapDAO.insertTag(dto);
        }

        // 2. [핵심] 수정된 DAO를 통해 분석 데이터(Map) 가져오기
        // XML에서 AS로 지정한 별칭(Alias)들이 Map의 Key가 됩니다.
        Map<String, Object> analysisData = userTagMapDAO.getTravelAnalysisData(userNo);
        System.out.println(">>> 분석 결과 데이터 Map: " + analysisData);
        
        if (analysisData == null) {
            System.out.println(">>> 분석 데이터 생성 실패");
            return null;
        }

        // 3. TravelStyleDTO 객체 생성 및 데이터 매핑
        TravelStyleDTO styleDTO = new TravelStyleDTO();
        styleDTO.setUserNo(userNo);
        
        // Map에서 꺼낼 때 XML의 대문자 별칭과 일치시켜야 합니다.
        String finalSummary = (String) analysisData.get("TRAVEL_FINAL_SUMMARY");
        styleDTO.setTravelFinalSummary(finalSummary);
        styleDTO.setSelectedPlaceCodes((String) analysisData.get("SELECTED_PLACE_CODES"));
        styleDTO.setSelectedEnergyCodes((String) analysisData.get("SELECTED_ENERGY_CODES"));
        styleDTO.setSelectedPlanCodes((String) analysisData.get("SELECTED_PLAN_CODES"));
        
        System.out.println(analysisData.get("SELECTED_PLACE_CODES"));
        System.out.println(analysisData.get("SELECTED_ENERGY_CODES"));
        System.out.println(analysisData.get("SELECTED_PLAN_CODES"));
        
        
        // 타입 이름은 요약문의 앞부분이나 별도 로직으로 지정 (예: "나만의 여행 스타일")
        styleDTO.setTravelTypeName("내 여행 스타일"); 
        styleDTO.setTravelIsAnalyzed("Y");
        
        userTagMapDAO.deleteTravelStyleByUserNo(userNo);

        // 4. Travel_Styles 테이블에 최종 저장
        userTagMapDAO.insertTravelStyle(styleDTO);

        // 5. 화면(Controller)에 보여줄 최종 문구 반환
        return finalSummary;
    }

    @Override
    public List<UserTagMapDTO> getUserTagHistory(Long userNo) {
        // 마이페이지용 조회 로직
        return userTagMapDAO.findByUserId(userNo);
    }
    
}