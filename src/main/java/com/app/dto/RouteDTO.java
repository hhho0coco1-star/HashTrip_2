package com.app.dto;

import java.util.List;
import java.util.Map;

public class RouteDTO {

    private Long id;
    private Long userNo;
    private String userName;
    private String emoji;
    private String typeId;
    private String title;
    private String description;
    private List<String> steps;
    private Map<String, String> tags;
    private int likeCount;
    private int savedCount;
    private Integer matchScore;

    public RouteDTO() {
    }

    public RouteDTO(
            Long id,
            Long userNo,
            String userName,
            String emoji,
            String typeId,
            String title,
            String description,
            List<String> steps,
            Map<String, String> tags,
            int likeCount,
            int savedCount,
            Integer matchScore) {
        this.id = id;
        this.userNo = userNo;
        this.userName = userName;
        this.emoji = emoji;
        this.typeId = typeId;
        this.title = title;
        this.description = description;
        this.steps = steps;
        this.tags = tags;
        this.likeCount = likeCount;
        this.savedCount = savedCount;
        this.matchScore = matchScore;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserNo() {
        return userNo;
    }

    public void setUserNo(Long userNo) {
        this.userNo = userNo;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getEmoji() {
        return emoji;
    }

    public void setEmoji(String emoji) {
        this.emoji = emoji;
    }

    public String getTypeId() {
        return typeId;
    }

    public void setTypeId(String typeId) {
        this.typeId = typeId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<String> getSteps() {
        return steps;
    }

    public void setSteps(List<String> steps) {
        this.steps = steps;
    }

    public Map<String, String> getTags() {
        return tags;
    }

    public void setTags(Map<String, String> tags) {
        this.tags = tags;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public int getSavedCount() {
        return savedCount;
    }

    public void setSavedCount(int savedCount) {
        this.savedCount = savedCount;
    }

    public Integer getMatchScore() {
        return matchScore;
    }

    public void setMatchScore(Integer matchScore) {
        this.matchScore = matchScore;
    }
}
