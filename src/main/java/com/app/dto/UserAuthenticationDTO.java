package com.app.dto;

import lombok.Data;

@Data
public class UserAuthenticationDTO {

	private Long userAuthNo;       // PK
    private Long userNo;           // FK (Users 테이블 참조)
    private String userAuthId;     // 아이디
    private String userAuthPw;     // 비밀번호
    private String userAuthEmail;  // 이메일
    private String userAuthSnsType; // SNS 연동 타입 (예: LOCAL, NAVER, KAKAO)
}
