package com.app.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.app.dto.PlaceDTO;
import com.app.service.PlaceService;

@Controller
public class MainPageController {
	 
	@Autowired
	private PlaceService placeService;
	
	@GetMapping({"/", "/main", "/hashTrip"}) // 메인 페이지
	public String hashTag(Model model) {
		List<PlaceDTO> list = placeService.searchPlaces("");
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
	public String hashTrip_faq() {
	    return "mainPage/mainPage-faq"; 
	}
	
	@GetMapping("/hashTrip/contact") // 메인 페이지 1:1문의
	public String hashTrip_contact() {
	    return "mainPage/mainPage-contact"; 
	}
	
	@GetMapping("/hashTrip/notice") // 메인 페이지 공지사항
	public String hashTrip_notice() {
	    return "mainPage/mainPage-notice"; 
	}
}
