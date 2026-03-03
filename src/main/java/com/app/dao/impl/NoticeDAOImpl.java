package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.NoticeDAO;
import com.app.dto.NoticeDTO;

@Repository
public class NoticeDAOImpl implements NoticeDAO{

	@Autowired
	SqlSessionTemplate sqlSessionTemplate;
	
	private static final String NS = "notice_mapper.";

    @Override
    public List<NoticeDTO> selectAllNotice() { return sqlSessionTemplate.selectList(NS + "selectAll"); }
    @Override
    public NoticeDTO selectNoticeByNo(int noticeNo) { return sqlSessionTemplate.selectOne(NS + "selectByNo", noticeNo); }
    @Override
    public int increaseViewCount(int noticeNo) { return sqlSessionTemplate.update(NS + "increaseViewCount", noticeNo); }
    @Override
    public int insertNotice(NoticeDTO noticeDTO) { return sqlSessionTemplate.insert(NS + "insert", noticeDTO); }
    @Override
    public int updateNotice(NoticeDTO noticeDTO) { return sqlSessionTemplate.update(NS + "update", noticeDTO); }
    @Override
    public int deleteNotice(int noticeNo) { return sqlSessionTemplate.delete(NS + "delete", noticeNo); }
    
}
