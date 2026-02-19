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

	private static final String GET_USER_BY_AUTH_ID_STATEMENT_ID = "users_mapper.getUserByAuthId";
	private static final String GET_USER_NICKNAME_STATEMENT_ID = "users_mapper.getUserNickname";
	private static final String GET_USER_TAGS_BY_AUTH_ID_STATEMENT_ID = "users_mapper.getUserTagsByAuthId";
	private static final String GET_TAG_MASTER_LIST_STATEMENT_ID = "users_mapper.getTagMasterList";
	private static final String COUNT_TAG_MASTER_BY_TAG_CODE_STATEMENT_ID = "users_mapper.countTagMasterByTagCode";
	private static final String INSERT_USER_TAG_BY_AUTH_ID_STATEMENT_ID = "users_mapper.insertUserTagByAuthId";
	private static final String DELETE_USER_TAG_BY_AUTH_ID_STATEMENT_ID = "users_mapper.deleteUserTagByAuthId";

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

	private Map<String, Object> buildUserTagParams(String authId, String tagCode, String questionId) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("tagCode", tagCode);
		params.put("questionId", questionId);
		return params;
	}
}
