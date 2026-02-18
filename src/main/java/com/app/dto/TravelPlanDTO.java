package com.app.dto;

import java.sql.Date;

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

    // Card data for recommended routes
    private String userName;
    private String typeId;
    private String description;
    private Integer likeCount;
    private Integer savedCount;
    private Integer matchScore;
}
