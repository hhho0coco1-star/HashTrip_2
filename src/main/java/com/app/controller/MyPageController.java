package com.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/mypage")
public class MyPageController {

    @GetMapping("/additional-info")
    public String additionalInfoPage() {
        return "forward:/auth/social/additional-info";
    }

    @PostMapping("/additional-info")
    public String additionalInfoProcess() {
        return "forward:/auth/social/additional-info";
    }
}
