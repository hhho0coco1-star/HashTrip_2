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
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.PlanDetailDTO;
import com.app.dto.TagMasterDTO;
import com.app.dto.TravelPlanDTO;
import com.app.dto.UsersDTO;
import com.app.service.PlanDetailService;
import com.app.service.PlaceService;
import com.app.service.TravelPlanService;
import com.app.service.UsersService;
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

    private static final String MSG_LOGIN = "로그인이 필요합니다.";
    private static final String MSG_NOT_FOUND = "해당 일정을 찾을 수 없습니다.";
    private static final String MSG_FORBIDDEN = "수정 권한이 없습니다.";
    private static final String MSG_SAVE_FAIL = "저장 중 오류가 발생했습니다.";
    private static final String MSG_UPDATE_FAIL = "수정 중 오류가 발생했습니다.";
    private static final String MSG_DELETE_FAIL = "삭제 중 오류가 발생했습니다.";
    private static final String MSG_DETAIL_REQUIRED = "장소를 최소 1개 이상 추가해 주세요.";
    private static final String MSG_JSON_INVALID = "일정 데이터 형식이 올바르지 않습니다.";
    private static final String MSG_PLACE_RESOLVE = "장소 정보 조회에 실패했습니다.";

    @Autowired
    private TravelPlanService travelPlanService;
    @Autowired
    private PlanDetailService planDetailService;
    @Autowired
    private UsersService usersService;
    @Autowired
    private PlaceService placeService;

    @GetMapping
    public String list(Authentication auth, RedirectAttributes ra, Model model) {
        UsersDTO user = resolveUser(auth);
        if (user == null || user.getUserNo() == null) {
            ra.addFlashAttribute("plannerError", MSG_LOGIN);
            return "redirect:/auth/login";
        }
        model.addAttribute("myPlans", travelPlanService.findUserTravelPlans(user.getUserNo()));
        return "planner/planner-list";
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

        model.addAttribute("plan", plan);
        model.addAttribute("planDetailsJson", writeJson(viewList));
        model.addAttribute("detailsByDay", byDay);
        model.addAttribute("tagMasterList", usersService.getTagMasterList());
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
            ra.addFlashAttribute("plannerMessage", "일정이 저장되었습니다.");
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
            ra.addFlashAttribute("plannerMessage", "일정이 수정되었습니다.");
            return "redirect:/planner/" + planNo + "/edit";
        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("plannerError", e.getMessage());
            return "redirect:/planner/" + planNo + "/edit";
        } catch (Exception e) {
            ra.addFlashAttribute("plannerError", MSG_UPDATE_FAIL);
            return "redirect:/planner/" + planNo + "/edit";
        }
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
            ra.addFlashAttribute("plannerMessage", "일정이 삭제되었습니다.");
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
        String authId = auth.getName();
        if (!StringUtils.hasText(authId)) return null;
        return usersService.getUserByAuthId(authId.trim());
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
        String datePart = "";
        if (start != null && end != null) {
            LocalDate s = start.toLocalDate();
            LocalDate e = end.toLocalDate();
            datePart = s.getMonthValue() + "/" + s.getDayOfMonth() + "~" + e.getMonthValue() + "/" + e.getDayOfMonth();
        } else {
            datePart = "여행";
        }
        String region = "";
        if (details != null && !details.isEmpty()) {
            PlanDetailDTO first = details.get(0);
            String name = first.getPlaceName();
            String addr = first.getPlaceAddress();
            if (StringUtils.hasText(name) && (name.contains("제주") || name.contains("서울") || name.contains("부산") || name.contains("강릉"))) {
                region = name.contains("제주") ? "제주" : (name.contains("서울") ? "서울" : (name.contains("부산") ? "부산" : (name.contains("강릉") ? "강릉" : "")));
            }
            if (region.isEmpty() && StringUtils.hasText(addr)) {
                if (addr.contains("제주")) region = "제주";
                else if (addr.contains("서울")) region = "서울";
                else if (addr.contains("부산")) region = "부산";
                else if (addr.contains("강릉")) region = "강릉";
            }
        }
        return (datePart + " " + (region.isEmpty() ? "여행" : region + " 여행")).trim();
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
