package com.app.dao;

import java.util.List;

import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;

public interface UsersDAO {
	UsersDTO getUserByAuthId(String authId);

	List<UserTagMapDTO> getUserTagsByAuthId(String authId);

	List<TagMasterDTO> getTagMasterList();

	int countTagMasterByTagCode(String tagCode);

	int insertUserTagByAuthId(String authId, String tagCode, String questionId);

	int deleteUserTagByAuthId(String authId, String tagCode);
}
