package com.app.controller;

import java.util.Collections;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.app.dto.PlaceDTO;
import com.app.service.PlaceService;

@Controller
public class PlaceDetailPageController {

	@Autowired
	private PlaceService placeService;

	@GetMapping("/place/detail/demo")
	public String placeDetailDemoPage(
			@RequestParam(name = "place_no", required = false) Long placeNo,
			@RequestParam(name = "placeNo", required = false) Long legacyPlaceNo,
			Model model) throws Exception {
		Long resolvedPlaceNo = placeNo != null ? placeNo : (legacyPlaceNo != null ? legacyPlaceNo : 49070L);
		PlaceDTO place = placeService.getPlaceByPlaceNo(resolvedPlaceNo);

		String kakaoMapAppKey = System.getenv("KAKAO_MAP_APP_KEY");
		if (kakaoMapAppKey == null || kakaoMapAppKey.isBlank()) {
			kakaoMapAppKey = System.getProperty("kakao.map.appkey", "");
		}

		model.addAttribute("placeNo", resolvedPlaceNo);
		model.addAttribute("place", place);
		model.addAttribute("reviewList", placeService.getPlaceReviewsByPlaceNo(resolvedPlaceNo));
		model.addAttribute("hoursList", placeService.getPlaceHoursByPlaceNo(resolvedPlaceNo));
		model.addAttribute("kakaoMapAppKey", kakaoMapAppKey);

		if (place == null) {
			model.addAttribute("tagNameList", Collections.emptyList());
			model.addAttribute("photoUrlList", Collections.emptyList());
			return "place/detail-demo";
		}

		model.addAttribute("tagNameList", placeService.getPlaceTagNamesByPlaceNo(resolvedPlaceNo));
		model.addAttribute("photoUrlList", placeService.getPlacePhotoUrlsByPlaceNo(resolvedPlaceNo));
		return "place/detail-demo";
	}
}
