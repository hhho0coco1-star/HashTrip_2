package com.app.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.InquiryDTO;
import com.app.dto.PlaceDTO;
import com.app.dto.UsersDTO;
import com.app.service.FaqService;
import com.app.service.NoticeService;
import com.app.service.PlaceService;
import com.app.service.UserAuthenticationService;
import com.app.service.UsersService;
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
	
	@GetMapping({"/", "/main", "/hashTrip"}) // 메인 페이지
	public String hashTag(Model model, Authentication authentication) {
		
		List<PlaceDTO> list = placeService.searchPlaces("");
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		
		UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
		
		model.addAttribute("usersDTO", usersDTO);
		model.addAttribute("places", list);
		
		return "mainPage/mainPage";
	}
	
	// 2. [추가] Ajax 검색 전용 메서드 (데이터만 리턴)
    @GetMapping("/hashTrip/searchApi") // 자바스크립트의 url과 맞춰야 함
    @ResponseBody // 리턴되는 리스트를 JSON 형태로 변환해서 응답함
    public List<PlaceDTO> searchPlacesApi(@RequestParam(value="keyword", required=false) String keyword) {
        // keyword가 있으면 전체 검색, 없으면 10개 리턴 (SQL에서 처리됨)
        return placeService.searchPlaces(keyword);
    }
	
	@GetMapping("/hashTrip/privacy") // 메인 페이지 개인정보처리방침
	public String hashTrip_privacy() {
		return "mainPage/mainPage-privacy";
	}
	
	@GetMapping("/hashTrip/terms") // 메인 페이지 이용약관
	public String hashTrip_terms() {
	    return "mainPage/mainPage-terms"; 
	}
	
	@GetMapping("/hashTrip/location") // 메인 페이지 위치기반 서비스
	public String hashTrip_locationTerms() {
	    return "mainPage/mainPage-location"; 
	}
	
	@GetMapping("/hashTrip/faq") // 메인 페이지 자주묻는질문
	public String hashTrip_faq(Model model, Authentication authentication) {
		
		String currentAuthId = resolveAuthenticatedAuthId(authentication);
		UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
		
		model.addAttribute("usersDTO", usersDTO);
		model.addAttribute("faqList", faqService.getFaqList());
		
	    return "mainPage/mainPage-faq"; 
	}
	
	@GetMapping("/hashTrip/contact") // 메인 페이지 1:1문의
	public String hashTrip_contact(Authentication authentication, Model model) {
		
		String defaultEmail = "";
		
		// 1. 로그인이 되어 있는지 확인 (null 체크)
	    if (authentication != null && authentication.isAuthenticated()) {
	        String userAuthId = authentication.getName();
	        // 2. 로그인된 경우에만 이메일 가져오기
	        defaultEmail = userAuthenticationService.getUserEmailByAuthId(userAuthId);
	    }
		
	    
	    model.addAttribute("defaultEmail", defaultEmail);
		
	    return "mainPage/mainPage-contact"; 
	}
	
	@GetMapping("/hashTrip/notice") // 메인 페이지 공지사항
	public String hashTrip_notice(Model model) {
		
		model.addAttribute("noticeList", noticeService.getNoticeList());
		
	    return "mainPage/mainPage-notice"; 
	}
	
	// 추천 여행지 '좋아요' 저장
	@PostMapping("/customer/savePlace")
	@ResponseBody
	// HttpSession 대신 Authentication 객체를 파라미터로 받습니다.
	public ApiResponse<String> savePlace(@RequestBody Map<String, String> params, Authentication authentication) {
	    ApiResponse<String> res = new ApiResponse<>();
	    
	    if (authentication == null || !authentication.isAuthenticated() 
	            || authentication instanceof AnonymousAuthenticationToken) {
	        
	        System.out.println("로그인 유저 확인: 인증되지 않은 사용자");
	        res.setBody("LOGIN_REQUIRED");
	        return res;
	    }
	    
	    // 로그인 된 사용자의 ID(이름) 확인
	    String userId = authentication.getName();
	    System.out.println("로그인 유저 확인: " + userId);
	    
	    // 2. 파라미터 추출 (JS에서 보낸 키값 'placeNo' 사용)
	    String placeId = params.get("placeNo");
	    String status = params.get("status");
	    
	    // TODO: placeService.toggleLike(userId, placeId, status); 등의 DB 작업 수행
	    
	    res.setBody("SUCCESS");
	    return res;
	}
	
	// 1:1문의 답변 작성
	@PostMapping("/contact/submit")
	public String submitInquiry(InquiryDTO dto, Authentication authentication, RedirectAttributes ra) {
	    // 1. 로그인 유저 확인 (이전에 만든 메서드 활용)
	    String authId = resolveAuthenticatedAuthId(authentication);
	    if (authId == null) return "redirect:/auth/login";

	    // 2. 유저 정보 세팅 (DB 조회를 통해 userNo 가져오기)
	    UsersDTO user = usersService.getUserByAuthId(authId);
	    dto.setUserNo(user.getUserNo());

	    // 3. DB 저장 서비스 호출
	    int result = usersService.registerInquiry(dto);

	    if (result > 0) {
	        ra.addFlashAttribute("msg", "문의가 성공적으로 접수되었습니다.");
	        return "redirect:/mypage"; // 마이페이지 리스트로 이동
	    } else {
	        ra.addFlashAttribute("msg", "접수에 실패했습니다.");
	        return "redirect:/hashTrip"; 
	    }
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
	
}
