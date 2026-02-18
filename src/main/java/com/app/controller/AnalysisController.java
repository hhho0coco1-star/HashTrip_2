package com.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AnalysisController {
	
	@GetMapping("/hashTrip/analysis")
	public String hashTrip_analysis() {
		
		return "analysis/analysis";
	}
	
	@GetMapping("/hashTrip/analysisResult")
	public String hashTrip_analysisResult() {
		
		return "analysis/analysisResult";
	}
}
