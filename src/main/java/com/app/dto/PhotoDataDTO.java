package com.app.dto;

import lombok.Data;

@Data
public class PhotoDataDTO {
	private Long photoNo;
	private Long commentNo;
	private String logPhotoUrl;
	private byte[] photoBinary;
	private String photoMimeType;
	private String photoFileName;
}
