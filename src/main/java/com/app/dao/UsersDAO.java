package com.app.dao;

import java.util.List;
import java.util.Map;

import com.app.dto.InquiryDTO;
import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;

public interface UsersDAO {
	
	UsersDTO getUserByAuthId(String authId);
	UsersDTO getUserProfileImageByUserNo(Long userNo);

	String getUserNickname(int userNo);

	List<UserTagMapDTO> getUserTagsByUserNo(Long userNo);

	List<TagMasterDTO> getTagMasterList();

	int countTagMasterByTagCode(String tagCode);

	int insertUserTagByAuthId(String authId, String tagCode, String questionId);

	int deleteUserTagByAuthId(String authId, String tagCode);

	int updateUserProfileByAuthId(String authId, UsersDTO usersDTO);

	int upsertUserAddressByAuthId(String authId, UsersDTO usersDTO);

	String findAuthPasswordByAuthId(String authId);

	int updateAuthPasswordByAuthId(String authId, String encodedPassword);
	
	// 1. 유저 고유 번호 조회
    int getUserNoByAuthId(String authId);

    // 2. 기존 성향 태그 전체 삭제
    int deleteUserTagsByUserNo(Long userNo);

    // 3. 분석 결과 태그들 일괄 삽입
    int insertUserAnalysisTags(Map<String, Object> params);

    // 4. (기존 기능) 마이페이지용 태그 리스트 조회
    List<UserTagMapDTO> getUserTagsByAuthId(String authId);
    
    // 1:1 문의
    int insertInquiry(InquiryDTO dto);
    
    // 1:1 문의내용 조회
    List<InquiryDTO> selectInquiryList(Long userNo);
    
    // 1:1 문의 삭제
    int deleteInquiry(Long inquiryNo);

    // 1:1 문의 수정
    int updateInquiry(InquiryDTO dto);
    
    // 1:1 문의 조회
    InquiryDTO getInquiryDetail(Long inquiryNo);
    
    // 관리자 페이지 회원목록 조회
    List<UsersDTO> findAllUsers();
    
    // 1. 전체 데이터 개수 조회
    int countUsers(Map<String, Object> params);
    
    // 2. 페이징 데이터 조회
    List<UsersDTO> findUsersPaged(Map<String, Object> params);
    
    // 관리자 권한 부여/취소
    int updateUserType(Map<String, Object> params);
    
    // 1:1 문의 전체 조회(관리자 페이지 전용)
    List<InquiryDTO> selectAllInquiries(Map<String, Object> params);
    
    // 💡 답변 저장 및 상태 업데이트 메서드
    public int updateReply(InquiryDTO inquiryDTO);
    
}
