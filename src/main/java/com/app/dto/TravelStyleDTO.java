package com.app.dto;

import java.util.Date;

import lombok.Data;

@Data
public class TravelStyleDTO {

	private Long styleUserNo;          // STYLE_USER_NO (NUMBER)
    private Long userNo;               // USER_NO (NUMBER)
    private String travelIsAnalyzed;    // TRAVEL_IS_ANALYZDE (CHAR) - 오타 주의 (Analyzde -> Analyzed)
    private Date travelAnalyzedDate;   // TRAVEL_ANALYZED_DATE (DATE)
    private String travelTypeName;     // TRAVEL_TYPE_NAME (VARCHAR2)
    private String selectedPlaceCodes; // SELECTED_PLACE_CODES (VARCHAR2)
    private String selectedEnergyCodes;// SELECTED_ENERGY_CODES (VARCHAR2)
    private String selectedPlanCodes;  // SELECTED_PLAN_CODES (VARCHAR2)
    private String travelFinalSummary; // TRAVEL_FINAL_SUMMARY (VARCHAR2)
    
}
