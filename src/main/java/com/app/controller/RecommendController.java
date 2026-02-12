package com.app.controller;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class RecommendController {

	  @GetMapping("/recommend")
	    public String recommend(Model model) {

	        // 간단 테스트용
	        model.addAttribute("pageTitle", "추천 페이지");

	        return "recommendPage";  
}
}
