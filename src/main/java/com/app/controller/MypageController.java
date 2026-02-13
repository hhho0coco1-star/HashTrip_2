package com.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.app.dto.UsersDTO;
import com.app.service.UsersService;

@Controller
public class MypageController {

	@Autowired
	UsersService usersService;
	
	@RequestMapping("/mypage")
	public String mypage(Model model) {
		String id = "1";
		UsersDTO usersDTO = usersService.getUser(id);
		
		model.addAttribute("usersDTO", usersDTO);
		
		return "mypage";
	}
	
}
