package com.app.controller;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.app.dto.CommunityDTO;
import com.app.dto.RouteDTO;
import com.app.dto.RouteSaveResultDTO;
import com.app.dto.UserTagMapDTO;
import com.app.dto.UsersDTO;
import com.app.service.PlanDetailService;
import com.app.service.TravelPlanService;
import com.app.service.UsersService;
import com.app.service.impl.CommunityService;
import com.app.service.impl.RouteService;
import com.app.service.impl.SocialUserProvisionService;

@Controller
@RequestMapping("/routes")
public class RouteController {

    @Autowired
    private RouteService routeService;

    @Autowired
    private UsersService usersService;

    @Autowired
    private CommunityService communityService;

    @Autowired
    private TravelPlanService travelPlanService;

    @Autowired
    private PlanDetailService planDetailService;

    @Autowired
    private SocialUserProvisionService socialUserProvisionService;

    @GetMapping
    public String routesPage(Model model, Authentication authentication) {
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        if (currentUser != null) {
            model.addAttribute("personalUserName", resolveDisplayName(currentUser));
        }

        List<UserTagMapDTO> userTags = resolveCurrentUserTags(authentication);
        List<RouteDTO> routes = routeService.getAllRoutes();
        routes = excludeCurrentUserRoutes(routes, currentUser);
        Integer similarityPct = applySimilarityScores(routes, authentication, userTags);

        model.addAttribute("routes", routes);
        model.addAttribute("similarityPct", similarityPct);
        model.addAttribute("myTagCount", userTags.size());
        model.addAttribute("myTopTags", extractTopTagNames(userTags, 5));
        model.addAttribute("categories", routeService.getAllTagCategories());
        model.addAttribute("travelerTypes", routeService.getAllTravelerTypes());
        return "routeList";
    }

    @GetMapping("/{routeId}")
    public String routeDetail(@PathVariable Long routeId, Model model, Authentication authentication) {
        RouteDTO route = routeService.getRouteById(routeId);
        if (route == null) {
            return "redirect:/routes";
        }

        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        model.addAttribute("route", route);
        model.addAttribute("reviews", communityService.getCommunityReviewsByPlanNo(routeId));
        model.addAttribute("routePlanDetails", planDetailService.findPlanDetails(routeId));
        model.addAttribute("travelerTypes", routeService.getAllTravelerTypes());
        model.addAttribute("categories", routeService.getAllTagCategories());
        model.addAttribute("currentAuthId", currentUser == null ? null : resolveAuthenticatedAuthId(authentication));
        model.addAttribute("myPlans", currentUser == null
                ? Collections.emptyList()
                : travelPlanService.findUserTravelPlans(currentUser.getUserNo()));
        return "routeDetail";
    }

    @GetMapping("/filter")
    @ResponseBody
    public List<RouteDTO> filterRoutes(
            @RequestParam(required = false) String category,
            Authentication authentication) {
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        List<RouteDTO> routes = routeService.getRoutesByCategory(category);
        routes = excludeCurrentUserRoutes(routes, currentUser);
        applySimilarityScores(routes, authentication);
        return routes;
    }

    @PostMapping("/save")
    @ResponseBody
    public Map<String, Object> saveRoute(@RequestParam Long routeId, Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            return loginRequiredResponse();
        }

