package com.app.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.UserAuthenticationDAO;
import com.app.service.UserAuthenticationService;

@Service
public class UserAuthenticationServiceImpl implements UserAuthenticationService{

	@Autowired
	private UserAuthenticationDAO userAuthenticationDAO;

	@Override
	public String getUserEmailByAuthId(String userAuthId) {
		String email = userAuthenticationDAO.getUserEmailByAuthId(userAuthId);
        return (email != null) ? email : "";
	}
	
}
