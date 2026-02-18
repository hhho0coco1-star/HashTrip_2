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

	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public UsersDTO getUserByAuthId(String authId) {
		UsersDTO usersDTO = sqlSessionTemplate.selectOne("users_mapper.getUserByAuthId", authId);
		return usersDTO;
	}

	@Override
	public List<UserTagMapDTO> getUserTagsByAuthId(String authId) {
		return sqlSessionTemplate.selectList("users_mapper.getUserTagsByAuthId", authId);
	}

	@Override
	public List<TagMasterDTO> getTagMasterList() {
		return sqlSessionTemplate.selectList("users_mapper.getTagMasterList");
	}

	@Override
	public int countTagMasterByTagCode(String tagCode) {
		Integer count = sqlSessionTemplate.selectOne("users_mapper.countTagMasterByTagCode", tagCode);
		return count == null ? 0 : count;
	}

	@Override
	public int insertUserTagByAuthId(String authId, String tagCode, String questionId) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("tagCode", tagCode);
		params.put("questionId", questionId);
		return sqlSessionTemplate.insert("users_mapper.insertUserTagByAuthId", params);
	}

	@Override
	public int deleteUserTagByAuthId(String authId, String tagCode) {
		Map<String, Object> params = new HashMap<>();
		params.put("authId", authId);
		params.put("tagCode", tagCode);
		return sqlSessionTemplate.delete("users_mapper.deleteUserTagByAuthId", params);
	}

}
