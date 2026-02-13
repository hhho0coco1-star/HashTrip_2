package com.app.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.UsersDAO;
import com.app.dto.UsersDTO;
import com.app.service.UsersService;

@Service
public class UsersServiceImpl implements UsersService {

	@Autowired
	UsersDAO usersDAO;
	
	@Override
	public UsersDTO getUser(String id) {
		// TODO Auto-generated method stub
			UsersDTO usersDTO = usersDAO.getUser(id);
		return usersDTO;
	}

}
