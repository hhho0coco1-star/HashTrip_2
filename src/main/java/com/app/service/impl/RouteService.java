package com.app.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dto.RouteDTO;
import com.app.dto.TagCategoryDTO;
import com.app.dto.TravelPlanDTO;
import com.app.dto.TravelerTypeDTO;
import com.app.service.PlanDetailService;
import com.app.service.TravelPlanService;

@Service
public class RouteService {

    @Autowired
    private PlanDetailService planDetailService;

    @Autowired
    private TravelPlanService travelPlanService;

    public RouteDTO getRouteById(Long routeId) {
        TravelPlanDTO travelPlan = travelPlanService.findTravelPlan(routeId);
        if (travelPlan == null) {
            return null;
        }

        RouteDTO route = mapTravelPlanToRoute(travelPlan);
        enrichRoute(route);
        return route;
    }

    public List<RouteDTO> getAllRoutes() {
        return getRoutesByCategory(null);
    }

    public List<RouteDTO> getRoutesByCategory(String categoryKey) {
        String normalizedCategory = normalizeCategoryKey(categoryKey);
        List<TravelPlanDTO> travelPlans = travelPlanService.findPublicTravelPlans();
        List<RouteDTO> routes = new ArrayList<>();
        for (TravelPlanDTO travelPlan : travelPlans) {
            if (normalizedCategory != null && !hasCategory(travelPlan.getPlanNo(), normalizedCategory)) {
                continue;
            }

            RouteDTO route = mapTravelPlanToRoute(travelPlan);
            enrichRoute(route);
            routes.add(route);
        }

        return routes;
    }

    public List<TagCategoryDTO> getAllTagCategories() {
        return Arrays.asList(
            new TagCategoryDTO("LOCATION", "\uC7A5\uC18C", "\uD83D\uDCCD", "#5B8DEE", "#E8F0FE", "tag-place"),
            new TagCategoryDTO("PLANNING", "\uACC4\uD68D", "\uD83D\uDCCB", "#22C55E", "#DCFCE7", "tag-plan"),
            new TagCategoryDTO("MOVE", "\uC774\uB3D9", "\uD83D\uDE97", "#2DD4BF", "#D9F6F1", "tag-transport"),
            new TagCategoryDTO("STAY", "\uC219\uC18C", "\uD83C\uDFE8", "#F5A623", "#FFF3DE", "tag-stay"),
            new TagCategoryDTO("BUDGET", "\uC608\uC0B0", "\uD83D\uDCB8", "#22C55E", "#EAFBEF", "tag-budget"),
            new TagCategoryDTO("COMPANION", "\uB3D9\uD589", "\uD83D\uDC65", "#F87171", "#FDECEC", "tag-companion"),
            new TagCategoryDTO("FOOD_STYLE", "\uC74C\uC2DD", "\uD83C\uDF7D", "#D97706", "#FFF4E5", "tag-food"),
            new TagCategoryDTO("PURPOSE", "\uBAA9\uC801", "\uD83C\uDFAF", "#818CF8", "#EEF0FF", "tag-purpose"),
            new TagCategoryDTO("INTENSITY", "\uAC15\uB3C4", "\u26A1", "#7C3AED", "#F2EBFF", "tag-intensity"),
            new TagCategoryDTO("MOOD", "\uBB34\uB4DC", "\uD83C\uDF19", "#0EA5E9", "#E6F7FF", "tag-mood")
        );
    }

    public List<TravelerTypeDTO> getAllTravelerTypes() {
        List<TravelerTypeDTO> types = new ArrayList<>();
        types.add(new TravelerTypeDTO("adventurer", "\uD83E\uDD20", "\uD504\uB85C \uBAA8\uD5D8\uAC00", "#5B8DEE", "#E8F0FE", "\uB3C4\uC804\uC801\uC778 \uC5EC\uD589", null));
        types.add(new TravelerTypeDTO("healer", "\uD83C\uDF3F", "\uD3C9\uD654\uB85C\uC6B4 \uD790\uB7EC", "#22C55E", "#DCFCE7", "\uC5EC\uC720\uB85C\uC6B4 \uC5EC\uD589", null));
        types.add(new TravelerTypeDTO("explorer", "\uD83C\uDFD9\uFE0F", "\uB3C4\uC2DC \uD0D0\uD5D8\uAC00", "#A78BFA", "#F3F0FF", "\uB3C4\uC2DC\uC758 \uB9E4\uB825\uC744 \uCC3E\uB294 \uC5EC\uD589", null));
        types.add(new TravelerTypeDTO("foodie", "\uD83C\uDF5C", "\uC2DD\uB3C4\uB77D\uAC00", "#F87171", "#FEF2F2", "\uB9DB\uC9D1\uC774 \uC81C\uC77C \uC911\uC694\uD568", null));
        types.add(new TravelerTypeDTO("romantic", "\uD83C\uDF03", "\uB0AD\uB9CC\uC8FC\uC758\uC790", "#F5A623", "#FFFBEB", "\uBD84\uC704\uAE30\uB97C \uC911\uC2DC\uD558\uB294 \uC5EC\uD589", null));
        return types;
    }

