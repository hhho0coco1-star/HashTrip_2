package com.app.controller.plan;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    @GetMapping("/plan")
    public String planIndex() {
        return "plan/index";
    }
}
