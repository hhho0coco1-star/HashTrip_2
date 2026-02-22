package com.app.dto;

import lombok.Data;

@Data
public class PlaceDTO {
	private Long placeNo;
	private String placeContentId;
	private String placeName;
	private String placeCategory;
	private String placeAddress;
	private Double placeLatitude;
	private Double placeLongitude;
	private Double placeRating;
	private String placeNumber;
	private String placeThumbnailUrl;
	
	// [추가] 좋아요 여부를 저장할 필드
    private String savedYn = "N"; // 기본값은 'N'
}
