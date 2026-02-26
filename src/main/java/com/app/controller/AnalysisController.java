package com.app.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;
import com.app.service.UserTagMapService;
import com.app.service.UsersService;

@Controller
public class AnalysisController {
    
    @Autowired
    UserTagMapService userTagMapService;
    
    @Autowired
    private UsersService usersService;
    
    @GetMapping("/hashTrip/analysis")
    public String hashTrip_analysis(Authentication authentication, HttpSession session, Model model) {
        String currentAuthId = resolveAuthenticatedAuthId(authentication);
        
        // 유저 정보를 가져와서 세션에 저장 (저장 로직에서 쓸 수 있게)
        if (currentAuthId != null) {
            UsersDTO usersDTO = usersService.getUserByAuthId(currentAuthId);
            session.setAttribute("loginUser", usersDTO); // 세션 키 이름을 "loginUser"로 통일
            model.addAttribute("usersDTO", usersDTO);
        }
        
        return "analysis/analysis";
    }

    @PostMapping("/hashTrip/saveAnalysis")
    @ResponseBody 
    public String saveAnalysis(@RequestBody List<UserTagMapDTO> selections, HttpSession session) {
        
        // 1. 세션에서 로그인한 유저 객체를 가져옵니다. (세션 키 이름 확인 필수: "loginUser")
        UsersDTO loginUser = (UsersDTO) session.getAttribute("loginUser");
        
        // 2. 유저가 로그인 상태라면, 전송받은 데이터의 userNo를 세션 값으로 덮어씁니다.
        if (loginUser != null) {
            Long realUserNo = loginUser.getUserNo();
            for (UserTagMapDTO dto : selections) {
                dto.setUserNo(realUserNo); // 0으로 들어온 값을 진짜 유저번호로 변경
            }
        } else {
            return "fail"; 
        }
        
        String finalResult = userTagMapService.processUserAnalysis((long)loginUser.getUserNo(), selections);
        
        session.setAttribute("finalResult", finalResult);
        return "success";
    }
    
    @GetMapping("/hashTrip/analysisResult")
    public String hashTrip_analysisResult(HttpSession session, Model model) {
        // 세션에서 저장된 결과 꺼내기
        String finalResult = (String) session.getAttribute("finalResult");
        UsersDTO loginUser = (UsersDTO) session.getAttribute("loginUser");

        if (finalResult == null) {
            return "redirect:/hashTrip/analysis"; // 결과 없으면 다시 테스트로
        }

        model.addAttribute("travelType", finalResult);
        model.addAttribute("isGuest", loginUser == null);
        
        return "analysis/analysisResult";
    }
    
    private String resolveAuthenticatedAuthId(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return null;
        }
        return authentication.getName();
    }
}