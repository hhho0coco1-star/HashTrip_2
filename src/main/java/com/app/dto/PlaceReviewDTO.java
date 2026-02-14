package com.app.dto;

import java.util.Date;

import lombok.Data;

@Data
public class PlaceReviewDTO {
	private Long commentNo;
	private Long logNo;
	private Long placeNo;
	private String commentContent;
	private String createdBy;
	private Date createdAt;
}
