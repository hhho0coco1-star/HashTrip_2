package com.app.dto;

import lombok.Data;

@Data
public class UserDTO {

	private Long user_no;
    private String user_name;
    private String user_nickName;
	
 // Getter, Setter 추가 필수!
    public String getUser_nickName() { return user_nickName; }
    public void setUser_nickName(String user_nickName) { this.user_nickName = user_nickName; }
}

