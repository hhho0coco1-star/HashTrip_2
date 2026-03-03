package com.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity // @PreAuthorize 등을 사용하기 위해 필수
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/hashTrip/admin/**").hasAnyRole("ADMIN", "MASTER")
                .requestMatchers("/hashTrip/admin").hasAnyRole("ADMIN", "MASTER")
                .anyRequest().authenticated()
            )
            .formLogin(formLogin -> formLogin
                .loginPage("/auth/login") // 로그인 페이지 경로
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/auth/logout")
                .permitAll()
            );

        return http.build();
    }
}
