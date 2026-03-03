package com.app.controller;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.CommunityDTO;
import com.app.dto.InquiryDTO;
import com.app.dto.PlaceReviewDTO;
import com.app.dto.TagMasterDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;
import com.app.dto.WishListDTO;
import com.app.service.PlaceService;
import com.app.service.ProfileImageStorageService;
import com.app.service.UsersService;
import com.app.service.WishListService;
import com.app.service.impl.CommunityService;
import com.app.service.impl.SocialUserProvisionService;

@Controller
public class MyPageController {

	private static final int REVIEW_PAGE_SIZE = 10;
	private static final int REVIEW_PREVIEW_SIZE = 4;

	@Autowired
	private UsersService usersService;

	@Autowired
	private PlaceService placeService;

	@Autowired
	private WishListService wishListService;

	@Autowired
	private CommunityService communityService;

	@Autowired
	private ProfileImageStorageService profileImageStorageService;

	@Autowired
	private SocialUserProvisionService socialUserProvisionService;

	@GetMapping({ "/mypage", "/mypage/", "/myPage", "/my-page", "/hashTrip/mypage" })
	public String mypage(
			@RequestParam(name = "placePage", defaultValue = "1") int placePage,
			@RequestParam(name = "communityPage", defaultValue = "1") int communityPage,
			@RequestParam(name = "placeSort", defaultValue = "latest") String placeSort,
			@RequestParam(name = "communitySort", defaultValue = "latest") String communitySort,
			@RequestParam(name = "placeExpanded", defaultValue = "N") String placeExpanded,
			@RequestParam(name = "communityExpanded", defaultValue = "N") String communityExpanded,
			Authentication authentication,
			Model model) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			return "redirect:/auth/login";
		}

		UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
		if (usersDTO == null) {
			return "redirect:/auth/login";
		}
		List<UserTagMapDTO> userTagList = usersService.getUserTagsByAuthId(currentAuthId);
		List<TagMasterDTO> tagMasterList = usersService.getTagMasterList();

		String resolvedPlaceSort = normalizeReviewSort(placeSort);
		String resolvedCommunitySort = normalizeReviewSort(communitySort);
		boolean placeExpandedFlag = isExpanded(placeExpanded);
		boolean communityExpandedFlag = isExpanded(communityExpanded);

		int placeReviewCount = placeService.getMyPlaceReviewCount(currentAuthId);
		int placeTotalPages = Math.max(1, (int) Math.ceil(placeReviewCount / (double) REVIEW_PAGE_SIZE));
		int placeCurrentPage = Math.max(1, Math.min(placePage, placeTotalPages));
		List<PlaceReviewDTO> placeReviewList = placeReviewCount == 0
				? Collections.emptyList()
				: placeService.getMyPlaceReviews(currentAuthId, placeCurrentPage, REVIEW_PAGE_SIZE, resolvedPlaceSort);

		int communityReviewCount = communityService.getMyCommunityReviewCount(currentAuthId);
		int communityTotalPages = Math.max(1, (int) Math.ceil(communityReviewCount / (double) REVIEW_PAGE_SIZE));
		int communityCurrentPage = Math.max(1, Math.min(communityPage, communityTotalPages));
		List<CommunityDTO> communityReviewList = communityReviewCount == 0
				? Collections.emptyList()
				: communityService.getMyCommunityReviews(currentAuthId, communityCurrentPage, REVIEW_PAGE_SIZE, resolvedCommunitySort);

		int wishCount = wishListService.getWishPlaceCountByAuthId(currentAuthId);
		List<WishListDTO> wishEntryList = wishCount == 0
				? Collections.emptyList()
				: wishListService.getWishListWithPlaceByAuthId(currentAuthId);

		String kakaoMapAppKey = System.getenv("KAKAO_MAP_APP_KEY");
		if (kakaoMapAppKey == null || kakaoMapAppKey.isBlank()) {
			kakaoMapAppKey = System.getProperty("kakao.map.appkey", "");
		}

		model.addAttribute("usersDTO", usersDTO);
		model.addAttribute("userTagList", userTagList);
		model.addAttribute("tagMasterList", tagMasterList);
		model.addAttribute("currentAuthId", currentAuthId);
		model.addAttribute("placeReviewList", placeReviewList);
		model.addAttribute("placeReviewCount", placeReviewCount);
		model.addAttribute("placeCurrentPage", placeCurrentPage);
		model.addAttribute("placeTotalPages", placeTotalPages);
		model.addAttribute("placeSort", resolvedPlaceSort);
		model.addAttribute("placeExpanded", placeExpandedFlag);

		model.addAttribute("communityReviewList", communityReviewList);
		model.addAttribute("communityReviewCount", communityReviewCount);
		model.addAttribute("communityCurrentPage", communityCurrentPage);
		model.addAttribute("communityTotalPages", communityTotalPages);
		model.addAttribute("communitySort", resolvedCommunitySort);
		model.addAttribute("communityExpanded", communityExpandedFlag);

		model.addAttribute("reviewCount", placeReviewCount + communityReviewCount);
		model.addAttribute("wishCount", wishCount);
		model.addAttribute("wishEntryList", wishEntryList);
		model.addAttribute("reviewPageSize", REVIEW_PAGE_SIZE);
		model.addAttribute("reviewPreviewSize", REVIEW_PREVIEW_SIZE);
		model.addAttribute("kakaoMapAppKey", kakaoMapAppKey);
		
		// 1:1 문의
		List<InquiryDTO> inquiryList = usersDTO.getUserNo() == null
				? Collections.emptyList()
				: usersService.getMyInquiries(usersDTO.getUserNo());
	    model.addAttribute("inquiryList", inquiryList); // JSP로 전달
	    
		return "mypage";
	}

	@GetMapping("/mypage/edit")
	public String mypageEdit(
			Authentication authentication,
			Model model) {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			return "redirect:/auth/login";
		}

		UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
		if (usersDTO == null) {
			return "redirect:/mypage";
		}
		model.addAttribute("usersDTO", usersDTO);
		model.addAttribute("currentAuthId", currentAuthId);
		return "mypage-edit";
	}

	@PostMapping("/mypage/edit")
	public String updateMypageProfile(
			Authentication authentication,
			@ModelAttribute("usersDTO") UsersDTO usersDTO,
			@RequestParam(value = "profileImage", required = false) MultipartFile profileImage,
			RedirectAttributes redirectAttributes,
			Model model) {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			return "redirect:/auth/login";
		}

		UsersDTO currentUsersDTO = usersService.getUserByAuthId(currentAuthId);
		String savedProfileImagePath = null;
		try {
			savedProfileImagePath = profileImageStorageService.store(profileImage);
			if (StringUtils.hasText(savedProfileImagePath)) {
				usersDTO.setUserProfileImg(savedProfileImagePath);
			}

			usersService.updateProfileByAuthId(currentAuthId, usersDTO);
			if (StringUtils.hasText(savedProfileImagePath)
					&& currentUsersDTO != null
					&& StringUtils.hasText(currentUsersDTO.getUserProfileImg())
					&& !savedProfileImagePath.equals(currentUsersDTO.getUserProfileImg())) {
				profileImageStorageService.deleteIfManaged(currentUsersDTO.getUserProfileImg());
			}
			redirectAttributes.addFlashAttribute("message", "회원 정보가 수정되었습니다.");
			return "redirect:/mypage";
		} catch (IllegalArgumentException e) {
			if (StringUtils.hasText(savedProfileImagePath)) {
				profileImageStorageService.deleteIfManaged(savedProfileImagePath);
			}
			if (!StringUtils.hasText(usersDTO.getUserProfileImg())) {
				UsersDTO fallbackUser = usersService.getUserByAuthId(currentAuthId);
				if (fallbackUser != null) {
					usersDTO.setUserProfileImg(fallbackUser.getUserProfileImg());
				}
			}
			model.addAttribute("usersDTO", usersDTO);
			model.addAttribute("errorMessage", e.getMessage());
			model.addAttribute("currentAuthId", currentAuthId);
			return "mypage-edit";
		} catch (Exception e) {
			if (StringUtils.hasText(savedProfileImagePath)) {
				profileImageStorageService.deleteIfManaged(savedProfileImagePath);
			}
			if (!StringUtils.hasText(usersDTO.getUserProfileImg())) {
				UsersDTO fallbackUser = usersService.getUserByAuthId(currentAuthId);
				if (fallbackUser != null) {
					usersDTO.setUserProfileImg(fallbackUser.getUserProfileImg());
				}
			}
			model.addAttribute("usersDTO", usersDTO);
			model.addAttribute("errorMessage", "회원정보 수정 중 오류가 발생했습니다.");
			model.addAttribute("currentAuthId", currentAuthId);
			return "mypage-edit";
		}
	}

	@PostMapping("/mypage/password")
	public String updateMypagePassword(
			Authentication authentication,
			@RequestParam String currentPassword,
			@RequestParam String newPassword,
			@RequestParam String confirmPassword,
			RedirectAttributes redirectAttributes,
			Model model) {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			return "redirect:/auth/login";
		}
		if (newPassword == null || !newPassword.equals(confirmPassword)) {
			UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
			model.addAttribute("usersDTO", usersDTO);
			model.addAttribute("currentAuthId", currentAuthId);
			model.addAttribute("passwordErrorMessage", "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
			return "mypage-edit";
		}

		try {
			usersService.changePasswordByAuthId(currentAuthId, currentPassword, newPassword);
			redirectAttributes.addFlashAttribute("passwordMessage", "비밀번호가 변경되었습니다.");
			return "redirect:/mypage/edit";
		} catch (IllegalArgumentException e) {
			UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
			model.addAttribute("usersDTO", usersDTO);
			model.addAttribute("currentAuthId", currentAuthId);
			model.addAttribute("passwordErrorMessage", e.getMessage());
			return "mypage-edit";
		}
	}

	@PostMapping("/mypage/tags/add")
	@ResponseBody
	public Map<String, Object> addMyTag(
			@RequestParam String tagCode,
			Authentication authentication) {
		Map<String, Object> response = new HashMap<>();
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			response.put("success", false);
			response.put("message", "로그인이 필요합니다.");
			return response;
		}

		try {
			boolean added = usersService.addUserTagByAuthId(currentAuthId, tagCode);
			response.put("success", added);
			response.put("message", added ? "태그가 추가되었습니다." : "이미 선택된 태그입니다.");
		} catch (IllegalArgumentException e) {
			response.put("success", false);
			response.put("message", e.getMessage());
		}
		return response;
	}

	@PostMapping("/mypage/tags/remove")
	@ResponseBody
	public Map<String, Object> removeMyTag(
			@RequestParam String tagCode,
			Authentication authentication) {
		Map<String, Object> response = new HashMap<>();
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			response.put("success", false);
			response.put("message", "로그인이 필요합니다.");
			return response;
		}

		try {
			boolean removed = usersService.removeUserTagByAuthId(currentAuthId, tagCode);
			response.put("success", removed);
			response.put("message", removed ? "태그가 제거되었습니다." : "제거할 태그가 없습니다.");
		} catch (IllegalArgumentException e) {
			response.put("success", false);
			response.put("message", e.getMessage());
		}
		return response;
	}

	private String resolveAuthenticatedAuthId(Authentication authentication) {
		if (authentication == null
				|| !authentication.isAuthenticated()
				|| authentication instanceof AnonymousAuthenticationToken) {
			return null;
		}

		if (authentication instanceof OAuth2AuthenticationToken) {
			OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) authentication;
			Object principal = token.getPrincipal();
			if (principal instanceof OAuth2User) {
				OAuth2User oAuth2User = (OAuth2User) principal;
				try {
					socialUserProvisionService.provisionIfMissing(
							token.getAuthorizedClientRegistrationId(),
							oAuth2User.getAttributes());
				} catch (Exception ignored) {
					// Ignore provisioning exceptions here and try to resolve existing auth id.
				}
				String socialAuthId = socialUserProvisionService.resolveSocialAuthId(
						token.getAuthorizedClientRegistrationId(),
						oAuth2User.getAttributes());
				if (StringUtils.hasText(socialAuthId)) {
					return socialAuthId.trim();
				}
			}
		}

		String authId = authentication.getName();
		if (!StringUtils.hasText(authId)) {
			return null;
		}
		return authId.trim();
	}

	private String normalizeReviewSort(String sortType) {
		if (sortType == null) {
			return "latest";
		}
		String normalized = sortType.trim().toLowerCase();
		if ("oldest".equals(normalized) || "rating".equals(normalized)) {
			return normalized;
		}
		return "latest";
	}

	private boolean isExpanded(String expanded) {
		return "Y".equalsIgnoreCase(expanded);
	}
	
	@PostMapping("/contact/inquiry/delete")
	public String deleteInquiry(@RequestParam("inquiryNo") Long inquiryNo, RedirectAttributes ra) {
	    int result = usersService.removeInquiry(inquiryNo);
	    if(result > 0) {
	        ra.addFlashAttribute("msg", "문의가 삭제되었습니다.");
	    }
	    return "redirect:/mypage";
	}
	
	// 1. 수정 페이지로 이동 (SELECT 필요)
	@GetMapping("/contact/inquiry/edit/{inquiryNo}")
	public String editForm(@PathVariable("inquiryNo") Long inquiryNo, Model model) {
	    // 지금 작성하신 UPDATE 쿼리가 아니라, 기존에 있던 SELECT 쿼리를 써야 합니다!
	    InquiryDTO inquiry = usersService.getInquiryDetail(inquiryNo); 
	    model.addAttribute("inquiry", inquiry);
	    model.addAttribute("isEdit", true);
	    return "mainPage/mainPage-contact";
	}

	// 2. 수정 실행
	@PostMapping("/contact/inquiry/update")
	public String updateInquiry(InquiryDTO dto, RedirectAttributes ra) {
	    int result = usersService.modifyInquiry(dto);
	    if(result > 0) {
	        ra.addFlashAttribute("msg", "문의 내용이 성공적으로 수정되었습니다.");
	    }
	    return "redirect:/mypage";
	}
	
}

