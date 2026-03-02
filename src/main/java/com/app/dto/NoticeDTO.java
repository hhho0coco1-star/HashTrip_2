package com.app.dto;

import java.util.Date;

import lombok.Data;

@Data
public class NoticeDTO {
	
	private int noticeNo;       // 공지사항 고유 번호
    private String title;       // 제목
    private String content;     // 내용 (줄 바꿈 및 HTML 태그 포함)
    private int viewCount;      // 조회수
    private Date createdAt;     // 작성일
    private Date updatedAt;     // 수정일

}
