package com.app.service.impl;

import java.util.List;

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
    @Transactional // DB 작업 도중 에러가 나면 전부 취소(Rollback)합니다.
    public String processUserAnalysis(Long userNo, List<UserTagMapDTO> selections) {
        
    	
        // 1. 회원 여부 판단 및 DB 저장
        if (userNo != null && userNo > 0) {
            // 기존 결과가 있으면 삭제 (최신 데이터 유지를 위해)
            userTagMapDAO.deleteByUserId(userNo);
            
            // 사용자가 선택한 10개의 태그를 하나씩 DB에 인서트
            for (UserTagMapDTO dto : selections) {
                dto.setUserNo(userNo); // DTO에 로그인한 유저 번호 세팅
                userTagMapDAO.insertTag(dto);
            }
        }
        
        String finalResult = userTagMapDAO.getFinalAnalysisResult(userNo);
        System.out.println(">>> 서비스에서 가져온 최종 결과: " + finalResult); // ★ 데이터 확인
        
        // [중요] null 체크: 쿼리가 데이터를 못 가져온 경우
        if (finalResult == null || finalResult.trim().isEmpty()) {
            System.out.println(">>> 서비스에서 분석 결과가 null입니다.");
            return null; // 컨트롤러에서 null로 인식하여 리다이렉트 처리
        }
        
        // 3. 결과 테이블에 저장 로직 추가
        // 분석 결과가 성공적으로 나왔을 때만 저장합니다.
        TravelStyleDTO styleDTO = new TravelStyleDTO();
        styleDTO.setUserNo(userNo);
        styleDTO.setTravelTypeName(finalResult);
        styleDTO.setTravelIsAnalyzed("Y");
        
        System.out.println(">>> DB에 저장할 DTO: " + styleDTO); // ★ DTO 확인
        
        userTagMapDAO.insertTravelStyle(styleDTO);

//        return userTagMapDAO.getFinalAnalysisResult(userNo);
        return finalResult;
    }

    @Override
    public List<UserTagMapDTO> getUserTagHistory(Long userNo) {
        // 마이페이지용 조회 로직
        return userTagMapDAO.findByUserId(userNo);
    }
    
}