    private void enrichRoute(RouteDTO route) {
        String normalizedTypeId = normalizeTypeId(route.getTypeId());
        route.setTypeId(normalizedTypeId);
        route.setEmoji(resolveEmoji(normalizedTypeId));

        List<String> steps = planDetailService.findStepNames(route.getId());
        if (steps == null || steps.isEmpty()) {
            steps = List.of("\uB4F1\uB85D\uB41C \uCF54\uC2A4 \uC815\uBCF4 \uC5C6\uC74C");
        }
        route.setSteps(steps);

        route.setTags(buildTagMap(planDetailService.findTagNames(route.getId())));

        String representativeMemo = defaultIfBlank(planDetailService.findRepresentativeMemo(route.getId()), null);
        if (representativeMemo != null) {
            route.setDescription(representativeMemo);
        }

        if (route.getDescription() == null || route.getDescription().trim().isEmpty()) {
            route.setDescription("\uC124\uBA85 \uC815\uBCF4 \uC5C6\uC74C");
        }
    }

    private RouteDTO mapTravelPlanToRoute(TravelPlanDTO travelPlan) {
        RouteDTO route = new RouteDTO();

        route.setId(travelPlan.getPlanNo());
        route.setTitle(defaultIfBlank(travelPlan.getPlanTitle(), "Untitled Plan"));
        route.setTypeId(defaultIfBlank(travelPlan.getTypeId(), "adventurer"));
        route.setDescription(defaultIfBlank(travelPlan.getDescription(), buildDescription(travelPlan)));
        route.setLikeCount(defaultIfNull(travelPlan.getLikeCount(), 0));
        route.setSavedCount(defaultIfNull(travelPlan.getSavedCount(), 0));
        route.setMatchScore(defaultIfNull(travelPlan.getMatchScore(), 70));
        route.setUserName(defaultIfBlank(travelPlan.getUserName(), "Traveler"));

        return route;
    }

    private String buildDescription(TravelPlanDTO travelPlan) {
        String planStatus = defaultIfBlank(travelPlan.getPlanStatus(), "planned");
        if (travelPlan.getPlanStartDate() != null && travelPlan.getPlanEndDate() != null) {
            return "Status: " + planStatus + " | " + travelPlan.getPlanStartDate() + " ~ " + travelPlan.getPlanEndDate();
        }
        return "Status: " + planStatus;
    }

    private String defaultIfBlank(String value, String defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        return value.trim();
    }

    private int defaultIfNull(Integer value, int defaultValue) {
        return value == null ? defaultValue : value;
    }

    private String normalizeCategoryKey(String categoryKey) {
        if (categoryKey == null || categoryKey.trim().isEmpty()) {
            return null;
        }
        return categoryKey.trim().toUpperCase(Locale.ROOT);
    }

    private boolean hasCategory(Long planNo, String categoryKey) {
        List<String> categories = planDetailService.findTagCategories(planNo);
        if (categories == null || categories.isEmpty()) {
            return false;
        }

        for (String category : categories) {
            if (category != null && categoryKey.equalsIgnoreCase(category.trim())) {
                return true;
            }
        }
        return false;
    }

    private String normalizeTypeId(String rawTypeId) {
        if (rawTypeId == null) {
            return "adventurer";
        }

        String normalized = rawTypeId.trim().toLowerCase(Locale.ROOT);
        switch (normalized) {
            case "adventurer":
            case "\uBAA8\uD5D8\uAC00":
            case "\uD504\uB85C \uBAA8\uD5D8\uAC00":
                return "adventurer";
            case "healer":
            case "\uD790\uB7EC":
            case "\uD3C9\uD654\uB85C\uC6B4 \uD790\uB7EC":
                return "healer";
            case "explorer":
            case "\uD0D0\uD5D8\uAC00":
            case "\uB3C4\uC2DC \uD0D0\uD5D8\uAC00":
                return "explorer";
            case "foodie":
            case "\uC2DD\uB3C4\uB77D\uAC00":
                return "foodie";
            case "romantic":
            case "\uB0AD\uB9CC\uC8FC\uC758\uC790":
                return "romantic";
            default:
                if (normalized.contains("\uD790\uB7EC")) {
                    return "healer";
                }
                if (normalized.contains("\uD0D0\uD5D8") || normalized.contains("\uB3C4\uC2DC")) {
                    return "explorer";
                }
                if (normalized.contains("\uC2DD\uB3C4\uB77D") || normalized.contains("\uB9DB")) {
                    return "foodie";
                }
                if (normalized.contains("\uB0AD\uB9CC") || normalized.contains("\uC57C\uACBD")) {
                    return "romantic";
                }
                return "adventurer";
        }
    }

    private String resolveEmoji(String typeId) {
        switch (typeId) {
            case "healer":
                return "\uD83C\uDF3F";
            case "explorer":
                return "\uD83C\uDFD9\uFE0F";
            case "foodie":
                return "\uD83C\uDF5C";
            case "romantic":
                return "\uD83C\uDF03";
            case "adventurer":
            default:
                return "\uD83E\uDD20";
        }
    }

    private Map<String, String> buildTagMap(List<String> tagNames) {
        Map<String, String> map = new LinkedHashMap<>();
        if (tagNames == null) {
            return map;
        }

        int order = 1;
        for (String tagName : tagNames) {
            if (tagName == null) {
                continue;
            }

            String trimmed = tagName.trim();
            if (trimmed.isEmpty()) {
                continue;
            }

            String displayTag = trimmed.startsWith("#") ? trimmed : "#" + trimmed;
            map.put("tag" + order, displayTag);
            order++;

            if (order > 5) {
                break;
            }
        }

        return map;
    }
}
