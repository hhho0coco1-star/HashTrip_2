package com.app.service.impl;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dto.RouteDTO;
import com.app.dto.TagCategoryDTO;
import com.app.dto.TravelPlanDTO;
import com.app.dto.TravelerTypeDTO;
import com.app.dto.UserTagMapDTO;
import com.app.service.PlanDetailService;
import com.app.service.TravelPlanService;
import com.app.service.UsersService;

@Service
public class RouteService {

    @Autowired
    private PlanDetailService planDetailService;

    @Autowired
    private TravelPlanService travelPlanService;

    @Autowired
    private UsersService usersService;

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

    public Integer applySimilarityScores(
            List<RouteDTO> routes,
            List<UserTagMapDTO> userTags,
            Long currentUserNo) {
        if (routes == null || routes.isEmpty()) {
            return null;
        }

        Map<String, Integer> currentUserTagWeights = buildUserTagWeights(
                userTags == null ? Collections.emptyList() : userTags);
        boolean hasCurrentUserTags = !currentUserTagWeights.isEmpty();

        Map<Long, Map<String, Integer>> authorTagWeightCache = new HashMap<>();
        int bestScore = 0;
        for (RouteDTO route : routes) {
            int similarityScore = hasCurrentUserTags
                    ? calculateSimilarityScore(route, currentUserTagWeights, authorTagWeightCache, currentUserNo)
                    : calculateFallbackScore(route, currentUserNo);
            route.setMatchScore(similarityScore);
            if (similarityScore > bestScore) {
                bestScore = similarityScore;
            }
        }

        routes.sort(
                Comparator.comparing(RouteDTO::getMatchScore, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(RouteDTO::getSavedCount, Comparator.reverseOrder())
                        .thenComparing(RouteDTO::getId, Comparator.nullsLast(Comparator.reverseOrder())));

        return bestScore == 0 ? null : bestScore;
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
        route.setUserNo(travelPlan.getUserNo());
        route.setTitle(defaultIfBlank(travelPlan.getPlanTitle(), "Untitled Plan"));
        route.setTypeId(defaultIfBlank(travelPlan.getTypeId(), "adventurer"));
        route.setDescription(defaultIfBlank(travelPlan.getDescription(), buildDescription(travelPlan)));
        route.setLikeCount(defaultIfNull(travelPlan.getLikeCount(), 0));
        route.setSavedCount(defaultIfNull(travelPlan.getSavedCount(), 0));
        route.setMatchScore(defaultIfNull(travelPlan.getMatchScore(), 70));
        route.setUserName(defaultIfBlank(travelPlan.getUserName(), "Traveler"));

        return route;
    }

    private int calculateSimilarityScore(
            RouteDTO route,
            Map<String, Integer> currentUserTagWeights,
            Map<Long, Map<String, Integer>> authorTagWeightCache,
            Long currentUserNo) {
        if (route == null) {
            return 40;
        }

        Long authorUserNo = route.getUserNo();
        if (authorUserNo == null) {
            return clampScore(defaultIfNull(route.getMatchScore(), 65));
        }
        if (currentUserNo != null && currentUserNo.equals(authorUserNo)) {
            return 100;
        }

        Map<String, Integer> authorTagWeights = authorTagWeightCache.get(authorUserNo);
        if (authorTagWeights == null) {
            List<UserTagMapDTO> authorTags = usersService.getUserTagsByUserNo(authorUserNo);
            authorTagWeights = buildUserTagWeights(authorTags == null ? Collections.emptyList() : authorTags);
            authorTagWeightCache.put(authorUserNo, authorTagWeights);
        }

        if (authorTagWeights.isEmpty()) {
            return clampScore(defaultIfNull(route.getMatchScore(), 65));
        }

        return calculateTagSimilarityScore(currentUserTagWeights, authorTagWeights, route.getSavedCount());
    }

    private int calculateFallbackScore(RouteDTO route, Long currentUserNo) {
        if (route == null) {
            return 40;
        }

        Long authorUserNo = route.getUserNo();
        if (currentUserNo != null && currentUserNo.equals(authorUserNo)) {
            return 100;
        }
        return clampScore(defaultIfNull(route.getMatchScore(), 65));
    }

    private int calculateTagSimilarityScore(
            Map<String, Integer> currentUserTagWeights,
            Map<String, Integer> authorTagWeights,
            int savedCount) {
        Set<String> allTags = new LinkedHashSet<>();
        allTags.addAll(currentUserTagWeights.keySet());
        allTags.addAll(authorTagWeights.keySet());

        int intersectionWeight = 0;
        int unionWeight = 0;
        int authorTotalWeight = 0;
        for (String tag : allTags) {
            int mine = positiveWeight(currentUserTagWeights.get(tag));
            int author = positiveWeight(authorTagWeights.get(tag));
            intersectionWeight += Math.min(mine, author);
            unionWeight += Math.max(mine, author);
            authorTotalWeight += author;
        }

        if (unionWeight == 0 || authorTotalWeight == 0) {
            return 40;
        }

        double jaccardSimilarity = (double) intersectionWeight / unionWeight;
        double authorCoverage = (double) intersectionWeight / authorTotalWeight;
        int popularityBonus = Math.min(6, Math.max(0, savedCount / 7));

        int score = 44
                + (int) Math.round(jaccardSimilarity * 38D)
                + (int) Math.round(authorCoverage * 10D)
                + popularityBonus;

        if (intersectionWeight == 0) {
            score = Math.max(40, score - 10);
        }

        return clampScore(score);
    }

    private Map<String, Integer> buildUserTagWeights(List<UserTagMapDTO> userTags) {
        Map<String, Integer> tagWeights = new HashMap<>();
        for (UserTagMapDTO userTag : userTags) {
            if (userTag == null) {
                continue;
            }

            String normalizedTagName = normalizeTagToken(userTag.getTagName());
            if (normalizedTagName == null) {
                normalizedTagName = normalizeTagToken(userTag.getTagCode());
            }
            if (normalizedTagName == null) {
                continue;
            }

            Integer currentWeight = tagWeights.get(normalizedTagName);
            tagWeights.put(normalizedTagName, currentWeight == null ? 1 : currentWeight + 1);
        }
        return tagWeights;
    }

    private int positiveWeight(Integer weight) {
        return weight == null || weight < 0 ? 0 : weight;
    }

    private String normalizeTagToken(String tagValue) {
        if (tagValue == null) {
            return null;
        }

        String normalized = tagValue.trim().toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) {
            return null;
        }
        if (normalized.startsWith("#")) {
            normalized = normalized.substring(1).trim();
        }
        return normalized.isEmpty() ? null : normalized;
    }

