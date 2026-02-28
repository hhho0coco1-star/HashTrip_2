package com.app.controller;

import java.util.List;
import java.util.Map;

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
        
        UsersDTO loginUser = (UsersDTO) session.getAttribute("loginUser");                
        
        if (loginUser != null) {
            Long realUserNo = loginUser.getUserNo();
            for (UserTagMapDTO dto : selections) {
                dto.setUserNo(realUserNo);
            }
        } else {
            return "fail"; 
        }
        
        // 💡 수정: 서비스에서 문자열(finalSummary)만 반환받도록 이전 상태로 돌립니다.
        String finalResult = userTagMapService.processUserAnalysis((long)loginUser.getUserNo(), selections);                
        
        // 💡 디버깅: 문자열이 제대로 왔는지 확인
        System.out.println(">>> 분석 결과 문자열: " + finalResult);                
        
        // 💡 세션 키를 'finalResult'로 설정
        session.setAttribute("finalResult", finalResult);
        return "success";
    }
    
    @GetMapping("/hashTrip/analysisResult")
    public String hashTrip_analysisResult(HttpSession session, Model model) {
        String finalResult = (String) session.getAttribute("finalResult");
        UsersDTO loginUser = (UsersDTO) session.getAttribute("loginUser");

        if (finalResult == null || loginUser == null) {
            return "redirect:/hashTrip/analysis"; 
        }
        
        // 추가 메서드 없이 요약 문구(String)와 유저 정보만 전달
        model.addAttribute("travelType", finalResult);
        model.addAttribute("loginUser", loginUser);
        
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