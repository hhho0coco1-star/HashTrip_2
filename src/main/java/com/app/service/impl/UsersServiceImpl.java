package com.app.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.app.dao.UsersDAO;
import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;
import com.app.service.UsersService;

@Service
public class UsersServiceImpl implements UsersService {

	@Autowired
	UsersDAO usersDAO;

	@Autowired
	private PasswordEncoder passwordEncoder;

	@Override
	public UsersDTO getUserByAuthId(String authId) {
		UsersDTO usersDTO = usersDAO.getUserByAuthId(authId);
		return usersDTO;
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public UsersDTO updateProfileByAuthId(String authId, UsersDTO users) {
		String safeAuthId = normalizeAuthId(authId);
		UsersDTO current = usersDAO.getUserByAuthId(safeAuthId);
		if (current == null) {
			throw new IllegalArgumentException("해당 회원을 찾을 수 없습니다.");
		}
		if (users == null) {
			throw new IllegalArgumentException("저장할 회원정보가 없습니다.");
		}

		UsersDTO normalized = sanitizeProfileInput(users);
		normalized.setUserGender(resolveGenderForUpdate(current.getUserGender(), users.getUserGender()));

		int updatedRows = usersDAO.updateUserProfileByAuthId(safeAuthId, normalized);
		if (updatedRows == 0) {
			throw new IllegalArgumentException("회원정보 저장에 실패했습니다.");
		}

		if (hasAnyAddressInput(normalized) || hasExistingAddress(current)) {
			usersDAO.upsertUserAddressByAuthId(safeAuthId, normalized);
		}

		return usersDAO.getUserByAuthId(safeAuthId);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void changePasswordByAuthId(String authId, String currentPassword, String newPassword) {
		String safeAuthId = normalizeAuthId(authId);
		if (!StringUtils.hasText(currentPassword) || !StringUtils.hasText(newPassword)) {
			throw new IllegalArgumentException("현재 비밀번호와 새 비밀번호를 모두 입력해 주세요.");
		}

		String currentPasswordTrimmed = currentPassword.trim();
		String newPasswordTrimmed = newPassword.trim();
		if (newPasswordTrimmed.length() < 8) {
			throw new IllegalArgumentException("새 비밀번호는 8자 이상이어야 합니다.");
		}
		if (currentPasswordTrimmed.equals(newPasswordTrimmed)) {
			throw new IllegalArgumentException("새 비밀번호는 현재 비밀번호와 달라야 합니다.");
		}

		String storedPassword = usersDAO.findAuthPasswordByAuthId(safeAuthId);
		if (!StringUtils.hasText(storedPassword)) {
			throw new IllegalArgumentException("비밀번호 정보를 확인할 수 없습니다.");
		}
		if (!passwordEncoder.matches(currentPasswordTrimmed, storedPassword)) {
			throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
		}

		String encodedPassword = passwordEncoder.encode(newPasswordTrimmed);
		int updatedRows = usersDAO.updateAuthPasswordByAuthId(safeAuthId, encodedPassword);
		if (updatedRows != 1) {
			throw new IllegalArgumentException("비밀번호 변경에 실패했습니다.");
		}
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
	public List<UserTagMapDTO> getUserTagsByUserNo(Long userNo) {
		return usersDAO.getUserTagsByUserNo(userNo);
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
			throw new IllegalArgumentException("존재하지 않는 태그 코드는 사용할 수 없습니다.");
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
			throw new IllegalArgumentException("로그인 상태가 유효하지 않습니다.");
		}
		String trimmed = authId.trim();
		return trimmed.length() <= 100 ? trimmed : trimmed.substring(0, 100);
	}

	private String normalizeTagCode(String tagCode) {
		if (tagCode == null || tagCode.trim().isEmpty()) {
			throw new IllegalArgumentException("태그 코드가 비어 있습니다.");
		}
		String trimmed = tagCode.trim();
		if (trimmed.length() > 50) {
			trimmed = trimmed.substring(0, 50);
		}
		return trimmed;
	}

	private UsersDTO sanitizeProfileInput(UsersDTO users) {
		UsersDTO normalized = new UsersDTO();

		String userNickName = safeText(users.getUserNickName(), 50);
		String userPhone = safeText(users.getUserPhoneNumber(), 50);
		String userProfileImg = safeText(users.getUserProfileImg(), 255);
		String zipCode = safeText(users.getUserZipCode(), 6);
		String baseAddress = safeText(users.getUserBaseAddress(), 255);
		String detailAddress = safeText(users.getUserDetailAddress(), 255);

		if (!StringUtils.hasText(userNickName)) {
			throw new IllegalArgumentException("닉네임은 필수 입력값입니다.");
		}

		normalized.setUserNickName(userNickName);
		normalized.setUserPhoneNumber(userPhone);
		normalized.setUserProfileImg(userProfileImg);
		normalized.setUserZipCode(zipCode);
		normalized.setUserBaseAddress(baseAddress);
		normalized.setUserDetailAddress(detailAddress);
		return normalized;
	}

	private String resolveGenderForUpdate(String currentGender, String requestedGender) {
		String normalizedCurrentGender = normalizeGender(currentGender);
		if (StringUtils.hasText(normalizedCurrentGender)) {
			return normalizedCurrentGender;
		}
		if (StringUtils.hasText(currentGender)) {
			return currentGender.trim();
		}

		if (!StringUtils.hasText(requestedGender)) {
			return null;
		}

		String normalizedRequestedGender = normalizeGender(requestedGender);
		if (!StringUtils.hasText(normalizedRequestedGender)) {
			throw new IllegalArgumentException("성별은 M 또는 F만 입력할 수 있습니다.");
		}
		return normalizedRequestedGender;
	}

	private String safeText(String value, int maxLength) {
		if (!StringUtils.hasText(value)) {
			return null;
		}
		String trimmed = value.trim();
		return trimmed.length() > maxLength ? trimmed.substring(0, maxLength) : trimmed;
	}

	private String normalizeGender(String userGender) {
		if (!StringUtils.hasText(userGender)) {
			return null;
		}
		String value = userGender.trim().toUpperCase();
		return ("M".equals(value) || "F".equals(value)) ? value : null;
	}

	private boolean hasAnyAddressInput(UsersDTO users) {
		return StringUtils.hasText(users.getUserZipCode())
				|| StringUtils.hasText(users.getUserBaseAddress())
				|| StringUtils.hasText(users.getUserDetailAddress());
	}

	private boolean hasExistingAddress(UsersDTO users) {
		return users != null && users.getUserAddressNo() != null;
	}

	@Override
	@Transactional(rollbackFor = Exception.class) // 삭제와 삽입을 하나의 트랜잭션으로 묶음
	public void saveUserAnalysisResults(String authId, List<Map<String, Object>> resultData) throws Exception {
	    // 1. 기존에 작성된 보안 로직을 그대로 활용하여 authId 검증
	    String safeAuthId = normalizeAuthId(authId);
	    
	    // 2. 해당 사용자의 UserNo 조회 (이미 DAO에 있는 기능을 활용하거나 새로 연결)
	    // 기존 코드의 흐름에 따라 usersDAO를 호출합니다.
	    UsersDTO user = usersDAO.getUserByAuthId(safeAuthId);
	    if (user == null) {
	        throw new IllegalArgumentException("해당 회원을 찾을 수 없습니다.");
	    }
	    Long userNo = user.getUserNo();

	    // 3. 기존 성향 태그 삭제 (중복 방지 및 초기화)
	    // 만약 DAO에 deleteUserTagsByUserNo가 없다면 호출명을 맞춰주세요.
	    usersDAO.deleteUserTagsByUserNo(userNo);

	    // 4. 새로운 성향 분석 결과 삽입
	    if (resultData != null && !resultData.isEmpty()) {
	        // DB 전송을 위한 파라미터 맵 생성
	        Map<String, Object> params = new java.util.HashMap<>();
	        params.put("userNo", userNo);
	        params.put("list", resultData);
	        System.out.println(userNo);
	        
	        // DAO의 일괄 삽입 메서드 호출
	        usersDAO.insertUserAnalysisTags(params);
	    }
	}

}
