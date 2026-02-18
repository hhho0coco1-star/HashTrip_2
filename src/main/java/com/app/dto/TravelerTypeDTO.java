package com.app.dto;

import java.util.List;

/**
 * ┌──────────────────────────────────────────────────────┐
 * │  파일 위치                                            │
 * │  src/main/java/com/app/dto/TravelerTypeDTO.java       │
 * └──────────────────────────────────────────────────────┘
 *
 * 여행자 유형 DTO
 *
 * [DB 연동 시]
 * traveler_types 테이블 컬럼:
 *   type_id, emoji, name, color, bg_color, description
 * type_key_tags 테이블 (type_id, tag_value):
 *   → keyTags 필드와 매핑 (MyBatis <collection>)
 */
public class TravelerTypeDTO {

    /** 유형 식별 키 (예: "adventurer", "romantic") */
    private String typeId;

    /** 이모지 */
    private String emoji;

    /** 유형 이름 (예: "야생 탐험가") */
    private String name;

    /** 텍스트 색상 */
    private String color;

    /** 배경 색상 */
    private String bgColor;

    /** 유형 설명 */
    private String description;

    /**
     * 유형 판별용 핵심 태그 목록
     * [DB 연동] type_key_tags 테이블에서 type_id 로 조회
     */
    private List<String> keyTags;

    // ── 생성자 ─────────────────────────────────────────────────────

    public TravelerTypeDTO() {}

    public TravelerTypeDTO(String typeId, String emoji, String name,
                           String color, String bgColor, String description,
                           List<String> keyTags) {
        this.typeId = typeId;
        this.emoji = emoji;
        this.name = name;
        this.color = color;
        this.bgColor = bgColor;
        this.description = description;
        this.keyTags = keyTags;
    }

    // ── Getters & Setters ──────────────────────────────────────────

    public String getTypeId() { return typeId; }
    public void setTypeId(String typeId) { this.typeId = typeId; }

    public String getEmoji() { return emoji; }
    public void setEmoji(String emoji) { this.emoji = emoji; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getBgColor() { return bgColor; }
    public void setBgColor(String bgColor) { this.bgColor = bgColor; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<String> getKeyTags() { return keyTags; }
    public void setKeyTags(List<String> keyTags) { this.keyTags = keyTags; }
}

