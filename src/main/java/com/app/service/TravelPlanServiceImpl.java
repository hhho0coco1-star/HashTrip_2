package com.app.service;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.app.dao.PlanDetailDAO;
import com.app.dao.TravelPlanDAO;
import com.app.dao.CommunityDAO;
import com.app.dto.PlanDetailDTO;
import com.app.dto.RouteSaveResultDTO;
import com.app.dto.TravelPlanDTO;

@Service
public class TravelPlanServiceImpl implements TravelPlanService {

    @Autowired
    private TravelPlanDAO travelPlanDAO;

    @Autowired
    private PlanDetailDAO planDetailDAO;

    @Autowired
    private CommunityDAO communityDAO;

    @Override
    public List<TravelPlanDTO> findPublicTravelPlans() {
        return travelPlanDAO.getPublicTravelPlans();
    }

    @Override
    public TravelPlanDTO findTravelPlan(Long planNo) {
        return travelPlanDAO.getTravelPlanById(planNo);
    }

    @Override
    public List<TravelPlanDTO> findUserTravelPlans(Long userNo) {
        return travelPlanDAO.getTravelPlansByUserNo(userNo);
    }

    @Override
    public int insertTravelPlan(TravelPlanDTO travelPlan) {
        return travelPlanDAO.insertTravelPlan(travelPlan);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long insertTravelPlanWithDetails(TravelPlanDTO travelPlan, List<PlanDetailDTO> planDetails) {
        int inserted = travelPlanDAO.insertTravelPlan(travelPlan);
        if (inserted != 1 || travelPlan.getPlanNo() == null) {
            throw new IllegalStateException("여행 일정 저장에 실패했습니다.");
        }

        if (planDetails != null) {
            for (PlanDetailDTO planDetail : planDetails) {
                planDetail.setPlanNo(travelPlan.getPlanNo());
                if (planDetail.getUserNo() == null) {
                    planDetail.setUserNo(travelPlan.getUserNo());
                }
                planDetailDAO.insertPlanDetail(planDetail);
            }
        }

        return travelPlan.getPlanNo();
    }

    @Override
    public int updateTravelPlan(TravelPlanDTO travelPlan) {
        if (travelPlan == null || travelPlan.getPlanNo() == null) {
            throw new IllegalArgumentException("일정 번호가 필요합니다.");
        }
        return travelPlanDAO.updateTravelPlan(travelPlan);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long updateTravelPlanWithDetails(TravelPlanDTO travelPlan, List<PlanDetailDTO> planDetails, Long ownerUserNo) {
        if (travelPlan == null || travelPlan.getPlanNo() == null) {
            throw new IllegalArgumentException("수정할 일정 번호가 필요합니다.");
        }
        if (ownerUserNo == null || ownerUserNo <= 0L) {
            throw new IllegalArgumentException("사용자 정보가 필요합니다.");
        }

        TravelPlanDTO existingPlan = requireTravelPlan(travelPlan.getPlanNo());
        if (existingPlan.getUserNo() == null || !ownerUserNo.equals(existingPlan.getUserNo())) {
            throw new IllegalArgumentException("본인 일정만 수정할 수 있습니다.");
        }
        if (planDetails == null || planDetails.isEmpty()) {
            throw new IllegalArgumentException("일정에 장소를 최소 1개 이상 추가해 주세요.");
        }

        travelPlan.setUserNo(ownerUserNo);
        int updated = travelPlanDAO.updateTravelPlan(travelPlan);
        if (updated != 1) {
            throw new IllegalStateException("일정 수정에 실패했습니다.");
        }

        planDetailDAO.deletePlanDetailsByPlanNo(travelPlan.getPlanNo());

        int visitOrder = 1;
        for (PlanDetailDTO detail : planDetails) {
            detail.setPlanNo(travelPlan.getPlanNo());
            detail.setUserNo(ownerUserNo);
            detail.setPlanVisitOrder(visitOrder++);
            planDetailDAO.insertPlanDetail(detail);
        }

        return travelPlan.getPlanNo();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long copyTravelPlanWithDetails(Long sourcePlanNo, Long targetUserNo, String copiedPlanTitle) {
        return copyTravelPlanWithDetailsInternal(sourcePlanNo, targetUserNo, copiedPlanTitle);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public RouteSaveResultDTO saveRouteForUser(Long sourcePlanNo, Long targetUserNo, String copiedPlanTitle) {
        if (targetUserNo == null || targetUserNo <= 0L) {
            throw new IllegalArgumentException("대상 사용자 정보가 필요합니다.");
        }
        requireTravelPlan(sourcePlanNo);

        int insertedSaveHistory;
        try {
            insertedSaveHistory = travelPlanDAO.registerRouteSave(sourcePlanNo, targetUserNo);
        } catch (DuplicateKeyException e) {
            insertedSaveHistory = 0;
        }
        Long copiedPlanNo = null;
        if (insertedSaveHistory > 0) {
            copiedPlanNo = copyTravelPlanWithDetailsInternal(sourcePlanNo, targetUserNo, copiedPlanTitle);
        }

        RouteSaveResultDTO result = new RouteSaveResultDTO();
        result.setSaveRegistered(insertedSaveHistory > 0);
        result.setCopiedPlanNo(copiedPlanNo);
        result.setSavedUserCount(travelPlanDAO.countSavedUsersBySourcePlan(sourcePlanNo));
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int appendPlanDetailsToExistingPlan(Long sourcePlanNo, Long targetPlanNo, Long targetUserNo) {
        requireTravelPlan(sourcePlanNo);
        TravelPlanDTO targetPlan = requireTravelPlan(targetPlanNo);
        if (targetUserNo == null || targetUserNo <= 0L) {
            throw new IllegalArgumentException("대상 사용자 정보가 필요합니다.");
        }
        if (targetPlan.getUserNo() == null || !targetUserNo.equals(targetPlan.getUserNo())) {
            throw new IllegalArgumentException("본인 일정에만 추가할 수 있습니다.");
        }

        List<PlanDetailDTO> sourceDetails = planDetailDAO.getPlanDetailsByPlanNo(sourcePlanNo);
        if (sourceDetails == null || sourceDetails.isEmpty()) {
            return 0;
        }

        int visitOrder = planDetailDAO.getMaxVisitOrderByPlanNo(targetPlanNo);
        int insertedCount = 0;

        for (PlanDetailDTO sourceDetail : sourceDetails) {
            PlanDetailDTO copiedDetail = copyPlanDetail(sourceDetail);
            copiedDetail.setPlanNo(targetPlanNo);
            copiedDetail.setUserNo(targetUserNo);
            copiedDetail.setPlanVisitOrder(++visitOrder);
            planDetailDAO.insertPlanDetail(copiedDetail);
            insertedCount++;
        }

        return insertedCount;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int appendSinglePlanDetailToExistingPlan(
            Long sourcePlanNo, Long sourcePlanDetailNo, Long targetPlanNo, Long targetUserNo) {
        requireTravelPlan(sourcePlanNo);
        TravelPlanDTO targetPlan = requireTravelPlan(targetPlanNo);
        if (targetUserNo == null || targetUserNo <= 0L) {
            throw new IllegalArgumentException("대상 사용자 정보가 필요합니다.");
        }
        if (targetPlan.getUserNo() == null || !targetUserNo.equals(targetPlan.getUserNo())) {
            throw new IllegalArgumentException("본인 일정에만 추가할 수 있습니다.");
        }

        PlanDetailDTO sourceDetail = planDetailDAO.getPlanDetailByPlanDetailNo(sourcePlanDetailNo);
        if (sourceDetail == null) {
            throw new IllegalArgumentException("원본 일정 상세를 찾을 수 없습니다.");
        }
        if (sourceDetail.getPlanNo() == null || !sourcePlanNo.equals(sourceDetail.getPlanNo())) {
            throw new IllegalArgumentException("선택한 상세 정보가 원본 일정에 속하지 않습니다.");
        }

        int visitOrder = planDetailDAO.getMaxVisitOrderByPlanNo(targetPlanNo);
        PlanDetailDTO copiedDetail = copyPlanDetail(sourceDetail);
        copiedDetail.setPlanNo(targetPlanNo);
        copiedDetail.setUserNo(targetUserNo);
        copiedDetail.setPlanVisitOrder(++visitOrder);
        return planDetailDAO.insertPlanDetail(copiedDetail);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTravelPlan(Long planNo, Long ownerUserNo) {
        if (ownerUserNo == null || ownerUserNo <= 0L) {
            throw new IllegalArgumentException("사용자 정보가 필요합니다.");
        }

        TravelPlanDTO existingPlan = requireTravelPlan(planNo);
        if (existingPlan.getUserNo() == null || !ownerUserNo.equals(existingPlan.getUserNo())) {
            throw new IllegalArgumentException("본인 일정만 삭제할 수 있습니다.");
        }

        // 일정 상세 및 관련 부가 데이터 삭제
        planDetailDAO.deletePlanDetailsByPlanNo(planNo);
        communityDAO.deleteCommunityReviewsByPlanNo(planNo);
        travelPlanDAO.deleteRouteSaveHistoryBySourcePlan(planNo);

        int deleted = travelPlanDAO.deleteTravelPlanByOwner(planNo, ownerUserNo);
        if (deleted != 1) {
            throw new IllegalStateException("일정 삭제에 실패했습니다.");
        }
    }

    private TravelPlanDTO requireTravelPlan(Long planNo) {
        if (planNo == null || planNo <= 0L) {
            throw new IllegalArgumentException("일정 번호가 필요합니다.");
        }
        TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlanById(planNo);
        if (travelPlan == null) {
            throw new IllegalArgumentException("일정을 찾을 수 없습니다.");
        }
        return travelPlan;
    }

    private String resolveCopiedPlanTitle(String sourceTitle, String copiedPlanTitle) {
        String trimmedCopied = normalizeTitle(copiedPlanTitle);
        if (trimmedCopied != null) {
            return trimmedCopied;
        }
        String baseTitle = normalizeTitle(sourceTitle);
        if (baseTitle == null) {
            return "복사한 일정";
        }
        return truncate(baseTitle + " (복사본)", 200);
    }

    private Long copyTravelPlanWithDetailsInternal(Long sourcePlanNo, Long targetUserNo, String copiedPlanTitle) {
        TravelPlanDTO sourcePlan = requireTravelPlan(sourcePlanNo);
        if (targetUserNo == null || targetUserNo <= 0L) {
            throw new IllegalArgumentException("대상 사용자 정보가 필요합니다.");
        }

        TravelPlanDTO copiedPlan = new TravelPlanDTO();
        copiedPlan.setUserNo(targetUserNo);
        copiedPlan.setPlanTitle(resolveCopiedPlanTitle(sourcePlan.getPlanTitle(), copiedPlanTitle));
        copiedPlan.setPlanIsPublic("N");
        copiedPlan.setPlanStatus("PLANNING");

        List<PlanDetailDTO> sourceDetails = planDetailDAO.getPlanDetailsByPlanNo(sourcePlanNo);
        LocalDate refStart = sourcePlan.getPlanStartDate() != null ? sourcePlan.getPlanStartDate().toLocalDate() : null;
        long daySpan = 1L;
        if (sourceDetails != null && !sourceDetails.isEmpty()) {
            LocalDate minDate = null;
            LocalDate maxDate = null;
            for (PlanDetailDTO d : sourceDetails) {
                if (d.getDetailStartDate() == null) continue;
                LocalDate dDate = d.getDetailStartDate().toLocalDateTime().toLocalDate();
                if (minDate == null || dDate.isBefore(minDate)) minDate = dDate;
                if (maxDate == null || dDate.isAfter(maxDate)) maxDate = dDate;
            }
            if (refStart == null && minDate != null) refStart = minDate;
            if (minDate != null && maxDate != null) {
                daySpan = ChronoUnit.DAYS.between(minDate, maxDate) + 1;
                if (daySpan < 1) daySpan = 1;
            }
        }
        LocalDate copyStart = LocalDate.now();
        LocalDate copyEnd = copyStart.plusDays(daySpan - 1);
        copiedPlan.setPlanStartDate(Date.valueOf(copyStart));
        copiedPlan.setPlanEndDate(Date.valueOf(copyEnd));

        int inserted = travelPlanDAO.insertTravelPlan(copiedPlan);
        if (inserted != 1 || copiedPlan.getPlanNo() == null) {
            throw new IllegalStateException("일정 복사에 실패했습니다.");
        }

        if (sourceDetails == null || sourceDetails.isEmpty()) {
            return copiedPlan.getPlanNo();
        }

        int visitOrder = 1;
        for (PlanDetailDTO sourceDetail : sourceDetails) {
            PlanDetailDTO copiedDetail = copyPlanDetailWithNewDates(sourceDetail, refStart != null ? refStart : copyStart, copyStart);
            copiedDetail.setPlanNo(copiedPlan.getPlanNo());
            copiedDetail.setUserNo(targetUserNo);
            copiedDetail.setPlanVisitOrder(visitOrder++);
            planDetailDAO.insertPlanDetail(copiedDetail);
        }

        return copiedPlan.getPlanNo();
    }

    private String normalizeTitle(String planTitle) {
        if (planTitle == null || planTitle.trim().isEmpty()) {
            return null;
        }
        return truncate(planTitle.trim(), 200);
    }

    private String truncate(String value, int maxLength) {
        if (value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }

    private PlanDetailDTO copyPlanDetail(PlanDetailDTO sourceDetail) {
        PlanDetailDTO copiedDetail = new PlanDetailDTO();
        copiedDetail.setPlaceNo(sourceDetail.getPlaceNo());
        copiedDetail.setPlanMeno(sourceDetail.getPlanMeno());
        copiedDetail.setDetailStartDate(sourceDetail.getDetailStartDate());
        copiedDetail.setDetailEndDate(sourceDetail.getDetailEndDate());
        return copiedDetail;
    }

    private PlanDetailDTO copyPlanDetailWithNewDates(PlanDetailDTO sourceDetail, LocalDate sourceRefStart, LocalDate copyRefStart) {
        PlanDetailDTO copiedDetail = new PlanDetailDTO();
        copiedDetail.setPlaceNo(sourceDetail.getPlaceNo());
        copiedDetail.setPlanMeno(sourceDetail.getPlanMeno());
        long dayOffset = 0;
        if (sourceDetail.getDetailStartDate() != null) {
            LocalDate dDate = sourceDetail.getDetailStartDate().toLocalDateTime().toLocalDate();
            dayOffset = ChronoUnit.DAYS.between(sourceRefStart, dDate);
            if (dayOffset < 0) dayOffset = 0;
        }
        LocalDate newDate = copyRefStart.plusDays(dayOffset);
        copiedDetail.setDetailStartDate(Timestamp.valueOf(newDate.atTime(9, 0)));
        copiedDetail.setDetailEndDate(Timestamp.valueOf(newDate.atTime(18, 0)));
        return copiedDetail;
    }
}
