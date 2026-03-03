package com.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.app.dto.UsersDTO;
import com.app.service.UsersService;

@ControllerAdvice
public class HeaderModelAdvice {

    @Autowired
    private UsersService usersService;

    @ModelAttribute
    public void addHeaderCommonModel(Authentication authentication, Model model) {
        model.addAttribute("headerDisplayName", null);
        model.addAttribute("headerUserType", null);
        model.addAttribute("headerCanAdmin", false);

        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return;
        }

        String authId = authentication.getName();
        if (authId == null || authId.trim().isEmpty()) {
            return;
        }

        UsersDTO usersDTO = usersService.getUserByAuthId(authId.trim());
        if (usersDTO == null) {
            model.addAttribute("headerDisplayName", authId.trim());
            return;
        }

        String displayName = resolveDisplayName(usersDTO, authId.trim());
        String userType = normalizeUserType(usersDTO.getUserType());
        boolean canAdmin = "ADMIN".equals(userType) || "MASTER".equals(userType);

        model.addAttribute("headerDisplayName", displayName);
        model.addAttribute("headerUserType", userType);
        model.addAttribute("headerCanAdmin", canAdmin);
    }

    private String resolveDisplayName(UsersDTO usersDTO, String fallbackAuthId) {
        if (usersDTO.getUserNickName() != null && !usersDTO.getUserNickName().trim().isEmpty()) {
            return usersDTO.getUserNickName().trim();
        }
        if (usersDTO.getUserName() != null && !usersDTO.getUserName().trim().isEmpty()) {
            return usersDTO.getUserName().trim();
        }
        return fallbackAuthId;
    }

    private String normalizeUserType(String userType) {
        if (userType == null) {
            return null;
        }
        String normalized = userType.trim().toUpperCase();
        if (normalized.isEmpty()) {
            return null;
        }
        return normalized;
    }
}
