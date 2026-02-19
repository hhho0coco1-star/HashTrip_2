package com.app.controller;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.app.dto.PlanDetailDTO;
import com.app.dto.TravelPlanDTO;
import com.app.dto.UsersDTO;
import com.app.service.PlanDetailService;
import com.app.service.PlaceService;
import com.app.service.TravelPlanService;
import com.app.service.UsersService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class PlanController {

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final int PLAN_MEMO_MAX_LENGTH = 1000;

    @Autowired
    private TravelPlanService planService;

    @Autowired
    private PlanDetailService planDetailService;

    @Autowired
    private UsersService usersService;

    @Autowired
    private PlaceService placeService;

    @GetMapping("/plan")
    public String planList(Authentication authentication, RedirectAttributes redirectAttributes, Model model) {
        UsersDTO currentUser = resolveCurrentUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            redirectAttributes.addFlashAttribute("planSaveError", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }

        model.addAttribute("myPlans", planService.findUserTravelPlans(currentUser.getUserNo()));
        return "plan/plan-list";
    }

    @GetMapping("/plan/new")
    public String planCreatePage(Authentication authentication, RedirectAttributes redirectAttributes, Model model) {
        UsersDTO currentUser = resolveCurrentUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            redirectAttributes.addFlashAttribute("planSaveError", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }

        TravelPlanDTO defaultPlan = new TravelPlanDTO();
        defaultPlan.setPlanStatus("PLANNING");
        defaultPlan.setPlanIsPublic("N");

        model.addAttribute("editMode", false);
        model.addAttribute("plan", defaultPlan);
        model.addAttribute("planDetailsJson", "[]");
        return "plan/plan";
    }

    @GetMapping("/plan/{planNo}/edit")
    public String planEditPage(@PathVariable Long planNo,
                               Authentication authentication,
                               RedirectAttributes redirectAttributes,
                               Model model) {
        UsersDTO currentUser = resolveCurrentUser(authentication);
        if (currentUser == null || currentUser.getUserNo() == null) {
            redirectAttributes.addFlashAttribute("planSaveError", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }

        TravelPlanDTO plan = planService.findTravelPlan(planNo);
        if (plan == null) {
            redirectAttributes.addFlashAttribute("planSaveError", "일정을 찾을 수 없습니다.");
            return "redirect:/plan";
        }
        if (plan.getUserNo() == null || !currentUser.getUserNo().equals(plan.getUserNo())) {
            redirectAttributes.addFlashAttribute("planSaveError", "본인 일정만 수정할 수 있습니다.");
            return "redirect:/plan";
        }

        List<PlanDetailViewInput> detailViewList = toPlanDetailViewInputs(
                planDetailService.findPlanDetails(planNo));

        model.addAttribute("editMode", true);
        model.addAttribute("plan", plan);
        model.addAttribute("planDetailsJson", writeJson(detailViewList));
        return "plan/plan";
    }

    @PostMapping("/plan")
    public String insertPlan(@ModelAttribute TravelPlanDTO travelPlanDTO,
                             @RequestParam(name = "planDetailsJson", required = false) String planDetailsJson,
                             Authentication authentication,
                             RedirectAttributes redirectAttributes) {
        UsersDTO usersDTO = resolveCurrentUser(authentication);
        if (usersDTO == null || usersDTO.getUserNo() == null) {
            redirectAttributes.addFlashAttribute("planSaveError", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }

        try {
            List<PlanDetailDTO> planDetails = parseAndBuildPlanDetails(planDetailsJson, usersDTO.getUserNo());

            travelPlanDTO.setUserNo(usersDTO.getUserNo());
            sanitizePlanHeader(travelPlanDTO);

            Long createdPlanNo = planService.insertTravelPlanWithDetails(travelPlanDTO, planDetails);
            redirectAttributes.addFlashAttribute("planSaveMessage", "일정이 저장되었습니다.");
            return "redirect:/plan/" + createdPlanNo + "/edit";
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("planSaveError", e.getMessage());
            return "redirect:/plan/new";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("planSaveError", "일정 저장 중 오류가 발생했습니다.");
            return "redirect:/plan/new";
        }
    }

    @PostMapping("/plan/{planNo}")
    public String updatePlan(@PathVariable Long planNo,
                             @ModelAttribute TravelPlanDTO travelPlanDTO,
                             @RequestParam(name = "planDetailsJson", required = false) String planDetailsJson,
                             Authentication authentication,
                             RedirectAttributes redirectAttributes) {
        UsersDTO usersDTO = resolveCurrentUser(authentication);
        if (usersDTO == null || usersDTO.getUserNo() == null) {
            redirectAttributes.addFlashAttribute("planSaveError", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }

        try {
            List<PlanDetailDTO> planDetails = parseAndBuildPlanDetails(planDetailsJson, usersDTO.getUserNo());

            travelPlanDTO.setPlanNo(planNo);
            travelPlanDTO.setUserNo(usersDTO.getUserNo());
            sanitizePlanHeader(travelPlanDTO);

            planService.updateTravelPlanWithDetails(travelPlanDTO, planDetails, usersDTO.getUserNo());
            redirectAttributes.addFlashAttribute("planSaveMessage", "일정이 수정되었습니다.");
            return "redirect:/plan/" + planNo + "/edit";
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("planSaveError", e.getMessage());
            return "redirect:/plan/" + planNo + "/edit";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("planSaveError", "일정 수정 중 오류가 발생했습니다.");
            return "redirect:/plan/" + planNo + "/edit";
        }
    }

    private UsersDTO resolveCurrentUser(Authentication authentication) {
        String currentAuthId = resolveAuthenticatedAuthId(authentication);
        if (currentAuthId == null) {
            return null;
        }
        return usersService.getUserByAuthId(currentAuthId);
    }

    private void sanitizePlanHeader(TravelPlanDTO travelPlanDTO) {
        if (!StringUtils.hasText(travelPlanDTO.getPlanTitle())) {
            throw new IllegalArgumentException("일정 제목을 입력해 주세요.");
        }

        travelPlanDTO.setPlanTitle(travelPlanDTO.getPlanTitle().trim());
        travelPlanDTO.setPlanIsPublic("Y".equalsIgnoreCase(travelPlanDTO.getPlanIsPublic()) ? "Y" : "N");

        if (!StringUtils.hasText(travelPlanDTO.getPlanStatus())) {
            travelPlanDTO.setPlanStatus("PLANNING");
        } else {
            travelPlanDTO.setPlanStatus(travelPlanDTO.getPlanStatus().trim().toUpperCase());
        }
    }

    private List<PlanDetailDTO> parseAndBuildPlanDetails(String planDetailsJson, Long userNo) {
        List<PlanDetailInput> detailInputs = parsePlanDetailsJson(planDetailsJson);
        List<PlanDetailDTO> planDetails = toPlanDetailDTOs(detailInputs, userNo);
        if (planDetails.isEmpty()) {
            throw new IllegalArgumentException("일정에 장소를 최소 1개 이상 추가해 주세요.");
        }
        return planDetails;
    }

    private List<PlanDetailInput> parsePlanDetailsJson(String planDetailsJson) {
        if (!StringUtils.hasText(planDetailsJson)) {
            return Collections.emptyList();
        }
        try {
            return OBJECT_MAPPER.readValue(planDetailsJson, new TypeReference<List<PlanDetailInput>>() {});
        } catch (IOException e) {
            throw new IllegalArgumentException("일정 상세 데이터 형식이 올바르지 않습니다.");
        }
    }

    private List<PlanDetailDTO> toPlanDetailDTOs(List<PlanDetailInput> detailInputs, Long userNo) {
        List<PlanDetailDTO> details = new ArrayList<>();
        int visitOrder = 1;

        for (PlanDetailInput input : detailInputs) {
            if (input == null) {
                continue;
            }

            Long placeNo = normalizePlaceNo(input.getPlaceNo());
            String placeName = normalizeText(input.getPlaceName());
            String placeAddress = normalizeText(input.getPlaceAddress());
            Double placeLatitude = input.getPlaceLatitude();
            Double placeLongitude = input.getPlaceLongitude();
            String memo = normalizeText(input.getMemo());
            Date startDate = parseSqlDate(input.getDate());
            Date endDate = parseSqlDate(input.getEndDate());

            if (placeNo == null && !StringUtils.hasText(placeAddress) && StringUtils.hasText(memo)) {
                String inferredAddress = extractAddressFromMemo(memo);
                if (StringUtils.hasText(inferredAddress)) {
                    placeAddress = inferredAddress;
                    memo = removeFirstLine(memo);
                }
            }

            if (placeNo == null && StringUtils.hasText(placeName)) {
                placeNo = resolvePlaceNoSafely(placeName, placeAddress, placeLatitude, placeLongitude);
            }

            String mergedMemo = buildMergedMemo(placeNo, placeName, placeAddress, memo);

            if (placeNo == null && mergedMemo == null && startDate == null && endDate == null) {
                continue;
            }

            PlanDetailDTO planDetailDTO = new PlanDetailDTO();
            planDetailDTO.setUserNo(userNo);
            planDetailDTO.setPlaceNo(placeNo);
            planDetailDTO.setPlanVisitOrder(visitOrder++);
            planDetailDTO.setPlanMeno(mergedMemo);
            planDetailDTO.setDetailStartDate(startDate);
            planDetailDTO.setDetailEndDate(endDate);
            details.add(planDetailDTO);
        }

        return details;
    }

    private Long resolvePlaceNoSafely(String placeName, String placeAddress, Double placeLatitude, Double placeLongitude) {
        try {
            return placeService.resolvePlaceNoForPlan(placeName, placeAddress, placeLatitude, placeLongitude);
        } catch (Exception e) {
            throw new IllegalArgumentException("장소 정보를 저장하는 중 오류가 발생했습니다.");
        }
    }

    private String buildMergedMemo(Long placeNo, String placeName, String placeAddress, String memo) {
        if (placeNo != null) {
            return truncate(normalizeText(memo), PLAN_MEMO_MAX_LENGTH);
        }

        if (!StringUtils.hasText(placeName) && !StringUtils.hasText(placeAddress) && !StringUtils.hasText(memo)) {
            return null;
        }

        StringBuilder builder = new StringBuilder();
        if (StringUtils.hasText(placeName)) {
            builder.append(placeName.trim());
        }
        if (StringUtils.hasText(placeAddress)) {
            if (builder.length() > 0) {
                builder.append('\n');
            }
            builder.append(placeAddress.trim());
        }
        if (StringUtils.hasText(memo)) {
            if (builder.length() > 0) {
                builder.append('\n');
            }
            builder.append(memo.trim());
        }

        return truncate(builder.toString(), PLAN_MEMO_MAX_LENGTH);
    }

    private List<PlanDetailViewInput> toPlanDetailViewInputs(List<PlanDetailDTO> details) {
        List<PlanDetailViewInput> result = new ArrayList<>();
        if (details == null) {
            return result;
        }

        for (PlanDetailDTO detail : details) {
            if (detail == null) {
                continue;
            }

            String placeName = normalizeText(detail.getPlaceName());
            String placeAddress = normalizeText(detail.getPlaceAddress());
            Double placeLatitude = detail.getPlaceLatitude();
            Double placeLongitude = detail.getPlaceLongitude();
            String memo = normalizeText(detail.getPlanMeno());

            if (!StringUtils.hasText(placeName) && StringUtils.hasText(memo)) {
                int newlineIndex = memo.indexOf('\n');
                if (newlineIndex > 0) {
                    placeName = memo.substring(0, newlineIndex).trim();
                    memo = memo.substring(newlineIndex + 1).trim();
                } else {
                    placeName = memo;
                    memo = null;
                }
            } else if (StringUtils.hasText(placeName) && StringUtils.hasText(memo)) {
                String prefix = placeName + "\n";
                if (memo.startsWith(prefix)) {
                    memo = memo.substring(prefix.length()).trim();
                } else if (placeName.equals(memo.trim())) {
                    memo = null;
                }
            }

            if (!StringUtils.hasText(placeAddress) && detail.getPlaceNo() == null && StringUtils.hasText(memo)) {
                String inferredAddress = extractAddressFromMemo(memo);
                if (StringUtils.hasText(inferredAddress)) {
                    placeAddress = inferredAddress;
                    memo = removeFirstLine(memo);
                }
            }

            PlanDetailViewInput viewInput = new PlanDetailViewInput();
            viewInput.setPlaceNo(detail.getPlaceNo());
            viewInput.setPlaceName(placeName);
            viewInput.setPlaceAddress(placeAddress);
            viewInput.setPlaceLatitude(placeLatitude);
            viewInput.setPlaceLongitude(placeLongitude);
            viewInput.setDate(detail.getDetailStartDate() == null ? "" : detail.getDetailStartDate().toString());
            viewInput.setEndDate(detail.getDetailEndDate() == null ? "" : detail.getDetailEndDate().toString());
            viewInput.setMemo(memo);
            result.add(viewInput);
        }

        return result;
    }

    private String writeJson(Object value) {
        try {
            return OBJECT_MAPPER.writeValueAsString(value);
        } catch (IOException e) {
            return "[]";
        }
    }

    private Long normalizePlaceNo(Long placeNo) {
        if (placeNo == null || placeNo <= 0L) {
            return null;
        }
        return placeNo;
    }

    private Date parseSqlDate(String dateValue) {
        if (!StringUtils.hasText(dateValue)) {
            return null;
        }
        try {
            LocalDate localDate = LocalDate.parse(dateValue.trim());
            return Date.valueOf(localDate);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    private String normalizeText(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }

    private String extractAddressFromMemo(String memo) {
        if (!StringUtils.hasText(memo)) {
            return null;
        }
        int newlineIndex = memo.indexOf('\n');
        String firstLine = newlineIndex >= 0 ? memo.substring(0, newlineIndex).trim() : memo.trim();
        if (!looksLikeAddress(firstLine)) {
            return null;
        }
        return truncate(firstLine, 500);
    }

    private String removeFirstLine(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        int newlineIndex = value.indexOf('\n');
        if (newlineIndex < 0) {
            return null;
        }
        String remaining = value.substring(newlineIndex + 1).trim();
        return StringUtils.hasText(remaining) ? remaining : null;
    }

    private boolean looksLikeAddress(String value) {
        if (!StringUtils.hasText(value)) {
            return false;
        }
        String text = value.trim();
        if (text.length() < 5) {
            return false;
        }
        if (text.matches(".*\\d+.*")) {
            return true;
        }
        return text.contains("로")
                || text.contains("길")
                || text.contains("동")
                || text.contains("읍")
                || text.contains("면")
                || text.contains("리")
                || text.contains("시")
                || text.contains("구")
                || text.contains("군");
    }

    private String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }

    private String resolveAuthenticatedAuthId(Authentication authentication) {
        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return null;
        }

        String authId = authentication.getName();
        if (!StringUtils.hasText(authId)) {
            return null;
        }
        return authId.trim();
    }

    private static class PlanDetailInput {
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

        public Long getPlaceNo() {
            return placeNo;
        }

        public void setPlaceNo(Long placeNo) {
            this.placeNo = placeNo;
        }

        public String getPlaceName() {
            return placeName;
        }

        public void setPlaceName(String placeName) {
            this.placeName = placeName;
        }

        public String getPlaceAddress() {
            return placeAddress;
        }

        public void setPlaceAddress(String placeAddress) {
            this.placeAddress = placeAddress;
        }

        public Double getPlaceLatitude() {
            return placeLatitude;
        }

        public void setPlaceLatitude(Double placeLatitude) {
            this.placeLatitude = placeLatitude;
        }

        public Double getPlaceLongitude() {
            return placeLongitude;
        }

        public void setPlaceLongitude(Double placeLongitude) {
            this.placeLongitude = placeLongitude;
        }

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getTime() {
            return time;
        }

        public void setTime(String time) {
            this.time = time;
        }

        public String getEndDate() {
            return endDate;
        }

        public void setEndDate(String endDate) {
            this.endDate = endDate;
        }

        public String getEndTime() {
            return endTime;
        }

        public void setEndTime(String endTime) {
            this.endTime = endTime;
        }

        public String getMemo() {
            return memo;
        }

        public void setMemo(String memo) {
            this.memo = memo;
        }
    }

    private static class PlanDetailViewInput {
        private Long placeNo;
        private String placeName;
        private String placeAddress;
        private Double placeLatitude;
        private Double placeLongitude;
        private String date;
        private String endDate;
        private String memo;

        public Long getPlaceNo() {
            return placeNo;
        }

        public void setPlaceNo(Long placeNo) {
            this.placeNo = placeNo;
        }

        public String getPlaceName() {
            return placeName;
        }

        public void setPlaceName(String placeName) {
            this.placeName = placeName;
        }

        public String getPlaceAddress() {
            return placeAddress;
        }

        public void setPlaceAddress(String placeAddress) {
            this.placeAddress = placeAddress;
        }

        public Double getPlaceLatitude() {
            return placeLatitude;
        }

        public void setPlaceLatitude(Double placeLatitude) {
            this.placeLatitude = placeLatitude;
        }

        public Double getPlaceLongitude() {
            return placeLongitude;
        }

        public void setPlaceLongitude(Double placeLongitude) {
            this.placeLongitude = placeLongitude;
        }

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getEndDate() {
            return endDate;
        }

        public void setEndDate(String endDate) {
            this.endDate = endDate;
        }

        public String getMemo() {
            return memo;
        }

        public void setMemo(String memo) {
            this.memo = memo;
        }
    }
}
