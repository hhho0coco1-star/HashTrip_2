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

import com.app.dto.InquiryDTO;
import com.app.service.UsersService;

@Controller
public class AdminController {

	@Autowired
	UsersService usersService;

	// 관리자 전용 페이지
	@PreAuthorize("hasRole('ADMIN')")
	@GetMapping("/hashTrip/admin")
	public String admin() {

		return "admin/adminpage";

	}

	// 회원 목록 페이지 (페이징 및 검색 기능 포함)
	@PreAuthorize("hasRole('ADMIN')")
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
	@PreAuthorize("hasRole('ADMIN')") // 보안을 위해 관리자 권한 체크 추가 권장
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
	@PreAuthorize("hasRole('ADMIN')")
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

}
