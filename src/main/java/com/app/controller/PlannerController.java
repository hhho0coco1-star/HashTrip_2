package com.app.controller;

import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.CommunityDTO;
import com.app.dto.PlaceDTO;
import com.app.dto.PlaceReviewDTO;
import com.app.dto.PlanDetailDTO;
import com.app.dto.TagMasterDTO;
import com.app.dto.TravelPlanDTO;
import com.app.dto.UsersDTO;
import com.app.service.PlanDetailService;
import com.app.service.PlaceService;
import com.app.service.TravelPlanService;
import com.app.service.UsersService;
import com.app.service.impl.CommunityService;
import com.app.service.impl.SocialUserProvisionService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@RequestMapping("/planner")
public class PlannerController {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");
    private static final int PLAN_MEMO_MAX = 1000;
    private static final String COOKIE_LAST_PLAN = "lastPlannerPlanNo";
    private static final int COOKIE_AGE_DAYS = 30;

    private static final String MSG_LOGIN = "Login is required.";
    private static final String MSG_NOT_FOUND = "Plan not found.";
    private static final String MSG_FORBIDDEN = "You do not have permission to modify this plan.";
    private static final String MSG_SAVE_FAIL = "Failed to save the plan.";
    private static final String MSG_UPDATE_FAIL = "Failed to update the plan.";
    private static final String MSG_DELETE_FAIL = "Failed to delete the plan.";
    private static final String MSG_DETAIL_REQUIRED = "Add at least one place to the plan.";
    private static final String MSG_JSON_INVALID = "Invalid plan detail payload.";
    private static final String MSG_PLACE_RESOLVE = "Failed to resolve place information.";
    private static final String MSG_REVIEW_CONTENT = "Please enter review content.";

    @Autowired
    private TravelPlanService travelPlanService;
    @Autowired
    private PlanDetailService planDetailService;
    @Autowired
    private UsersService usersService;
    @Autowired
    private PlaceService placeService;
    @Autowired
    private CommunityService communityService;
    @Autowired
    private SocialUserProvisionService socialUserProvisionService;

