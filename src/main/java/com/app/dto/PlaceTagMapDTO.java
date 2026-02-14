package com.app.dto;

import lombok.Data;

@Data
public class PlaceTagMapDTO {
	private Long placeTagNo;
	private Long placeNo;
	private String tagCode;
	private Double tagWeight;
	private String tagSource;
	private Double tagConfidence;
}
