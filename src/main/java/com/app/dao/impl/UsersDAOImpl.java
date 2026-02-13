package com.app.dao.impl;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.UsersDAO;
import com.app.dto.UsersDTO;

@Repository
public class UsersDAOImpl implements UsersDAO {

	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	@Override
	public UsersDTO getUser(String id) {
		UsersDTO usersDTO = sqlSessionTemplate.selectOne("users_mapper.getUser",id);
		return usersDTO;
	}

}
