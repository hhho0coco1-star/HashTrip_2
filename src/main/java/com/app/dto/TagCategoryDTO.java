package com.app.dto;

/**
 * ┌────────────────────────────────────────────────────┐
 * │  파일 위치                                          │
 * │  src/main/java/com/app/dto/TagCategoryDTO.java      │
 * └────────────────────────────────────────────────────┘
 *
 * 태그 카테고리 DTO
 * 필터 바 버튼 및 태그 색상 표시에 사용
 *
 * [DB 연동 시]
 * tag_categories 테이블 컬럼:
 *   category_key, label, icon, color, bg_color, css_class
 */
public class TagCategoryDTO {

    /** 카테고리 키 (예: "place", "plan", "transport") */
    private String categoryKey;

    /** 화면 표시 이름 (예: "장소", "계획", "이동") */
    private String label;

    /** 이모지 아이콘 */
    private String icon;

    /** 태그 텍스트 색상 (CSS 값) */
    private String color;

    /** 태그 배경 색상 (CSS 값) */
    private String bgColor;

    /** 태그 CSS 클래스 (예: "tag-place", "tag-plan") */
    private String cssClass;

    // ── 생성자 ─────────────────────────────────────────────────────

    public TagCategoryDTO() {}

    public TagCategoryDTO(String categoryKey, String label, String icon,
                          String color, String bgColor, String cssClass) {
        this.categoryKey = categoryKey;
        this.label = label;
        this.icon = icon;
        this.color = color;
        this.bgColor = bgColor;
        this.cssClass = cssClass;
    }

    // ── Getters & Setters ──────────────────────────────────────────

    public String getCategoryKey() { return categoryKey; }
    public void setCategoryKey(String categoryKey) { this.categoryKey = categoryKey; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getBgColor() { return bgColor; }
    public void setBgColor(String bgColor) { this.bgColor = bgColor; }

    public String getCssClass() { return cssClass; }
    public void setCssClass(String cssClass) { this.cssClass = cssClass; }
}
