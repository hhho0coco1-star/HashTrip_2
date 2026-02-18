package com.app.dto;

import lombok.Data;

@Data
public class UserTagMapDTO {
	private Long mappingNo;
	private Long userNo;
	private String questionId;
	private String tagCode;
	private String tagName;
	private String tagCategory;
}
