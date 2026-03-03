package com.app.config;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.InMemoryOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.InMemoryClientRegistrationRepository;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.util.StringUtils;

@Configuration
public class OAuth2Config {

    private static final Logger log = LoggerFactory.getLogger(OAuth2Config.class);

    @Value("${oauth2.google.client-id:GOOGLE_CLIENT_ID}")
    private String googleClientId;

    @Value("${oauth2.google.client-secret:GOOGLE_CLIENT_SECRET}")
    private String googleClientSecret;

    @Value("${oauth2.kakao.client-id:KAKAO_REST_API_KEY}")
    private String kakaoClientId;

    @Value("${oauth2.kakao.client-secret:KAKAO_CLIENT_SECRET}")
    private String kakaoClientSecret;

    @Value("${oauth2.naver.client-id:NAVER_CLIENT_ID}")
    private String naverClientId;

    @Value("${oauth2.naver.client-secret:NAVER_CLIENT_SECRET}")
    private String naverClientSecret;

    @Value("${oauth2.base-url:}")
    private String oauth2BaseUrl;

    @Bean
    public ClientRegistrationRepository clientRegistrationRepository() {
        List<ClientRegistration> registrations = new ArrayList<>();
        log.info("OAuth2 base URL config: {}", StringUtils.hasText(oauth2BaseUrl) ? oauth2BaseUrl : "{baseUrl(auto)}");

        if (isGoogleEnabled()) {
            registrations.add(googleRegistration());
        } else {
            log.info("OAuth2 google login is disabled. Set oauth2.google.client-id/client-secret to enable.");
        }

        if (isKakaoEnabled()) {
            registrations.add(kakaoRegistration());
        } else {
            log.info("OAuth2 kakao login is disabled. Set oauth2.kakao.client-id to enable.");
        }

        if (isNaverEnabled()) {
            registrations.add(naverRegistration());
        } else {
            log.info("OAuth2 naver login is disabled. Set oauth2.naver.client-id/client-secret to enable.");
        }

        if (registrations.isEmpty()) {
            log.warn("No OAuth2 providers are configured. Falling back to Google placeholder registration.");
            registrations.add(googleRegistration());
        }

        return new InMemoryClientRegistrationRepository(registrations);
    }

    @Bean
    public OAuth2AuthorizedClientService authorizedClientService(
            ClientRegistrationRepository clientRegistrationRepository) {
        return new InMemoryOAuth2AuthorizedClientService(clientRegistrationRepository);
    }

    private ClientRegistration googleRegistration() {
        warnIfPlaceholder("google", googleClientId, googleClientSecret);
        String redirectUri = resolveRedirectUri();
        log.info("OAuth2 google redirect URI template: {}", redirectUri);

        return ClientRegistration.withRegistrationId("google")
                .clientId(googleClientId)
                .clientSecret(googleClientSecret)
                .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_BASIC)
                .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
                .redirectUri(redirectUri)
                .scope("openid", "profile", "email")
                .authorizationUri("https://accounts.google.com/o/oauth2/v2/auth")
                .tokenUri("https://oauth2.googleapis.com/token")
                .jwkSetUri("https://www.googleapis.com/oauth2/v3/certs")
                .userInfoUri("https://www.googleapis.com/oauth2/v3/userinfo")
                .userNameAttributeName("sub")
                .clientName("Google")
                .build();
    }

    private ClientRegistration kakaoRegistration() {
        warnIfPlaceholder("kakao", kakaoClientId, kakaoClientSecret);
        String redirectUri = resolveRedirectUri();
        log.info("OAuth2 kakao redirect URI template: {}", redirectUri);

        ClientRegistration.Builder builder = ClientRegistration.withRegistrationId("kakao")
                .clientId(kakaoClientId)
                .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
                .redirectUri(redirectUri)
                .scope("profile_nickname", "account_email")
                .authorizationUri("https://kauth.kakao.com/oauth/authorize")
                .tokenUri("https://kauth.kakao.com/oauth/token")
                .userInfoUri("https://kapi.kakao.com/v2/user/me")
                .userNameAttributeName("id")
                .clientName("Kakao");

        applyClientSecret(builder, kakaoClientSecret);
        return builder.build();
    }

    private ClientRegistration naverRegistration() {
        warnIfPlaceholder("naver", naverClientId, naverClientSecret);
        String redirectUri = resolveRedirectUri();
        log.info("OAuth2 naver redirect URI template: {}", redirectUri);

        return ClientRegistration.withRegistrationId("naver")
                .clientId(naverClientId)
                .clientSecret(naverClientSecret)
                .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_POST)
                .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
                .redirectUri(redirectUri)
                .scope("name", "email", "profile_image")
                .authorizationUri("https://nid.naver.com/oauth2.0/authorize")
                .tokenUri("https://nid.naver.com/oauth2.0/token")
                .userInfoUri("https://openapi.naver.com/v1/nid/me")
                .userNameAttributeName("response")
                .clientName("Naver")
                .build();
    }

    private String resolveRedirectUri() {
        if (!StringUtils.hasText(oauth2BaseUrl)) {
            return "{baseUrl}/login/oauth2/code/{registrationId}";
        }
        return oauth2BaseUrl.trim() + "/login/oauth2/code/{registrationId}";
    }

    private void applyClientSecret(ClientRegistration.Builder builder, String secret) {
        if (StringUtils.hasText(secret) && !isPlaceholder(secret)) {
            builder.clientSecret(secret);
            builder.clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_POST);
            return;
        }
        builder.clientAuthenticationMethod(ClientAuthenticationMethod.NONE);
    }

    private void warnIfPlaceholder(String provider, String clientId, String clientSecret) {
        if (isPlaceholder(clientId) || isPlaceholder(clientSecret)) {
            log.warn("OAuth2 {} credentials are placeholders. Update src/main/resources/oauth2-local.properties.", provider);
        }
    }

    private boolean isGoogleEnabled() {
        return isConfiguredValue(googleClientId) && isConfiguredValue(googleClientSecret);
    }

    private boolean isKakaoEnabled() {
        return isConfiguredValue(kakaoClientId);
    }

    private boolean isNaverEnabled() {
        return isConfiguredValue(naverClientId) && isConfiguredValue(naverClientSecret);
    }

    private boolean isConfiguredValue(String value) {
        return StringUtils.hasText(value) && !isPlaceholder(value);
    }

    private boolean isPlaceholder(String value) {
        if (!StringUtils.hasText(value)) {
            return true;
        }
        String normalized = value.trim().toUpperCase();
        return normalized.contains("CLIENT_ID")
                || normalized.contains("CLIENT_SECRET")
                || normalized.contains("REST_API_KEY");
    }
}
