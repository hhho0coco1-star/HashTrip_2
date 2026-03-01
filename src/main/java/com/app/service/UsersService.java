package com.app.service;

import java.util.List;
import java.util.Map;

import com.app.dto.InquiryDTO;
import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;
	
public interface UsersService {
	
	UsersDTO getUserByAuthId(String authId);

	UsersDTO updateProfileByAuthId(String authId, UsersDTO users);

	void changePasswordByAuthId(String authId, String currentPassword, String newPassword);

	String findUserName(int userNo);

	List<UserTagMapDTO> getUserTagsByUserNo(Long userNo);

	// 1. 전체 태그 목록 가져오기 (마이페이지 출력용)
    List<TagMasterDTO> getTagMasterList();

    // 2. 특정 유저의 선택된 태그 가져오기
    List<UserTagMapDTO> getUserTagsByAuthId(String authId);

    // 3. 성향 분석 결과 전체 저장 (삭제 후 삽입)
    void saveUserAnalysisResults(String authId, List<Map<String, Object>> resultData) throws Exception;

    // 4. 개별 태그 추가/삭제 (마이페이지 개별 수정용)
    boolean addUserTagByAuthId(String authId, String tagCode);
    boolean removeUserTagByAuthId(String authId, String tagCode);
    
    // 1:1 문의 등록
    int registerInquiry(InquiryDTO dto);
    
    // 특정 유저의 문의 목록 조회
    List<InquiryDTO> getMyInquiries(Long userNo);
    
    // 1:1 문의 삭제
    int removeInquiry(Long inquiryNo);
    
    // 1:1 문의 수정
    int modifyInquiry(InquiryDTO dto);
    
    // 1:1 문의 조회
    InquiryDTO getInquiryDetail(Long inquiryNo);
    
    // 관리자 페이지 회원목록 조회
    List<UsersDTO> findAllUsers();
    
    Map<String, Object> getPagedUsers(int page, int size, String searchType, String keyword, String orderBy);
    
    // 관리자 권한 부여/취소
    boolean changeUserType(int userNo, String userType, Integer loginUserNo);
    
    // 1:1 문의내역(관리자 페이지)
    List<InquiryDTO> getAllInquiries(Map<String, Object> params);

}
