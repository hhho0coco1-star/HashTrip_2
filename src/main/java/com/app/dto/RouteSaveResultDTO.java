package com.app.dto;

public class RouteSaveResultDTO {

    private boolean saveRegistered;
    private Long copiedPlanNo;
    private int savedUserCount;

    public boolean isSaveRegistered() {
        return saveRegistered;
    }

    public void setSaveRegistered(boolean saveRegistered) {
        this.saveRegistered = saveRegistered;
    }

    public Long getCopiedPlanNo() {
        return copiedPlanNo;
    }

    public void setCopiedPlanNo(Long copiedPlanNo) {
        this.copiedPlanNo = copiedPlanNo;
    }

    public int getSavedUserCount() {
        return savedUserCount;
    }

    public void setSavedUserCount(int savedUserCount) {
        this.savedUserCount = savedUserCount;
    }
}
