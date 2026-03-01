package com.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

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

	@PreAuthorize("hasRole('ADMIN')")
	@GetMapping("/hashTrip/admin/users")
	public String admin_users(Model model) {
		
		// 서비스에서 회원 목록 데이터를 가져옴
        model.addAttribute("userList", usersService.findAllUsers());

		return "admin/users";

	}
}
