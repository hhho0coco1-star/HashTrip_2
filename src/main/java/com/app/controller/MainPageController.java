package com.app.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.CategoryDTO;
import com.app.dto.InquiryDTO;
import com.app.dto.PlaceDTO;
import com.app.dto.TagCategoryDTO;
import com.app.dto.UsersDTO;
import com.app.service.FaqService;
import com.app.service.NoticeService;
import com.app.service.PlaceService;
import com.app.service.UserAuthenticationService;
import com.app.service.UsersService;
import com.app.service.WishListService;
import com.app.service.impl.RouteService;
import com.app.service.impl.SocialUserProvisionService;
import com.app.util.ApiResponse;

@Controller
public class MainPageController {
    
    @Autowired
    private PlaceService placeService;
    
    @Autowired
    private UsersService usersService;
    
    @Autowired
    private FaqService faqService;
    
    @Autowired
    private UserAuthenticationService userAuthenticationService;
    
    @Autowired
    private NoticeService noticeService;
    
    @Autowired
    private RouteService routeService;

    @Autowired
    private WishListService wishListService;

    @Autowired
    private SocialUserProvisionService socialUserProvisionService;

    // 메인 페이지Preference 카테고리 정의
    private static final Set<String> MAIN_PREF_CATEGORY_KEYS = new LinkedHashSet<>(
            Arrays.asList("LOCATION", "BUDGET", "FOOD_STYLE", "PURPOSE", "INTENSITY"));

    
    // --- 1. 메인 페이지 페이지 이동 ---
    @GetMapping({"/", "/main", "/hashTrip"})
    public String hashTag(Model model, Authentication authentication) {
        
        String currentAuthId = resolveAuthenticatedAuthId(authentication);
        
        // 💡 기존 두 메서드의 논리를 합침: 검색 조건(prefCategory, prefTagCode)을 포함하여 places 가져오기
        List<PlaceDTO> places = placeService.searchPlaces("", null, null, currentAuthId);
        UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);

        model.addAttribute("usersDTO", usersDTO);
        model.addAttribute("places", places);
        // 메인 Preference 카테고리 필터링
        model.addAttribute("preferenceCategories", filterMainPreferenceCategories(routeService.getPreferenceCategories()));
        
