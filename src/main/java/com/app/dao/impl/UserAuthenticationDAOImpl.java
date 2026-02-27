package com.app.dao.impl;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.UserAuthenticationDAO;

@Repository
public class UserAuthenticationDAOImpl implements UserAuthenticationDAO{

	@Autowired
	private SqlSessionTemplate sqlSessionTemplate;

	@Override
	public String getUserEmailByAuthId(String userAuthId) {
		return sqlSessionTemplate.selectOne("users_mapper.getUserEmail", userAuthId);
	}
	
}
