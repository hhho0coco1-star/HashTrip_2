package com.app.dao;

import java.util.List;

import com.app.dto.NoticeDTO;

public interface NoticeDAO {

	List<NoticeDTO> selectAllNotice();    // 목록 조회 (사용자/관리자)
    NoticeDTO selectNoticeByNo(int noticeNo); // 상세 조회 (수정용)
    int increaseViewCount(int noticeNo); // 조회수 증가
    int insertNotice(NoticeDTO noticeDTO); // 추가
    int updateNotice(NoticeDTO noticeDTO); // 수정
    int deleteNotice(int noticeNo);        // 삭제
    
}