    @GetMapping
    public String list(Authentication auth, RedirectAttributes ra, Model model,
            @RequestParam(required = false) String status) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        List<TravelPlanDTO> plans = travelPlanService.findUserTravelPlans(user.getUserNo());
        if (StringUtils.hasText(status)) {
            plans = plans.stream()
                    .filter(p -> status.equals(p.getPlanStatus()))
                    .collect(Collectors.toList());
        }
        for (TravelPlanDTO plan : plans) {
            plan.setPlanDetails(planDetailService.findPlanDetails(plan.getPlanNo()));
        }
        model.addAttribute("myPlans", plans);
        model.addAttribute("activeStatus", status);
        return "planner/planner-list";
    }

    /** Search nearby places for replacement suggestions. Requires login. */
    @GetMapping("/nearby-places")
    @ResponseBody
    public List<PlaceDTO> nearbyPlaces(Authentication auth,
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(defaultValue = "10") int radiusKm,
            @RequestParam(required = false) Long excludePlaceNo) {
        if (resolveUser(auth) == null) {
            return new ArrayList<>();
        }
        int safeRadius = Math.max(1, Math.min(50, radiusKm));
        return placeService.getPlacesNearby(lat, lng, safeRadius, excludePlaceNo);
    }

    /** Place preview data (photos + reviews) for replacement modal. */
    @GetMapping("/place-preview")
    @ResponseBody
    public Map<String, Object> placePreview(Authentication auth, @RequestParam Long placeNo) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("photoUrls", new ArrayList<String>());
        out.put("reviews", new ArrayList<Map<String, Object>>());
        if (resolveUser(auth) == null || placeNo == null) return out;
        try {
            List<String> urls = placeService.getPlacePhotoUrlsByPlaceNo(placeNo);
            if (urls != null) out.put("photoUrls", urls);
            List<PlaceReviewDTO> reviews = placeService.getPlaceReviewsByPlaceNo(placeNo);
            if (reviews != null) {
                int limit = 5;
                List<Map<String, Object>> list = new ArrayList<>();
                for (int i = 0; i < Math.min(limit, reviews.size()); i++) {
                    PlaceReviewDTO r = reviews.get(i);
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("rating", r.getRating());
                    m.put("commentContent", r.getCommentContent());
                    m.put("createdBy", r.getCreatedBy());
                    m.put("createdAt", r.getCreatedAt() != null ? r.getCreatedAt().getTime() : null);
                    list.add(m);
                }
                out.put("reviews", list);
            }
        } catch (Exception ignored) { }
        return out;
    }

    @GetMapping("/new")
    public String newPlan(Authentication auth, RedirectAttributes ra, Model model) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        TravelPlanDTO dto = new TravelPlanDTO();
        dto.setPlanStatus("PLANNING");
        dto.setPlanIsPublic("N");
        model.addAttribute("plan", dto);
        model.addAttribute("planDetailsJson", "[]");
        List<TagMasterDTO> allTags = usersService.getTagMasterList();
        List<TagMasterDTO> placeTags = allTags == null ? new ArrayList<>() : allTags.stream()
                .filter(t -> t != null && "LOCATION".equals(t.getTagCategory()))
                .collect(Collectors.toList());
        model.addAttribute("placeTagList", placeTags);
        return "planner/planner-new";
    }

    @GetMapping("/{planNo}/edit")
    public String edit(@PathVariable Long planNo, Authentication auth, RedirectAttributes ra, Model model,
                       HttpServletResponse response) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        TravelPlanDTO plan = travelPlanService.findTravelPlan(planNo);
        if (plan == null) {
            ra.addFlashAttribute("plannerError", MSG_NOT_FOUND);
            return "redirect:/planner";
        }
        if (!user.getUserNo().equals(plan.getUserNo())) {
            ra.addFlashAttribute("plannerError", MSG_FORBIDDEN);
            return "redirect:/planner";
        }
        writeCookie(response, COOKIE_LAST_PLAN, String.valueOf(planNo), COOKIE_AGE_DAYS * 24 * 60 * 60);

        List<PlanDetailDTO> details = planDetailService.findPlanDetails(planNo);
        LocalDate planStart = plan.getPlanStartDate() != null ? plan.getPlanStartDate().toLocalDate() : null;
        List<PlannerDetailView> viewList = toDetailViews(details, planStart);
        Map<Integer, List<PlannerDetailView>> byDay = viewList.stream()
                .collect(Collectors.groupingBy(PlannerDetailView::getDayNumber, LinkedHashMap::new, Collectors.toList()));

        CommunityDTO existingReview = communityService.getCommunityReviewByPlanNoAndUserNo(planNo, user.getUserNo());
        model.addAttribute("plan", plan);
        model.addAttribute("planDetailsJson", writeJson(viewList));
        model.addAttribute("detailsByDay", byDay);
        model.addAttribute("tagMasterList", usersService.getTagMasterList());
        model.addAttribute("hasCompleteReview", existingReview != null);
        model.addAttribute("existingReview", existingReview);
        return "planner/planner-edit";
    }

    @PostMapping
    public String insert(@ModelAttribute TravelPlanDTO dto,
                         @RequestParam(name = "planDetailsJson", required = false) String planDetailsJson,
                         Authentication auth, RedirectAttributes ra, HttpServletResponse response) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        try {
            List<PlanDetailDTO> details = parseDetails(planDetailsJson, user.getUserNo());
            if (details.isEmpty()) {
                ra.addFlashAttribute("plannerError", MSG_DETAIL_REQUIRED);
                return "redirect:/planner/new";
            }
            dto.setUserNo(user.getUserNo());
            dto.setPlanStatus("PLANNING");
            dto.setPlanIsPublic("N");
            ensurePlanDates(dto);
            if (!StringUtils.hasText(dto.getPlanTitle())) {
                dto.setPlanTitle(buildAutoTitle(dto.getPlanStartDate(), dto.getPlanEndDate(), details));
            } else {
                dto.setPlanTitle(dto.getPlanTitle().trim());
            }
            Long planNo = travelPlanService.insertTravelPlanWithDetails(dto, details);
            writeCookie(response, COOKIE_LAST_PLAN, String.valueOf(planNo), COOKIE_AGE_DAYS * 24 * 60 * 60);
            ra.addFlashAttribute("plannerMessage", "Plan saved.");
            return "redirect:/planner/" + planNo + "/edit";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("plannerError", e.getMessage());
            return "redirect:/planner/new";
        } catch (Exception e) {
            ra.addFlashAttribute("plannerError", MSG_SAVE_FAIL);
            return "redirect:/planner/new";
        }
    }

    @PostMapping("/{planNo}")
    public String update(@PathVariable Long planNo,
                         @ModelAttribute TravelPlanDTO dto,
                         @RequestParam(name = "planDetailsJson", required = false) String planDetailsJson,
                         Authentication auth, RedirectAttributes ra, HttpServletResponse response) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        try {
            List<PlanDetailDTO> details = parseDetails(planDetailsJson, user.getUserNo());
            if (details.isEmpty()) {
                ra.addFlashAttribute("plannerError", MSG_DETAIL_REQUIRED);
                return "redirect:/planner/" + planNo + "/edit";
            }
            TravelPlanDTO existing = travelPlanService.findTravelPlan(planNo);
            if (existing == null || !user.getUserNo().equals(existing.getUserNo())) {
                ra.addFlashAttribute("plannerError", MSG_FORBIDDEN);
                return "redirect:/planner";
            }
            dto.setPlanNo(planNo);
            dto.setUserNo(user.getUserNo());
            dto.setPlanStatus(existing.getPlanStatus() != null ? existing.getPlanStatus() : "PLANNING");
            dto.setPlanIsPublic(existing.getPlanIsPublic() != null ? existing.getPlanIsPublic() : "N");
            if (!StringUtils.hasText(dto.getPlanTitle())) {
                dto.setPlanTitle(buildAutoTitle(dto.getPlanStartDate(), dto.getPlanEndDate(), details));
            } else {
                dto.setPlanTitle(dto.getPlanTitle().trim());
            }
            travelPlanService.updateTravelPlanWithDetails(dto, details, user.getUserNo());
            writeCookie(response, COOKIE_LAST_PLAN, String.valueOf(planNo), COOKIE_AGE_DAYS * 24 * 60 * 60);
            ra.addFlashAttribute("plannerMessage", "Plan updated.");
            return "redirect:/planner/" + planNo + "/edit";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("plannerError", e.getMessage());
            return "redirect:/planner/" + planNo + "/edit";
        } catch (Exception e) {
            ra.addFlashAttribute("plannerError", MSG_UPDATE_FAIL);
            return "redirect:/planner/" + planNo + "/edit";
        }
    }

    /**
     * Complete trip and save review/rating/public flag.
     * Public trips are exposed to route recommendation.
     */
    @PostMapping("/{planNo}/complete-review")
    public String completeReview(
            @PathVariable Long planNo,
            @RequestParam String reviewContent,
            @RequestParam(required = false, defaultValue = "5") Integer rating,
            @RequestParam(required = false, defaultValue = "N") String planIsPublic,
            @RequestParam(required = false) String planTitle,
            Authentication auth, RedirectAttributes ra) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        if (!StringUtils.hasText(reviewContent) || reviewContent.trim().isEmpty()) {
            ra.addFlashAttribute("plannerError", MSG_REVIEW_CONTENT);
            return "redirect:/planner/" + planNo + "/edit";
        }
        TravelPlanDTO existing = travelPlanService.findTravelPlan(planNo);
        if (existing == null || !user.getUserNo().equals(existing.getUserNo())) {
            ra.addFlashAttribute("plannerError", MSG_FORBIDDEN);
            return "redirect:/planner";
        }
        int r = Math.min(5, Math.max(1, rating == null ? 5 : rating));
        String isPublic = "Y".equalsIgnoreCase(planIsPublic != null ? planIsPublic.trim() : "N") ? "Y" : "N";
        existing.setPlanStatus("COMPLETED");
        existing.setPlanIsPublic(isPublic);
        if (StringUtils.hasText(planTitle)) {
            existing.setPlanTitle(planTitle.trim());
        }
        travelPlanService.updateTravelPlan(existing);
        CommunityDTO existingReview = communityService.getCommunityReviewByPlanNoAndUserNo(planNo, user.getUserNo());
        if (existingReview != null && existingReview.getReviewNo() != null) {
            communityService.updateCommunityReview(existingReview.getReviewNo(), user.getUserNo(), reviewContent.trim(), r);
            ra.addFlashAttribute("plannerMessage", "Review updated." + ("Y".equals(isPublic) ? " Public route recommendation enabled." : ""));
        } else {
            communityService.addCommunityReview(planNo, user.getUserNo(), reviewContent.trim(), r);
            ra.addFlashAttribute("plannerMessage", "Trip completed and review created." + ("Y".equals(isPublic) ? " Public route recommendation enabled." : ""));
        }
        return "redirect:/planner/" + planNo + "/edit";
    }

    @PostMapping("/{planNo}/delete")
    public String delete(@PathVariable Long planNo, Authentication auth, RedirectAttributes ra,
                         HttpServletResponse response) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        try {
            travelPlanService.deleteTravelPlan(planNo, user.getUserNo());
            removeCookie(response, COOKIE_LAST_PLAN);
            ra.addFlashAttribute("plannerMessage", "Plan deleted.");
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("plannerError", e.getMessage());
        } catch (Exception e) {
            ra.addFlashAttribute("plannerError", MSG_DELETE_FAIL);
        }
        return "redirect:/planner";
    }

    private UsersDTO resolveUser(Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            return null;
        }

        String authId = null;
        if (auth instanceof OAuth2AuthenticationToken) {
            OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) auth;
            Object principal = token.getPrincipal();
            if (principal instanceof OAuth2User) {
                OAuth2User oAuth2User = (OAuth2User) principal;
                try {
                    socialUserProvisionService.provisionIfMissing(
                            token.getAuthorizedClientRegistrationId(),
                            oAuth2User.getAttributes());
                } catch (Exception ignored) {
                    // Ignore provisioning errors here and try resolving existing user.
                }
                authId = socialUserProvisionService.resolveSocialAuthId(
                        token.getAuthorizedClientRegistrationId(),
                        oAuth2User.getAttributes());
            }
        }

        if (!StringUtils.hasText(authId)) {
            authId = auth.getName();
        }
        if (!StringUtils.hasText(authId)) {
            return null;
        }
        UsersDTO user = usersService.getUserByAuthId(authId.trim());
        if (user != null) {
            return user;
        }

        if (auth instanceof OAuth2AuthenticationToken) {
            OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) auth;
            String provider = token.getAuthorizedClientRegistrationId();
            String principalName = auth.getName();
            if (StringUtils.hasText(provider) && StringUtils.hasText(principalName)) {
                String candidateAuthId = provider.trim().toLowerCase(Locale.ROOT)
                        + "_" + principalName.trim();
                return usersService.getUserByAuthId(candidateAuthId);
            }
        }

        return null;
    }

    private void ensurePlanDates(TravelPlanDTO dto) {
        if (dto.getPlanStartDate() == null) {
            dto.setPlanStartDate(Date.valueOf(LocalDate.now()));
        }
        if (dto.getPlanEndDate() == null) {
            dto.setPlanEndDate(Date.valueOf(LocalDate.now().plusDays(1)));
        }
    }

    private String buildAutoTitle(Date start, Date end, List<PlanDetailDTO> details) {
        String datePart;
        if (start != null && end != null) {
            LocalDate s = start.toLocalDate();
            LocalDate e = end.toLocalDate();
            datePart = s.getMonthValue() + "/" + s.getDayOfMonth() + "~" + e.getMonthValue() + "/" + e.getDayOfMonth();
        } else {
            datePart = "Trip";
        }

        String placeHint = "";
        if (details != null && !details.isEmpty()) {
            PlanDetailDTO first = details.get(0);
            if (first != null) {
                if (StringUtils.hasText(first.getPlaceName())) {
                    placeHint = first.getPlaceName().trim();
                } else if (StringUtils.hasText(first.getPlaceAddress())) {
                    placeHint = first.getPlaceAddress().trim();
                }
            }
        }

        if (StringUtils.hasText(placeHint)) {
            if (placeHint.length() > 20) {
                placeHint = placeHint.substring(0, 20);
            }
            return (datePart + " " + placeHint + " Trip").trim();
        }
        return (datePart + " Trip").trim();
    }
    private List<PlannerDetailView> toDetailViews(List<PlanDetailDTO> details, LocalDate planStartDate) {
        List<PlannerDetailView> list = new ArrayList<>();
        if (details == null) return list;
        for (PlanDetailDTO d : details) {
            if (d == null) continue;
            PlannerDetailView v = new PlannerDetailView();
            v.setId(d.getPlanDetailNo() != null ? "pd_" + d.getPlanDetailNo() : "p_" + System.currentTimeMillis());
            v.setPlanDetailNo(d.getPlanDetailNo());
            v.setPlaceNo(d.getPlaceNo());
            v.setPlaceName(d.getPlaceName());
            v.setPlaceAddress(d.getPlaceAddress());
            v.setPlaceLatitude(d.getPlaceLatitude());
            v.setPlaceLongitude(d.getPlaceLongitude());
            v.setMemo(parseMemoOnly(d.getPlanMeno(), d.getPlaceName()));
            if (d.getDetailStartDate() != null) {
                LocalDateTime ldt = d.getDetailStartDate().toLocalDateTime();
                v.setDate(ldt.toLocalDate().toString());
                v.setTime(ldt.toLocalTime().format(TIME_FMT));
            }
            if (d.getDetailEndDate() != null) {
                LocalDateTime ldt = d.getDetailEndDate().toLocalDateTime();
                v.setEndDate(ldt.toLocalDate().toString());
                v.setEndTime(ldt.toLocalTime().format(TIME_FMT));
            }
            int dayNum = 1;
            if (planStartDate != null && d.getDetailStartDate() != null) {
                LocalDate detailDate = d.getDetailStartDate().toLocalDateTime().toLocalDate();
                dayNum = (int) java.time.temporal.ChronoUnit.DAYS.between(planStartDate, detailDate) + 1;
                if (dayNum < 1) dayNum = 1;
            }
            v.setDayNumber(dayNum);
            list.add(v);
        }
        return list;
    }

    private String parseMemoOnly(String planMeno, String placeName) {
        if (!StringUtils.hasText(planMeno)) return "";
        if (!StringUtils.hasText(placeName)) return planMeno.trim();
        String prefix = placeName + "\n";
        if (planMeno.startsWith(prefix)) return planMeno.substring(prefix.length()).trim();
        if (planMeno.trim().equals(placeName)) return "";
        return planMeno.trim();
    }

    private List<PlanDetailDTO> parseDetails(String json, Long userNo) {
        if (!StringUtils.hasText(json)) return new ArrayList<>();
        List<DetailInput> inputs;
        try {
            inputs = OBJECT_MAPPER.readValue(json, new TypeReference<List<DetailInput>>() {});
        } catch (IOException e) {
            throw new IllegalArgumentException(MSG_JSON_INVALID);
        }
        List<PlanDetailDTO> result = new ArrayList<>();
        int order = 1;
        for (DetailInput in : inputs) {
            if (in == null) continue;
            Long placeNo = in.getPlaceNo() != null && in.getPlaceNo() > 0 ? in.getPlaceNo() : null;
            String name = trim(in.getPlaceName());
            String addr = trim(in.getPlaceAddress());
            String memo = trim(in.getMemo());
            if (placeNo == null && StringUtils.hasText(name)) {
                try {
                    placeNo = placeService.resolvePlaceNoForPlan(name, addr, in.getPlaceLatitude(), in.getPlaceLongitude());
                } catch (Exception e) {
                    throw new IllegalArgumentException(MSG_PLACE_RESOLVE);
                }
            }
            String mergedMemo = mergeMemo(placeNo, name, addr, memo);
            if (placeNo == null && mergedMemo == null) continue;

            PlanDetailDTO d = new PlanDetailDTO();
            d.setUserNo(userNo);
            d.setPlaceNo(placeNo);
            d.setPlanVisitOrder(order++);
            d.setPlanMeno(mergedMemo);
            d.setDetailStartDate(parseTs(in.getDate(), in.getTime()));
            d.setDetailEndDate(parseTs(in.getEndDate(), in.getEndTime()));
            result.add(d);
        }
        return result;
    }

    private String mergeMemo(Long placeNo, String name, String addr, String memo) {
        if (placeNo != null) return truncate(memo, PLAN_MEMO_MAX);
        if (!StringUtils.hasText(name) && !StringUtils.hasText(addr) && !StringUtils.hasText(memo)) return null;
        StringBuilder sb = new StringBuilder();
        if (StringUtils.hasText(name)) sb.append(name);
        if (StringUtils.hasText(addr)) { if (sb.length() > 0) sb.append('\n'); sb.append(addr); }
        if (StringUtils.hasText(memo)) { if (sb.length() > 0) sb.append('\n'); sb.append(memo); }
        return truncate(sb.toString(), PLAN_MEMO_MAX);
    }

    private Timestamp parseTs(String dateStr, String timeStr) {
        if (!StringUtils.hasText(dateStr)) return null;
        try {
            LocalDate d = LocalDate.parse(dateStr.trim());
            LocalTime t = StringUtils.hasText(timeStr) ? LocalTime.parse(timeStr.trim(), TIME_FMT) : LocalTime.MIDNIGHT;
            return Timestamp.valueOf(LocalDateTime.of(d, t));
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private String trim(String s) {
        return s != null ? s.trim() : null;
    }

    private String truncate(String s, int max) {
        if (s == null || s.length() <= max) return s;
        return s.substring(0, max);
    }

    private String writeJson(Object o) {
        try {
            return OBJECT_MAPPER.writeValueAsString(o);
        } catch (IOException e) {
            return "[]";
        }
    }

    private void writeCookie(HttpServletResponse response, String name, String value, int maxAgeSeconds) {
        Cookie c = new Cookie(name, value);
        c.setPath("/");
        c.setMaxAge(maxAgeSeconds);
        c.setHttpOnly(true);
        response.addCookie(c);
    }

    private void removeCookie(HttpServletResponse response, String name) {
        Cookie c = new Cookie(name, "");
        c.setPath("/");
        c.setMaxAge(0);
        response.addCookie(c);
    }

    public static class DetailInput {
        private Long placeNo;
        private String placeName;
        private String placeAddress;
        private Double placeLatitude;
        private Double placeLongitude;
        private String date;
        private String time;
        private String endDate;
        private String endTime;
        private String memo;
        public Long getPlaceNo() { return placeNo; }
        public void setPlaceNo(Long placeNo) { this.placeNo = placeNo; }
        public String getPlaceName() { return placeName; }
        public void setPlaceName(String placeName) { this.placeName = placeName; }
        public String getPlaceAddress() { return placeAddress; }
        public void setPlaceAddress(String placeAddress) { this.placeAddress = placeAddress; }
        public Double getPlaceLatitude() { return placeLatitude; }
        public void setPlaceLatitude(Double placeLatitude) { this.placeLatitude = placeLatitude; }
        public Double getPlaceLongitude() { return placeLongitude; }
        public void setPlaceLongitude(Double placeLongitude) { this.placeLongitude = placeLongitude; }
        public String getDate() { return date; }
        public void setDate(String date) { this.date = date; }
        public String getTime() { return time; }
        public void setTime(String time) { this.time = time; }
        public String getEndDate() { return endDate; }
        public void setEndDate(String endDate) { this.endDate = endDate; }
        public String getEndTime() { return endTime; }
        public void setEndTime(String endTime) { this.endTime = endTime; }
        public String getMemo() { return memo; }
        public void setMemo(String memo) { this.memo = memo; }
    }

    public static class PlannerDetailView {
        private String id;
        private Long planDetailNo;
        private Long placeNo;
        private String placeName;
        private String placeAddress;
        private Double placeLatitude;
        private Double placeLongitude;
        private String date;
        private String time;
        private String endDate;
        private String endTime;
        private String memo;
        private int dayNumber;
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public Long getPlanDetailNo() { return planDetailNo; }
        public void setPlanDetailNo(Long planDetailNo) { this.planDetailNo = planDetailNo; }
        public Long getPlaceNo() { return placeNo; }
        public void setPlaceNo(Long placeNo) { this.placeNo = placeNo; }
        public String getPlaceName() { return placeName; }
        public void setPlaceName(String placeName) { this.placeName = placeName; }
        public String getPlaceAddress() { return placeAddress; }
        public void setPlaceAddress(String placeAddress) { this.placeAddress = placeAddress; }
        public Double getPlaceLatitude() { return placeLatitude; }
        public void setPlaceLatitude(Double placeLatitude) { this.placeLatitude = placeLatitude; }
        public Double getPlaceLongitude() { return placeLongitude; }
        public void setPlaceLongitude(Double placeLongitude) { this.placeLongitude = placeLongitude; }
        public String getDate() { return date; }
        public void setDate(String date) { this.date = date; }
        public String getTime() { return time; }
        public void setTime(String time) { this.time = time; }
        public String getEndDate() { return endDate; }
        public void setEndDate(String endDate) { this.endDate = endDate; }
        public String getEndTime() { return endTime; }
        public void setEndTime(String endTime) { this.endTime = endTime; }
        public String getMemo() { return memo; }
        public void setMemo(String memo) { this.memo = memo; }
        public int getDayNumber() { return dayNumber; }
        public void setDayNumber(int dayNumber) { this.dayNumber = dayNumber; }
    }
}
