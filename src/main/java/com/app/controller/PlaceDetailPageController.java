package com.app.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.CategoryDTO;
import com.app.dto.PhotoDataDTO;
import com.app.dto.PlaceDTO;
import com.app.dto.WishListDTO;
import com.app.service.PlaceService;
import com.app.service.WishListService;

@Controller
public class PlaceDetailPageController {

	private static final int MAX_REVIEW_IMAGE_COUNT = 10;
	private static final int MAX_REVIEW_IMAGE_SIZE_BYTES = 5 * 1024 * 1024;

	@Autowired
	private PlaceService placeService;

	@Autowired
	private WishListService wishListService;

	@GetMapping("/place/detail")
	public String placeDetailPage(
			@RequestParam(name = "place_no", required = false) Long placeNo,
			@RequestParam(name = "placeNo", required = false) Long legacyPlaceNo,
			@RequestParam(name = "openWishlist", required = false, defaultValue = "false") boolean openWishlist,
			Authentication authentication,
			Model model) throws Exception {
		Long resolvedPlaceNo = placeNo != null ? placeNo : (legacyPlaceNo != null ? legacyPlaceNo : 49070L);
		PlaceDTO place = placeService.getPlaceByPlaceNo(resolvedPlaceNo);
		String currentAuthId = resolveAuthenticatedAuthId(authentication);

		String kakaoMapAppKey = System.getenv("KAKAO_MAP_APP_KEY");
		if (kakaoMapAppKey == null || kakaoMapAppKey.isBlank()) {
			kakaoMapAppKey = System.getProperty("kakao.map.appkey", "");
		}

		model.addAttribute("placeNo", resolvedPlaceNo);
		model.addAttribute("place", place);
		model.addAttribute("reviewList", placeService.getPlaceReviewsByPlaceNo(resolvedPlaceNo));
		model.addAttribute("hoursList", placeService.getPlaceHoursByPlaceNo(resolvedPlaceNo));
		model.addAttribute("wishCount", wishListService.getWishUserCountByPlaceNo(resolvedPlaceNo));
		model.addAttribute("currentAuthId", currentAuthId);
		model.addAttribute("kakaoMapAppKey", kakaoMapAppKey);
		model.addAttribute("openWishlist", openWishlist);

		if (currentAuthId != null) {
			model.addAttribute("wishlistCategoryList", wishListService.getCategoriesByAuthId(currentAuthId));
			model.addAttribute("wishlistList", wishListService.getWishListByAuthIdAndPlaceNo(currentAuthId, resolvedPlaceNo));
		} else {
			model.addAttribute("wishlistCategoryList", Collections.emptyList());
			model.addAttribute("wishlistList", Collections.emptyList());
		}

		if (place == null) {
			model.addAttribute("tagNameList", Collections.emptyList());
			model.addAttribute("photoUrlList", Collections.emptyList());
			return "place/detail";
		}

		model.addAttribute("tagNameList", placeService.getPlaceTagNamesByPlaceNo(resolvedPlaceNo));
		model.addAttribute("photoUrlList", placeService.getPlacePhotoUrlsByPlaceNo(resolvedPlaceNo));
		return "place/detail";
	}

	@PostMapping("/place/{placeNo}/reviews")
	public String createPlaceReview(
			@PathVariable Long placeNo,
			@RequestParam String commentContent,
			@RequestParam(name = "rating", required = false, defaultValue = "5") Integer rating,
			@RequestParam(name = "reviewImages", required = false) MultipartFile[] reviewImages,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("reviewActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		try {
			List<PhotoDataDTO> photoDataList = buildReviewPhotoData(reviewImages);
			placeService.createPlaceReview(placeNo, commentContent, rating, currentAuthId, photoDataList);
			redirectAttributes.addFlashAttribute("reviewActionMessage", "리뷰가 등록되었습니다.");
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("reviewActionError", e.getMessage());
		} catch (IOException e) {
			redirectAttributes.addFlashAttribute("reviewActionError", "이미지 업로드에 실패했습니다.");
		}
		return buildDetailRedirect(placeNo);
	}

