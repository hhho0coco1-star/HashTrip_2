package com.app.dao.impl;

import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.app.dao.UserTagMapDAO;
import com.app.dto.UserTagMapDTO;

@Repository
public class UserTagMapImpl implements UserTagMapDAO {

    @Autowired
    private SqlSessionTemplate sqlSessionTemplate;

    private static final String NAMESPACE = "com.app.mapper.UserTagMapMapper";

    @Override
    public void deleteByUserId(Long userNo) {
        // sqlSessionTemplate.delete("네임스페이스.아이디", 파라미터)
        sqlSessionTemplate.delete(NAMESPACE + ".deleteByUserId", userNo);
    }

    @Override
    public void insertTag(UserTagMapDTO dto) {
        sqlSessionTemplate.insert(NAMESPACE + ".insertTag", dto);
    }

    @Override
    public List<UserTagMapDTO> findByUserId(Long userNo) {
        return sqlSessionTemplate.selectList(NAMESPACE + ".findByUserId", userNo);
    }
}