        return "mainPage/mainPage";
    }
    
    // --- 2. Ajax 데이터 요청 (검색, 위시리스트 카테고리) ---
    
    @GetMapping("/hashTrip/searchApi")
    @ResponseBody
    public List<PlaceDTO> searchPlacesApi(
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "prefCategory", required = false) String prefCategory,
            @RequestParam(value = "prefTagCode", required = false) String prefTagCode,
            Authentication authentication) {
        
        String currentAuthId = resolveAuthenticatedAuthId(authentication);
        return placeService.searchPlaces(keyword, prefCategory, prefTagCode, currentAuthId);
    }
    
    @GetMapping("/customer/wishlist/categories")
    @ResponseBody
    public Map<String, Object> wishlistCategories(Authentication authentication) {
        Map<String, Object> response = new HashMap<>();

        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            response.put("result", "LOGIN_REQUIRED");
            response.put("categories", new ArrayList<>());
            return response;
        }

        try {
            response.put("result", "SUCCESS");
            response.put("categories", loadActiveCategories(authId));
        } catch (Exception e) {
            response.put("result", "FAIL");
            response.put("categories", new ArrayList<>());
        }
        return response;
    }

    @PostMapping("/customer/wishlist/categories")
    @ResponseBody
    public Map<String, Object> createWishlistCategory(@RequestBody Map<String, String> params, Authentication authentication) {
        Map<String, Object> response = new HashMap<>();

        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            response.put("result", "LOGIN_REQUIRED");
            response.put("categories", new ArrayList<>());
            return response;
        }

        String categoryType = params == null ? null : params.get("categoryType");
        String normalizedCategoryType = normalizeCategoryType(categoryType);
        if (normalizedCategoryType == null) {
            response.put("result", "INVALID_CATEGORY");
            response.put("categories", new ArrayList<>());
            return response;
        }

        try {
            wishListService.createCategory(authId, normalizedCategoryType, "Y");
            response.put("result", "SUCCESS");
            response.put("categories", loadActiveCategories(authId));
        } catch (Exception e) {
            response.put("result", "FAIL");
            response.put("categories", new ArrayList<>());
        }
        return response;
    }
    
    // 추천 여행지 '좋아요' 저장 (보완된 논리)
    @PostMapping("/customer/savePlace")
    @ResponseBody
    public ApiResponse<String> savePlace(@RequestBody Map<String, String> params, Authentication authentication) {
        ApiResponse<String> response = new ApiResponse<>();

        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            response.setBody("LOGIN_REQUIRED");
            return response;
        }

        Long placeNo = parseLong(params == null ? null : params.get("placeNo"));
        if (placeNo == null || placeNo <= 0) {
            response.setBody("INVALID_REQUEST");
            return response;
        }

        String status = params == null ? null : params.get("status");
        // status가 없으면 기본 'Y', trim 후 대문자 처리
        String normalizedStatus = status == null ? "Y" : status.trim().toUpperCase(Locale.ROOT);

        try {
            if ("N".equals(normalizedStatus)) {
                // 찜 해제 (DB 작업)
                wishListService.deleteWishListByPlace(authId, placeNo);
                response.setBody("SUCCESS");
                return response;
            }

            if (!"Y".equals(normalizedStatus)) {
                response.setBody("INVALID_REQUEST");
                return response;
            }

            // 'Y' 상태인 경우 카테고리 확인 후 찜
            Long categoryNo = parseLong(params == null ? null : params.get("categoryNo"));
            if (categoryNo == null || !isUsableCategory(authId, categoryNo)) {
                response.setBody("NEED_CATEGORY");
                return response;
            }

            wishListService.createWishList(authId, placeNo, categoryNo);
            response.setBody("SUCCESS");
        } catch (IllegalArgumentException e) {
            response.setBody("ALREADY_SAVED");
        } catch (Exception e) {
            response.setBody("FAIL");
        }
        return response;
    }

    // --- 3. 일반 페이지 이동 ---
    
    @GetMapping("/hashTrip/privacy")
    public String hashTripPrivacy() {
        return "mainPage/mainPage-privacy";
    }

    @GetMapping("/hashTrip/terms")
    public String hashTripTerms() {
        return "mainPage/mainPage-terms";
    }

    @GetMapping("/hashTrip/location")
    public String hashTripLocationTerms() {
        return "mainPage/mainPage-location";
    }

    @GetMapping("/hashTrip/faq")
    public String hashTripFaq(Model model, Authentication authentication) {
        String currentAuthId = resolveAuthenticatedAuthId(authentication);
        UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
        model.addAttribute("usersDTO", usersDTO);
        model.addAttribute("faqList", faqService.getFaqList());
        return "mainPage/mainPage-faq";
    }

    @GetMapping("/hashTrip/contact")
    public String hashTripContact(Authentication authentication, Model model) {
        String defaultEmail = "";
        String userAuthId = resolveAuthenticatedAuthId(authentication);
        if (userAuthId != null) {
            defaultEmail = userAuthenticationService.getUserEmailByAuthId(userAuthId);
        }
        model.addAttribute("defaultEmail", defaultEmail);
        return "mainPage/mainPage-contact";
    }

    @GetMapping("/hashTrip/notice")
    public String hashTripNotice(Model model) {
        model.addAttribute("noticeList", noticeService.getNoticeList());
        return "mainPage/mainPage-notice";
    }

    // --- 4. 문의사항 제출 ---
    
    @PostMapping("/contact/submit")
    public String submitInquiry(InquiryDTO dto, Authentication authentication, RedirectAttributes ra) {
        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            return "redirect:/auth/login";
        }

        UsersDTO user = usersService.getUserByAuthId(authId);
        dto.setUserNo(user.getUserNo());

        int result = usersService.registerInquiry(dto);
        if (result > 0) {
            ra.addFlashAttribute("msg", "문의가 성공적으로 접수되었습니다.");
            return "redirect:/mypage";
        }

        ra.addFlashAttribute("msg", "접수에 실패했습니다.");
        return "redirect:/hashTrip";
    }

    // --- 5. 헬퍼 메서드 (Helper Methods) ---

    private List<TagCategoryDTO> filterMainPreferenceCategories(List<TagCategoryDTO> categories) {
        List<TagCategoryDTO> source = categories == null ? new ArrayList<>() : categories;
        List<TagCategoryDTO> filtered = new ArrayList<>();

        for (TagCategoryDTO category : source) {
            if (category == null || category.getCategoryKey() == null) {
                continue;
            }
            String key = category.getCategoryKey().trim().toUpperCase(Locale.ROOT);
            if (MAIN_PREF_CATEGORY_KEYS.contains(key)) {
                filtered.add(category);
            }
        }
        return filtered;
    }

    private List<CategoryDTO> loadActiveCategories(String authId) throws Exception {
        List<CategoryDTO> categories = wishListService.getCategoriesByAuthId(authId);
        List<CategoryDTO> activeCategories = new ArrayList<>();
        if (categories == null) {
            return activeCategories;
        }

        for (CategoryDTO category : categories) {
            if (category == null || category.getCategoryNo() == null || category.getCategoryNo() <= 0) {
                continue;
            }
            if (!"N".equalsIgnoreCase(category.getCategoryIsUsed())) {
                activeCategories.add(category);
            }
        }
        return activeCategories;
    }

    private boolean isUsableCategory(String authId, Long categoryNo) throws Exception {
        if (categoryNo == null || categoryNo <= 0) {
            return false;
        }
        List<CategoryDTO> activeCategories = loadActiveCategories(authId);
        for (CategoryDTO category : activeCategories) {
            if (categoryNo.equals(category.getCategoryNo())) {
                return true;
            }
        }
        return false;
    }

    private Long parseLong(String rawValue) {
        if (rawValue == null || rawValue.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(rawValue.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalizeCategoryType(String categoryType) {
        if (categoryType == null) {
            return null;
        }
        String trimmed = categoryType.trim();
        if (trimmed.isEmpty()) {
            return null;
        }
        if (trimmed.length() <= 100) {
            return trimmed;
        }
        return trimmed.substring(0, 100);
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
                    // Ignore provisioning errors here and try resolving existing auth id.
                }
                String socialAuthId = socialUserProvisionService.resolveSocialAuthId(
                        token.getAuthorizedClientRegistrationId(),
                        oAuth2User.getAttributes());
                if (socialAuthId != null && !socialAuthId.trim().isEmpty()) {
                    return socialAuthId.trim();
                }
            }
        }

        String authId = authentication.getName();
        if (authId == null || authId.trim().isEmpty()) {
            return null;
        }
        return authId.trim();
    }
}
