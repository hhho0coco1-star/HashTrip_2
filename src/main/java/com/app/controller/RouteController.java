package com.app.controller;

import com.app.dto.RouteDTO;
import com.app.dto.TravelerTypeDTO;
import com.app.service.UserService;
import com.app.service.impl.RouteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.*;

import javax.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/routes")
public class RouteController {

    @Autowired
    private RouteService routeService;

    // 메인 목록 페이지
    @GetMapping
    public String routesPage(Model model, HttpServletRequest request) {
        // [수정 내용] DB에서 1번 유저의 이름을 가져와서 userName이라는 이름으로 담습니다.
        // 나중에 세션 기능이 구현되면 1L 대신 세션의 유저 번호를 넣으시면 됩니다.
        String name = userService.findUserName(1); 
        request.setAttribute("userName", name);

        model.addAttribute("routes", routeService.getAllRoutes());
        model.addAttribute("categories", routeService.getAllTagCategories());
        model.addAttribute("travelerTypes", routeService.getAllTravelerTypes());
        
        return "routeList"; // 이 이름이 아까 보여주신 JSP 파일명과 일치해야 합니다.
    }

    // 루트 상세 페이지 (ID 기반)
    @GetMapping("/{routeId}")
    public String routeDetail(@PathVariable Long routeId, Model model) {
        RouteDTO route = routeService.getRouteById(routeId);
        
        if (route == null) {
            return "redirect:/routes"; // 없는 ID일 경우 목록으로
        }

        model.addAttribute("route", route);
        model.addAttribute("travelerTypes", routeService.getAllTravelerTypes());
        model.addAttribute("categories", routeService.getAllTagCategories());
        return "routeDetail"; 
    }

    // 필터링 AJAX 전용
    @GetMapping("/filter")
    @ResponseBody
    public List<RouteDTO> filterRoutes(@RequestParam(required = false) String category) {
        // 실제 운영 시에는 여기서 category별로 필터링 로직을 수행합니다.
        return routeService.getAllRoutes();
    }

    // 저장 AJAX
    @PostMapping("/save")
    @ResponseBody
    public Map<String, Object> saveRoute(@RequestParam Long routeId) {
        return Map.of("success", true, "message", "루트를 저장했어요 🔖");
    }
    
    @Autowired
    private UserService userService;

    @GetMapping("/api/user-info")
    public String getUserInfo(@RequestParam int userNo) {
        // 이제 UserService에 findUserName이 정의되었으므로 에러가 사라집니다.
        return userService.findUserName(userNo);
    }
}