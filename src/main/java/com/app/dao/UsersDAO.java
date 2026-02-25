package com.app.dao;

import java.util.List;
import java.util.Map;

import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;

public interface UsersDAO {
	UsersDTO getUserByAuthId(String authId);

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

}