	@PostMapping("/place/{placeNo}/reviews/{commentNo}/update")
	public String updatePlaceReview(
			@PathVariable Long placeNo,
			@PathVariable Long commentNo,
			@RequestParam String commentContent,
			@RequestParam(name = "rating", required = false, defaultValue = "5") Integer rating,
			@RequestParam(name = "deletePhotoNoList", required = false) List<Long> deletePhotoNoList,
			@RequestParam(name = "reviewImages", required = false) MultipartFile[] reviewImages,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("reviewActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		try {
			List<PhotoDataDTO> photoDataList = buildReviewPhotoData(reviewImages);
			boolean updated = placeService.updatePlaceReview(
					placeNo,
					commentNo,
					commentContent,
					rating,
					currentAuthId,
					deletePhotoNoList,
					photoDataList);
			if (updated) {
				redirectAttributes.addFlashAttribute("reviewActionMessage", "리뷰가 수정되었습니다.");
			} else {
				redirectAttributes.addFlashAttribute("reviewActionError", "본인 리뷰만 수정할 수 있습니다.");
			}
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("reviewActionError", e.getMessage());
		} catch (IOException e) {
			redirectAttributes.addFlashAttribute("reviewActionError", "Image upload failed.");
		}
		return buildDetailRedirect(placeNo);
	}

	@PostMapping("/place/{placeNo}/wishlist/categories")
	public String createWishlistCategory(
			@PathVariable Long placeNo,
			@RequestParam String categoryType,
			@RequestParam(name = "categoryIsUsed", required = false, defaultValue = "Y") String categoryIsUsed,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("wishlistActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		try {
			CategoryDTO categoryDTO = wishListService.createCategory(currentAuthId, categoryType, categoryIsUsed);
			redirectAttributes.addFlashAttribute("wishlistActionMessage",
					"찜 카테고리가 생성되었습니다: " + categoryDTO.getCategoryType());
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("wishlistActionError", e.getMessage());
		}
		return buildWishlistRedirect(placeNo);
	}

	@PostMapping("/place/{placeNo}/wishlist/categories/{categoryNo}/usage")
	public String updateWishlistCategoryUsage(
			@PathVariable Long placeNo,
			@PathVariable Long categoryNo,
			@RequestParam String categoryIsUsed,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("wishlistActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		try {
			boolean updated = wishListService.updateCategoryUsage(currentAuthId, categoryNo, categoryIsUsed);
			if (updated) {
				redirectAttributes.addFlashAttribute("wishlistActionMessage", "카테고리 사용여부가 변경되었습니다.");
			} else {
				redirectAttributes.addFlashAttribute("wishlistActionError", "카테고리를 찾을 수 없습니다.");
			}
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("wishlistActionError", e.getMessage());
		}
		return buildWishlistRedirect(placeNo);
	}

	@PostMapping("/place/{placeNo}/wishlist")
	public String createWishlist(
			@PathVariable Long placeNo,
			@RequestParam Long categoryNo,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("wishlistActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		try {
			WishListDTO wishlistDTO = wishListService.createWishList(currentAuthId, placeNo, categoryNo);
			redirectAttributes.addFlashAttribute("wishlistActionMessage",
					"장소를 찜했습니다. wish_no: " + wishlistDTO.getWishNo());
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("wishlistActionError", e.getMessage());
		}
		return buildWishlistRedirect(placeNo);
	}

	@PostMapping("/place/{placeNo}/wishlist/{wishNo}/delete")
	public String deleteWishlist(
			@PathVariable Long placeNo,
			@PathVariable Long wishNo,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("wishlistActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		try {
			boolean deleted = wishListService.deleteWishList(currentAuthId, wishNo);
			if (deleted) {
				redirectAttributes.addFlashAttribute("wishlistActionMessage", "찜이 삭제되었습니다.");
			} else {
				redirectAttributes.addFlashAttribute("wishlistActionError", "찜 정보를 찾을 수 없습니다.");
			}
		} catch (IllegalArgumentException e) {
			redirectAttributes.addFlashAttribute("wishlistActionError", e.getMessage());
		}
		return buildWishlistRedirect(placeNo);
	}

