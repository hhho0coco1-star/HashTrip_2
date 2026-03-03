package com.app.service.impl;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.app.dao.AuthDAO;
import com.app.dto.UsersDTO;

@Service("customUserDetailsService")
public class CustomUserDetailsService implements UserDetailsService {

    private static final String ACTIVE_STATUS = "A";
    private static final String USER_TYPE_ADMIN = "ADMIN";
    private static final String USER_TYPE_MASTER = "MASTER";

    private final AuthDAO authDAO;

    @Autowired
    public CustomUserDetailsService(AuthDAO authDAO) {
        this.authDAO = authDAO;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UsersDTO user = authDAO.findByAuthId(username);
        if (user == null) {
            throw new UsernameNotFoundException("존재하지 않는 아이디입니다.");
        }
        if (!ACTIVE_STATUS.equalsIgnoreCase(user.getUserStatus())) {
            throw new DisabledException("활성 상태가 아닌 계정입니다.");
        }
        if (user.getAuthPassword() == null) {
            throw new UsernameNotFoundException("비밀번호가 등록되지 않은 계정입니다.");
        }

        return User.withUsername(user.getAuthId())
                .password(user.getAuthPassword())
                .authorities(resolveAuthorities(user))
                .build();
    }

    private List<GrantedAuthority> resolveAuthorities(UsersDTO user) {
        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_USER"));

        String userType = user.getUserType();
        if (userType == null) {
            return authorities;
        }

        String normalizedUserType = userType.trim().toUpperCase();
        if (USER_TYPE_ADMIN.equals(normalizedUserType)) {
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
            return authorities;
        }

        if (USER_TYPE_MASTER.equals(normalizedUserType)) {
            authorities.add(new SimpleGrantedAuthority("ROLE_MASTER"));
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        }

        return authorities;
    }
}
