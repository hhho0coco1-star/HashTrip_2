package com.app.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.UsersDAO;
import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;
import com.app.service.UsersService;

@Service
public class UsersServiceImpl implements UsersService {

	@Autowired
	UsersDAO usersDAO;
	
	@Override
	public UsersDTO getUserByAuthId(String authId) {
		UsersDTO usersDTO = usersDAO.getUserByAuthId(authId);
		return usersDTO;
	}

	@Override
	public String findUserName(int userNo) {
		return usersDAO.getUserNickname(userNo);
	}

	@Override
	public List<UserTagMapDTO> getUserTagsByAuthId(String authId) {
		return usersDAO.getUserTagsByAuthId(authId);
	}

	@Override
	public List<TagMasterDTO> getTagMasterList() {
		return usersDAO.getTagMasterList();
	}

	@Override
	public boolean addUserTagByAuthId(String authId, String tagCode) {
		String safeAuthId = normalizeAuthId(authId);
		String safeTagCode = normalizeTagCode(tagCode);
		if (usersDAO.countTagMasterByTagCode(safeTagCode) <= 0) {
			throw new IllegalArgumentException("존재하지 않는 태그 코드입니다.");
		}
		return usersDAO.insertUserTagByAuthId(safeAuthId, safeTagCode, "MANUAL") > 0;
	}

	@Override
	public boolean removeUserTagByAuthId(String authId, String tagCode) {
		String safeAuthId = normalizeAuthId(authId);
		String safeTagCode = normalizeTagCode(tagCode);
		return usersDAO.deleteUserTagByAuthId(safeAuthId, safeTagCode) > 0;
	}

	private String normalizeAuthId(String authId) {
		if (authId == null || authId.trim().isEmpty()) {
			throw new IllegalArgumentException("로그인 정보가 필요합니다.");
		}
		String trimmed = authId.trim();
		return trimmed.length() <= 100 ? trimmed : trimmed.substring(0, 100);
	}

	private String normalizeTagCode(String tagCode) {
		if (tagCode == null || tagCode.trim().isEmpty()) {
			throw new IllegalArgumentException("태그 코드가 필요합니다.");
		}
		String trimmed = tagCode.trim();
		if (trimmed.length() > 50) {
			trimmed = trimmed.substring(0, 50);
		}
		return trimmed;
	}

}