	@PostMapping("/place/{placeNo}/reviews/{commentNo}/delete")
	public String deletePlaceReview(
			@PathVariable Long placeNo,
			@PathVariable Long commentNo,
			Authentication authentication,
			RedirectAttributes redirectAttributes) throws Exception {
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		if (currentAuthId == null) {
			redirectAttributes.addFlashAttribute("reviewActionError", "로그인이 필요합니다.");
			return "redirect:/auth/login";
		}

		boolean deleted = placeService.deletePlaceReview(placeNo, commentNo, currentAuthId);
		if (deleted) {
			redirectAttributes.addFlashAttribute("reviewActionMessage", "리뷰가 삭제되었습니다.");
		} else {
			redirectAttributes.addFlashAttribute("reviewActionError", "본인 리뷰만 삭제할 수 있습니다.");
		}
		return buildDetailRedirect(placeNo);
	}

	@GetMapping("/place/review-photo/{photoNo}")
	@ResponseBody
	public ResponseEntity<byte[]> getReviewPhoto(@PathVariable Long photoNo) throws Exception {
		PhotoDataDTO photoData = placeService.getReviewPhotoByPhotoNo(photoNo);
		if (photoData == null || photoData.getPhotoBinary() == null || photoData.getPhotoBinary().length == 0) {
			return ResponseEntity.notFound().build();
		}

		MediaType mediaType = MediaType.APPLICATION_OCTET_STREAM;
		if (StringUtils.hasText(photoData.getPhotoMimeType())) {
			try {
				mediaType = MediaType.parseMediaType(photoData.getPhotoMimeType());
			} catch (Exception ignored) {
				mediaType = MediaType.APPLICATION_OCTET_STREAM;
			}
		}

		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(mediaType);
		headers.setCacheControl(CacheControl.noCache().getHeaderValue());
		return ResponseEntity.ok().headers(headers).body(photoData.getPhotoBinary());
	}

	private String resolveAuthenticatedAuthId(Authentication authentication) {
		if (authentication == null
				|| !authentication.isAuthenticated()
				|| authentication instanceof AnonymousAuthenticationToken) {
			return null;
		}
		String authId = authentication.getName();
		if (authId == null || authId.trim().isEmpty()) {
			return null;
		}
		return authId.trim();
	}

	private List<PhotoDataDTO> buildReviewPhotoData(MultipartFile[] reviewImages) throws IOException {
		if (reviewImages == null || reviewImages.length == 0) {
			return Collections.emptyList();
		}

		List<PhotoDataDTO> photoDataList = new ArrayList<>();
		for (MultipartFile reviewImage : reviewImages) {
			if (reviewImage == null || reviewImage.isEmpty()) {
				continue;
			}

			if (photoDataList.size() >= MAX_REVIEW_IMAGE_COUNT) {
				throw new IllegalArgumentException("You can upload up to " + MAX_REVIEW_IMAGE_COUNT + " images.");
			}

			String contentType = reviewImage.getContentType();
			if (!StringUtils.hasText(contentType) || !contentType.startsWith("image/")) {
				throw new IllegalArgumentException("Only image files can be uploaded.");
			}

			if (reviewImage.getSize() > MAX_REVIEW_IMAGE_SIZE_BYTES) {
				throw new IllegalArgumentException("Each image must be 5MB or less.");
			}

			PhotoDataDTO photoData = new PhotoDataDTO();
			photoData.setPhotoMimeType(contentType);
			photoData.setPhotoFileName(resolveSafeFileName(reviewImage.getOriginalFilename()));
			photoData.setPhotoBinary(reviewImage.getBytes());
			photoDataList.add(photoData);
		}

		return photoDataList;
	}

	private String resolveSafeFileName(String originalFilename) {
		if (!StringUtils.hasText(originalFilename)) {
			return null;
		}

		String normalized = originalFilename.trim().replace("\\", "_").replace("/", "_");
		if (normalized.length() > 255) {
			return normalized.substring(0, 255);
		}
		return normalized.toLowerCase(Locale.ROOT);
	}

	private String buildDetailRedirect(Long placeNo) {
		return buildDetailRedirect(placeNo, "section-review");
	}

	private String buildDetailRedirect(Long placeNo, String sectionId) {
		StringBuilder redirect = new StringBuilder("redirect:/place/detail?place_no=").append(placeNo);
		if (sectionId != null && !sectionId.trim().isEmpty()) {
			redirect.append("#").append(sectionId.trim());
		}
		return redirect.toString();
	}

	private String buildWishlistRedirect(Long placeNo) {
		return "redirect:/place/detail?place_no=" + placeNo + "&openWishlist=true#section-overview";
	}
}