        try {
            RouteSaveResultDTO saveResult = travelPlanService.saveRouteForUser(routeId, currentUser.getUserNo(), null);
            response.put("success", true);
            response.put("savedUserCount", saveResult.getSavedUserCount());
            response.put("saveRegistered", saveResult.isSaveRegistered());
            response.put("message", saveResult.isSaveRegistered()
                    ? "내 일정으로 저장했습니다."
                    : "이미 저장한 루트입니다.");
            if (saveResult.getCopiedPlanNo() != null) {
                response.put("planNo", saveResult.getCopiedPlanNo());
                response.put("redirectUrl", "/plan/" + saveResult.getCopiedPlanNo() + "/edit");
            }
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return response;
        }
    }

    @PostMapping("/{routeId}/reviews")
    @ResponseBody
    public Map<String, Object> writeReview(
            @PathVariable Long routeId,
            @RequestParam String reviewContent,
            @RequestParam(required = false, defaultValue = "5") Integer rating,
            Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            return loginRequiredResponse();
        }

        try {
            CommunityDTO savedReview = communityService.addCommunityReview(routeId, currentUser.getUserNo(), reviewContent, rating);
            List<CommunityDTO> reviews = communityService.getCommunityReviewsByPlanNo(routeId);

            response.put("success", true);
            response.put("review", savedReview);
            response.put("reviewCount", reviews.size());
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        return response;
    }

    @PostMapping("/{routeId}/copy")
    @ResponseBody
    public Map<String, Object> copyRouteToNewPlan(
            @PathVariable Long routeId,
            @RequestParam(required = false) String planTitle,
            Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            return loginRequiredResponse();
        }

        try {
            Long copiedPlanNo = travelPlanService.copyTravelPlanWithDetails(routeId, currentUser.getUserNo(), planTitle);
            response.put("success", true);
            response.put("message", "새 일정으로 복사했습니다.");
            response.put("planNo", copiedPlanNo);
            response.put("redirectUrl", "/plan/" + copiedPlanNo + "/edit");
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return response;
        }
    }

    @PostMapping("/{routeId}/append")
    @ResponseBody
    public Map<String, Object> appendRouteToExistingPlan(
            @PathVariable Long routeId,
            @RequestParam Long targetPlanNo,
            Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            return loginRequiredResponse();
        }

        try {
            int insertedCount = travelPlanService.appendPlanDetailsToExistingPlan(
                    routeId, targetPlanNo, currentUser.getUserNo());
            if (insertedCount <= 0) {
                response.put("success", false);
                response.put("message", "추가할 장소 정보가 없습니다.");
                return response;
            }

            response.put("success", true);
            response.put("message", "선택한 일정에 코스 전체를 추가했습니다.");
            response.put("insertedCount", insertedCount);
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return response;
        }
    }

    @PostMapping("/{routeId}/append-place")
    @ResponseBody
    public Map<String, Object> appendSinglePlaceToExistingPlan(
            @PathVariable Long routeId,
            @RequestParam Long sourcePlanDetailNo,
            @RequestParam Long targetPlanNo,
            Authentication authentication) {
        Map<String, Object> response = new HashMap<>();
        UsersDTO currentUser = resolveAuthenticatedUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            return loginRequiredResponse();
        }

        try {
            int insertedCount = travelPlanService.appendSinglePlanDetailToExistingPlan(
                    routeId, sourcePlanDetailNo, targetPlanNo, currentUser.getUserNo());
            if (insertedCount <= 0) {
                response.put("success", false);
                response.put("message", "선택한 장소를 추가하지 못했습니다.");
                return response;
            }

            response.put("success", true);
            response.put("message", "선택한 장소를 기존 일정에 추가했습니다.");
            response.put("insertedCount", insertedCount);
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return response;
        }
    }

    @GetMapping("/api/user-info")
    @ResponseBody
    public String getUserInfo(@RequestParam int userNo) {
        return usersService.findUserName(userNo);
    }

    private Map<String, Object> loginRequiredResponse() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        response.put("loginRequired", true);
        response.put("redirectUrl", "/auth/login");
        return response;
    }

    private UsersDTO resolveAuthenticatedUser(Authentication authentication) {
        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            return null;
        }
        return usersService.getUserByAuthId(authId);
    }

    private String resolveAuthenticatedAuthId(Authentication authentication) {
        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return null;
        }

        if (authentication instanceof OAuth2AuthenticationToken) {
            OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) authentication;
            Object principal = token.getPrincipal();
            if (principal instanceof OAuth2User) {
                OAuth2User oAuth2User = (OAuth2User) principal;
                String socialAuthId = socialUserProvisionService.resolveSocialAuthId(
                        token.getAuthorizedClientRegistrationId(),
                        oAuth2User.getAttributes());
                if (socialAuthId != null && !socialAuthId.trim().isEmpty()) {
                    return socialAuthId.trim();
                }
            }
        }

        String authId = authentication.getName();
        if (authId == null || authId.trim().isEmpty()) {
            return null;
        }
        return authId.trim();
    }

    private String resolveDisplayName(UsersDTO usersDTO) {
        if (usersDTO == null) {
            return null;
        }
        if (usersDTO.getUserNickName() != null && !usersDTO.getUserNickName().trim().isEmpty()) {
            return usersDTO.getUserNickName().trim();
        }
        if (usersDTO.getUserName() != null && !usersDTO.getUserName().trim().isEmpty()) {
            return usersDTO.getUserName().trim();
        }
        return null;
    }

    private Integer applySimilarityScores(List<RouteDTO> routes, Authentication authentication) {
        return applySimilarityScores(routes, authentication, null);
    }

    private Integer applySimilarityScores(
            List<RouteDTO> routes,
            Authentication authentication,
            List<UserTagMapDTO> preloadedUserTags) {
        if (routes == null || routes.isEmpty()) {
            return null;
        }

        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            return null;
        }

        UsersDTO currentUser = usersService.getUserByAuthId(authId);
        Long currentUserNo = currentUser == null ? null : currentUser.getUserNo();
        List<UserTagMapDTO> userTags = preloadedUserTags == null
                ? usersService.getUserTagsByAuthId(authId)
                : preloadedUserTags;
        if (userTags == null) {
            userTags = Collections.emptyList();
        }
        Integer personalizedSimilarity = routeService.applySimilarityScores(routes, userTags, currentUserNo);
        if (personalizedSimilarity != null) {
            return personalizedSimilarity;
        }

        int bestScore = 0;
        for (RouteDTO route : routes) {
            if (route == null || route.getMatchScore() == null) {
                continue;
            }
            if (route.getMatchScore() > bestScore) {
                bestScore = route.getMatchScore();
            }
        }
        return bestScore == 0 ? null : bestScore;
    }

    private List<RouteDTO> excludeCurrentUserRoutes(List<RouteDTO> routes, UsersDTO currentUser) {
        if (routes == null || routes.isEmpty() || currentUser == null || currentUser.getUserNo() == null) {
            return routes;
        }

        Long currentUserNo = currentUser.getUserNo();
        routes.removeIf(route -> route != null
                && route.getUserNo() != null
                && currentUserNo.equals(route.getUserNo()));
        return routes;
    }

    private List<UserTagMapDTO> resolveCurrentUserTags(Authentication authentication) {
        String authId = resolveAuthenticatedAuthId(authentication);
        if (authId == null) {
            return Collections.emptyList();
        }

        List<UserTagMapDTO> userTags = usersService.getUserTagsByAuthId(authId);
        return userTags == null ? Collections.emptyList() : userTags;
    }

    private List<String> extractTopTagNames(List<UserTagMapDTO> userTags, int limit) {
        if (userTags == null || userTags.isEmpty() || limit <= 0) {
            return Collections.emptyList();
        }

        Set<String> uniqueTagNames = new LinkedHashSet<>();
        for (UserTagMapDTO userTag : userTags) {
            if (userTag == null) {
                continue;
            }

            String tagName = userTag.getTagName();
            if (tagName == null || tagName.trim().isEmpty()) {
                tagName = userTag.getTagCode();
            }
            if (tagName == null || tagName.trim().isEmpty()) {
                continue;
            }

            uniqueTagNames.add(tagName.trim());
            if (uniqueTagNames.size() >= limit) {
                break;
            }
        }
        return new ArrayList<>(uniqueTagNames);
    }
}
