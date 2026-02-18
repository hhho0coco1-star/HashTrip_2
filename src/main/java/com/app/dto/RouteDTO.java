package com.app.dto;

import java.util.List;
import java.util.Map;

/**
 * 추천 루트 DTO (기존 필드 + 상세페이지용 matchScore 통합)
 */
public class RouteDTO {

    private Long id;                // 루트 ID
    private String userName;        // 작성자 닉네임
    private String emoji;           // 작성자 이모지
    private String typeId;          // 여행자 유형 ID (adventurer, healer 등)
    private String title;           // 루트 제목
    private String description;     // 루트 짧은 설명
    private List<String> steps;     // 경유지 목록 (A -> B -> C)
    private Map<String, String> tags; // 태그 (카테고리:태그명)
    private int likeCount;          // 좋아요 수
    private int savedCount;         // 저장 수
    private Integer matchScore;     // 취향 매칭 점수 (신규 추가)

    // ── 기본 생성자 ────────────────────────────────────────────────
    public RouteDTO() {}

    // ── 통합 생성자 (Service에서 데이터 만들 때 사용) ──────────────────
    public RouteDTO(Long id, String userName, String emoji, String typeId, String title, 
                    String description, List<String> steps, Map<String, String> tags, 
                    int likeCount, int savedCount, Integer matchScore) {
        this.id = id;
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

    // ── Getters & Setters ──────────────────────────────────────────
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getEmoji() { return emoji; }
    public void setEmoji(String emoji) { this.emoji = emoji; }

    public String getTypeId() { return typeId; }
    public void setTypeId(String typeId) { this.typeId = typeId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<String> getSteps() { return steps; }
    public void setSteps(List<String> steps) { this.steps = steps; }

    public Map<String, String> getTags() { return tags; }
    public void setTags(Map<String, String> tags) { this.tags = tags; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public int getSavedCount() { return savedCount; }
    public void setSavedCount(int savedCount) { this.savedCount = savedCount; }

    public Integer getMatchScore() { return matchScore; }
    public void setMatchScore(Integer matchScore) { this.matchScore = matchScore; }
}