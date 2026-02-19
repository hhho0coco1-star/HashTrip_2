package com.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import com.app.dto.TravelPlanDTO;
import com.app.service.TravelPlanService;

@Controller
public class PlanController {
	
	@Autowired
	private TravelPlanService planService;
	
    @GetMapping("/plan")
    public String planIndex() {
        return "plan/plan";
    }
    
    @PostMapping("/plan")
    public String insertPlan(@ModelAttribute TravelPlanDTO travelPlanDTO, Model model) {
    	System.out.println(travelPlanDTO.toString());
    	travelPlanDTO.setUserNo(7L); //임시사용자 번호
        planService.insertTravelPlan(travelPlanDTO);
        return "redirect:/plan";
    }
    
}