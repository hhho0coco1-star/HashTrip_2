package com.app.service;

import java.util.List;

import com.app.dto.NoticeDTO;

public interface NoticeService {

	List<NoticeDTO> getNoticeList();
	
    NoticeDTO getNoticeDetail(int noticeNo);

    boolean increaseViewCount(int noticeNo);
    
    void registerNotice(NoticeDTO noticeDTO);
    
    void modifyNotice(NoticeDTO noticeDTO);
    
    void removeNotice(int noticeNo);
}
