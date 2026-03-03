package com.app.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.NoticeDAO;
import com.app.dto.NoticeDTO;
import com.app.service.NoticeService;

@Service
public class NoticeServiceImpl implements NoticeService{

	@Autowired
	NoticeDAO noticeDAO;
	
	@Override
    public List<NoticeDTO> getNoticeList() { return noticeDAO.selectAllNotice(); }
    @Override
    public NoticeDTO getNoticeDetail(int noticeNo) { return noticeDAO.selectNoticeByNo(noticeNo); }
    @Override
    public boolean increaseViewCount(int noticeNo) { return noticeDAO.increaseViewCount(noticeNo) > 0; }
    @Override
    public void registerNotice(NoticeDTO noticeDTO) { noticeDAO.insertNotice(noticeDTO); }
    @Override
    public void modifyNotice(NoticeDTO noticeDTO) { noticeDAO.updateNotice(noticeDTO); }
    @Override
    public void removeNotice(int noticeNo) { noticeDAO.deleteNotice(noticeNo); }
    
}
