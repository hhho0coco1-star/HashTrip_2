package com.app.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
    public String userList(
            @RequestParam(value = "page", defaultValue = "1") int page, // 현재 페이지, 기본값 1
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
	
}
