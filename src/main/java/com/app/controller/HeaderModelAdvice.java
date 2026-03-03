package com.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.app.dto.UsersDTO;
import com.app.service.UsersService;
import com.app.service.impl.SocialUserProvisionService;

@ControllerAdvice
public class HeaderModelAdvice {

    @Autowired
    private UsersService usersService;

    @Autowired
    private SocialUserProvisionService socialUserProvisionService;

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

        String authId = resolveAuthenticatedAuthId(authentication);
        if (!StringUtils.hasText(authId)) {
            return;
        }

        UsersDTO usersDTO = usersService.getUserByAuthId(authId.trim());
        if (usersDTO == null) {
            model.addAttribute("headerDisplayName", "Traveler");
            return;
        }

        String displayName = resolveDisplayName(usersDTO);
        String userType = normalizeUserType(usersDTO.getUserType());
        boolean canAdmin = "ADMIN".equals(userType) || "MASTER".equals(userType);

        model.addAttribute("headerDisplayName", displayName);
        model.addAttribute("headerUserType", userType);
        model.addAttribute("headerCanAdmin", canAdmin);
    }

    private String resolveDisplayName(UsersDTO usersDTO) {
        if (StringUtils.hasText(usersDTO.getUserNickName())) {
            return usersDTO.getUserNickName().trim();
        }
        if (StringUtils.hasText(usersDTO.getUserName())) {
            return usersDTO.getUserName().trim();
        }
        return "Traveler";
    }

    private String normalizeUserType(String userType) {
        if (!StringUtils.hasText(userType)) {
            return null;
        }
        return userType.trim().toUpperCase();
    }

    private String resolveAuthenticatedAuthId(Authentication authentication) {
        if (authentication instanceof OAuth2AuthenticationToken) {
            OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) authentication;
            Object principal = token.getPrincipal();
            if (principal instanceof OAuth2User) {
                OAuth2User oAuth2User = (OAuth2User) principal;
                try {
                    socialUserProvisionService.provisionIfMissing(
                            token.getAuthorizedClientRegistrationId(),
                            oAuth2User.getAttributes());
                } catch (Exception ignored) {
                    // Ignore provisioning errors here and try resolving existing auth id.
                }
                String socialAuthId = socialUserProvisionService.resolveSocialAuthId(
                        token.getAuthorizedClientRegistrationId(),
                        oAuth2User.getAttributes());
                if (StringUtils.hasText(socialAuthId)) {
                    return socialAuthId.trim();
                }
            }
        }

        String authId = authentication.getName();
        if (!StringUtils.hasText(authId)) {
            return null;
        }
        return authId.trim();
    }
}