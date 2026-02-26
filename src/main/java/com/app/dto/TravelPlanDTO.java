package com.app.dto;

import java.sql.Date;
import java.util.List;

import lombok.Data;

@Data
public class TravelPlanDTO {

    private Long planNo;
    private Long userNo;
    private String planTitle;
    private String planIsPublic;
    private String planStatus;
    private Date planStartDate;
    private Date planEndDate;

    /** 일정 목록용: 방문 순서·썸네일 등 */
    private List<PlanDetailDTO> planDetails;

    // Card data for recommended routes
    private String userName;
    private String typeId;
    private String description;
    private Integer likeCount;
    private Integer savedCount;
    private Integer matchScore;
}
