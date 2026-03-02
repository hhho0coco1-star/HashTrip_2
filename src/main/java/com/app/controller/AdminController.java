package com.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.app.dto.FaqDTO;
import com.app.dto.InquiryDTO;
import com.app.dto.NoticeDTO;
import com.app.service.FaqService;
import com.app.service.NoticeService;
import com.app.service.UsersService;

@Controller
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

	@Autowired
	UsersService usersService;
	
	@Autowired
    private FaqService faqService;

	@Autowired
    private NoticeService noticeService;
	
	// 관리자 전용 페이지
	@GetMapping("/hashTrip/admin")
	public String admin() {

		return "admin/adminpage";

	}

	// 회원 목록 페이지 (페이징 및 검색 기능 포함)
	@GetMapping("/hashTrip/admin/users")
	public String userList(@RequestParam(value = "page", defaultValue = "1") int page, // 현재 페이지, 기본값 1
			@RequestParam(value = "size", defaultValue = "10") int size, // 페이지당 회원 수, 기본값 10
			@RequestParam(value = "searchType", required = false) String searchType,
			@RequestParam(value = "keyword", required = false) String keyword,
			@RequestParam(value = "orderBy", defaultValue = "desc") String orderBy, // 💡 정렬 기준 추가
			Model model) {

		// 1. 서비스에서 페이징 처리된 데이터와 페이징 정보를 가져옴
		Map<String, Object> result = usersService.getPagedUsers(page, size, searchType, keyword, orderBy);

		// 2. 모델에 결과 담기
		model.addAttribute("userList", result.get("userList"));
		model.addAttribute("totalCount", result.get("totalCount"));
		model.addAttribute("currentPage", result.get("currentPage"));
		model.addAttribute("totalPage", result.get("totalPage"));

		// 3. 검색 조건 유지를 위해 모델에 담기
		model.addAttribute("searchType", searchType);
		model.addAttribute("keyword", keyword);

		return "admin/users";
	}

	// 관리자 권한 부여/취소
	@PostMapping("/hashTrip/admin/updateType") // 💡 주소를 AJAX 호출 경로와 일치시킴
	@ResponseBody
	public String updateType(@RequestParam("userNo") int userNo, @RequestParam("userType") String userType,
			HttpSession session) {

		System.out.println("수정 요청 확인 - 번호: " + userNo + ", 타입: " + userType);

		// 세션에서 로그인한 관리자의 번호를 꺼냄
		Integer loginUserNo = (Integer) session.getAttribute("userNo");

		System.out.println("본인 번호(세션): " + loginUserNo);
		System.out.println("변경 대상 번호: " + userNo);

		boolean isUpdated = usersService.changeUserType(userNo, userType, loginUserNo);

		return isUpdated ? "success" : "fail";
	}

	// 1:1 문의
	@GetMapping("/hashTrip/admin/inquiry")
	public String inquiry(
	        @RequestParam(value = "inquiryType", required = false) String inquiryType,
	        @RequestParam(value = "status", required = false) String status,
	        @RequestParam(value = "searchType", required = false) String searchType,
	        @RequestParam(value = "keyword", required = false) String keyword,
	        Model model) {

	    // 💡 Map에 파라미터 담기
	    Map<String, Object> params = new HashMap<>();
	    params.put("inquiryType", inquiryType);
	    params.put("status", status);
	    params.put("searchType", searchType);
	    params.put("keyword", keyword);

	    // 💡 서비스 호출
	    List<InquiryDTO> inquiryList = usersService.getAllInquiries(params);
	    
	    model.addAttribute("inquiryList", inquiryList);
	    
	    return "admin/inquiry"; // JSP 경로
	}
	
	@GetMapping("/admin/inquiry/detail")                
	public String getInquiryDetail(@RequestParam("inquiryNo") Long inquiryNo, Model model) {
	    InquiryDTO dto = usersService.getInquiryDetail(inquiryNo);
	    model.addAttribute("inquiry", dto);
	    
	    // 💡 상세 내용만 보여줄 전용 JSP (예: /WEB-INF/views/admin/inquiryDetail.jsp)
	    return "admin/inquiryDetail"; 
	}

	// 답변 저장
	@PostMapping("/admin/inquiry/reply")
	public String replyInquiry(InquiryDTO inquiryDTO) {
		
	    usersService.updateReply(inquiryDTO); // 답변 내용 및 날짜, 상태 업데이트 서비스
	    
	    return "redirect:/hashTrip/admin/inquiry"; // 목록으로 리다이렉트
	}
	
	// 관리자 전용 페이지(1:1 문의)
	@GetMapping("/hashTrip/admin/faq")
	public String faq(Model model) {

		model.addAttribute("faqList", faqService.getFaqList());
		
		return "admin/faq";
	}
	

    
	// FAQ 등록 폼 이동
    @GetMapping("/admin/faq/registerForm")
    public String registerForm() {
        return "admin/faqRegister";
    }
    
	// FAQ 등록 처리
    @PostMapping("/admin/faq/register")
    public String registerFaq(FaqDTO faqDTO) {
    	
        faqService.registerFaq(faqDTO);
        
        return "redirect:/hashTrip/admin/faq";
    }


    // FAQ 수정 화면 이동
    @GetMapping("/admin/faq/modify")
    public String modifyForm(@RequestParam("faqNo") int faqNo, Model model) {
    	
        model.addAttribute("faq", faqService.getFaqDetail(faqNo));
        
        return "admin/faqModify"; // 수정 JSP 경로
    }
    
    // FAQ 수정 처리
    @PostMapping("/admin/faq/modify")
    public String modifyFaq(FaqDTO faqDTO) {
    	
        faqService.modifyFaq(faqDTO);

        return "redirect:/hashTrip/admin/faq";
    }
    
    // FAQ 삭제 처리
    @GetMapping("admin/faq/remove")
    public String removeFaq(@RequestParam("faqNo") int faqNo) {
    	
        faqService.removeFaq(faqNo);
        
        return "redirect:/hashTrip/admin/faq";
    }
    
    // 1. 공지사항 관리 페이지 이동 (목록 조회)
    @GetMapping("/hashTrip/admin/notice")
    public String noticeManagementPage(Model model) {
        model.addAttribute("noticeList", noticeService.getNoticeList());
        return "admin/notice"; // JSP 파일 위치: /WEB-INF/views/admin/noticeManagement.jsp
    }

    // 2. 공지사항 등록 폼 페이지 이동
    @GetMapping("/admin/notice/registerForm")
    public String registerForm2() {
    	return "admin/noticeRegister";
    }

    // 3. 공지사항 등록 처리
    @PostMapping("/admin/notice/registerForm")
    public String registerNotice(NoticeDTO noticeDTO) {
        noticeService.registerNotice(noticeDTO);
        return "redirect:/hashTrip/admin/notice";
    }

    // 4. 공지사항 수정 폼 페이지 이동
    @GetMapping("/admin/notice/modify")
    public String modifyForm2(@RequestParam("noticeNo") int noticeNo, Model model) {
        model.addAttribute("notice", noticeService.getNoticeDetail(noticeNo));
        
        return "admin/noticeModify"; // JSP 파일 위치: /WEB-INF/views/admin/noticeModify.jsp
    }

    // 5. 공지사항 수정 처리
    @PostMapping("/admin/notice/modify")
    public String modifyNotice(NoticeDTO noticeDTO) {
        noticeService.modifyNotice(noticeDTO);
        return "redirect:/hashTrip/admin/notice";
    }

    // 6. 공지사항 삭제 처리
    @GetMapping("/admin/notice/remove")
    public String removeNotice(@RequestParam("noticeNo") int noticeNo) {
        noticeService.removeNotice(noticeNo);
        return "redirect:/hashTrip/admin/notice";
    }
}
