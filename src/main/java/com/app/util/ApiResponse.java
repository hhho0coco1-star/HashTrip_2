package com.app.util;

import lombok.Data;

@Data
public class ApiResponse<T> {
	private ApiResponseHeader header;
    private T body;
}