    private int clampScore(int score) {
        if (score < 40) {
            return 40;
        }
        return Math.min(score, 98);
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

    /**
     * 선택한 장소 태그(이름)와 루트의 장소 태그 일치도로 점수 부여 후 적합도 순 정렬.
     * (어디로 갈까요에서 선택한 태그를 임시로 사용해 검색할 때 사용)
     */
    public void applyPlaceTagScores(List<RouteDTO> routes, List<String> selectedTagNames) {
        if (routes == null || routes.isEmpty()) {
            return;
        }
        if (selectedTagNames == null) {
            selectedTagNames = Collections.emptyList();
        }
        Set<String> selectedNormalized = new LinkedHashSet<>();
        for (String name : selectedTagNames) {
            if (name != null && !name.trim().isEmpty()) {
                selectedNormalized.add(name.trim().toLowerCase(Locale.ROOT));
            }
        }
        for (RouteDTO route : routes) {
            List<String> routeTagNames = planDetailService.findTagNames(route.getId());
            Set<String> routeNormalized = new LinkedHashSet<>();
            if (routeTagNames != null) {
                for (String name : routeTagNames) {
                    if (name != null && !name.trim().isEmpty()) {
                        routeNormalized.add(name.trim().toLowerCase(Locale.ROOT));
                    }
                }
            }
            int matchCount = 0;
            for (String s : selectedNormalized) {
                if (routeNormalized.contains(s)) {
                    matchCount++;
                }
            }
            int score = selectedNormalized.isEmpty()
                    ? 50
                    : Math.min(98, 40 + (matchCount * 60 / selectedNormalized.size()));
            route.setMatchScore(score);
        }
        routes.sort(
                Comparator.comparing(RouteDTO::getMatchScore, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(RouteDTO::getSavedCount, Comparator.reverseOrder())
                        .thenComparing(RouteDTO::getId, Comparator.nullsLast(Comparator.reverseOrder())));
    }
}
