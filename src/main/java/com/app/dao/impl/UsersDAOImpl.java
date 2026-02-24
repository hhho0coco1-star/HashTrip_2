package com.app.dao.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.UsersDAO;
import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;

@Repository
public class UsersDAOImpl implements UsersDAO {

	private static final String GET_USER_NO_BY_AUTH_ID_STATEMENT_ID = "users_mapper.getUserNoByAuthId";
	private static final String DELETE_USER_TAGS_BY_USER_NO_STATEMENT_ID = "users_mapper.deleteUserTagsByUserNo";
	private static final String INSERT_USER_ANALYSIS_TAGS_STATEMENT_ID = "users_mapper.insertUserAnalysisTags";
	
	private static final String GET_USER_BY_AUTH_ID_STATEMENT_ID = "users_mapper.getUserByAuthId";
	private static final String GET_USER_NICKNAME_STATEMENT_ID = "users_mapper.getUserNickname";
	private static final String GET_USER_TAGS_BY_AUTH_ID_STATEMENT_ID = "users_mapper.getUserTagsByAuthId";
	private static final String GET_USER_TAGS_BY_USER_NO_STATEMENT_ID = "users_mapper.findUserTagsByUserNo";
	private static final String GET_TAG_MASTER_LIST_STATEMENT_ID = "users_mapper.getTagMasterList";
	private static final String COUNT_TAG_MASTER_BY_TAG_CODE_STATEMENT_ID = "users_mapper.countTagMasterByTagCode";
	private static final String INSERT_USER_TAG_BY_AUTH_ID_STATEMENT_ID = "users_mapper.insertUserTagByAuthId";
	private static final String DELETE_USER_TAG_BY_AUTH_ID_STATEMENT_ID = "users_mapper.deleteUserTagByAuthId";
	private static final String UPDATE_USER_PROFILE_BY_AUTH_ID_STATEMENT_ID = "users_mapper.updateUserProfileByAuthId";
	private static final String UPSERT_USER_ADDRESS_BY_AUTH_ID_STATEMENT_ID = "users_mapper.upsertUserAddressByAuthId";
	private static final String FIND_AUTH_PASSWORD_BY_AUTH_ID_STATEMENT_ID = "users_mapper.findAuthPasswordByAuthId";
	private static final String UPDATE_AUTH_PASSWORD_BY_AUTH_ID_STATEMENT_ID = "users_mapper.updateAuthPasswordByAuthId";

	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public UsersDTO getUserByAuthId(String authId) {
		return sqlSessionTemplate.selectOne(GET_USER_BY_AUTH_ID_STATEMENT_ID, authId);
	}

	@Override
	public String getUserNickname(int userNo) {
		return sqlSessionTemplate.selectOne(GET_USER_NICKNAME_STATEMENT_ID, userNo);
	}

	@Override
	public List<UserTagMapDTO> getUserTagsByAuthId(String authId) {
		return sqlSessionTemplate.selectList(GET_USER_TAGS_BY_AUTH_ID_STATEMENT_ID, authId);
	}

	@Override
	public List<UserTagMapDTO> getUserTagsByUserNo(Long userNo) {
		return sqlSessionTemplate.selectList(GET_USER_TAGS_BY_USER_NO_STATEMENT_ID, userNo);
	}

	@Override
	public List<TagMasterDTO> getTagMasterList() {
		return sqlSessionTemplate.selectList(GET_TAG_MASTER_LIST_STATEMENT_ID);
	}

	@Override
	public int countTagMasterByTagCode(String tagCode) {
		Integer count = sqlSessionTemplate.selectOne(COUNT_TAG_MASTER_BY_TAG_CODE_STATEMENT_ID, tagCode);
		return count == null ? 0 : count;
	}

	@Override
	public int insertUserTagByAuthId(String authId, String tagCode, String questionId) {
		return sqlSessionTemplate.insert(INSERT_USER_TAG_BY_AUTH_ID_STATEMENT_ID,
				buildUserTagParams(authId, tagCode, questionId));
	}

	@Override
	public int deleteUserTagByAuthId(String authId, String tagCode) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("tagCode", tagCode);
		return sqlSessionTemplate.delete(DELETE_USER_TAG_BY_AUTH_ID_STATEMENT_ID, params);
	}

	@Override
	public int updateUserProfileByAuthId(String authId, UsersDTO usersDTO) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("userName", usersDTO.getUserName());
		params.put("userNickName", usersDTO.getUserNickName());
		params.put("userGender", usersDTO.getUserGender());
		params.put("userPhoneNumber", usersDTO.getUserPhoneNumber());
		params.put("userRegistrationNo", usersDTO.getUserRegistrationNo());
		return sqlSessionTemplate.update(UPDATE_USER_PROFILE_BY_AUTH_ID_STATEMENT_ID, params);
	}

	@Override
	public int upsertUserAddressByAuthId(String authId, UsersDTO usersDTO) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("userZipCode", usersDTO.getUserZipCode());
		params.put("userBaseAddress", usersDTO.getUserBaseAddress());
		params.put("userDetailAddress", usersDTO.getUserDetailAddress());
		return sqlSessionTemplate.update(UPSERT_USER_ADDRESS_BY_AUTH_ID_STATEMENT_ID, params);
	}

	@Override
	public String findAuthPasswordByAuthId(String authId) {
		return sqlSessionTemplate.selectOne(FIND_AUTH_PASSWORD_BY_AUTH_ID_STATEMENT_ID, authId);
	}

	@Override
	public int updateAuthPasswordByAuthId(String authId, String encodedPassword) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("encodedPassword", encodedPassword);
		return sqlSessionTemplate.update(UPDATE_AUTH_PASSWORD_BY_AUTH_ID_STATEMENT_ID, params);
	}

	private Map<String, Object> buildUserTagParams(String authId, String tagCode, String questionId) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("tagCode", tagCode);
		params.put("questionId", questionId);
		return params;
	}
	
	@Override
	public int deleteUserTagsByUserNo(Long userNo) {
	    // 특정 태그가 아닌 userNo를 기준으로 해당 유저의 모든 태그 삭제
	    return sqlSessionTemplate.delete(DELETE_USER_TAGS_BY_USER_NO_STATEMENT_ID, userNo);
	}
	
	@Override
	public int insertUserAnalysisTags(Map<String, Object> params) {
	    // Service에서 만든 {userNo: 1, list: [...]} 형태의 맵을 전달
	    return sqlSessionTemplate.insert(INSERT_USER_ANALYSIS_TAGS_STATEMENT_ID, params);
	}

	@Override
	public int getUserNoByAuthId(String authId) {
	    // 쿼리 결과가 없을 경우를 대비해 Integer로 받은 뒤 0으로 처리하거나, 
	    // 결과가 확실히 있다면 바로 int로 리턴합니다.
	    Integer userNo = sqlSessionTemplate.selectOne(GET_USER_NO_BY_AUTH_ID_STATEMENT_ID, authId);
	    return userNo != null ? userNo : 0;
	}
}
