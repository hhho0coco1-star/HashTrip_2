package com.app.security;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

public class CompatiblePasswordEncoder implements PasswordEncoder {

    private final BCryptPasswordEncoder bcrypt = new BCryptPasswordEncoder();

    @Override
    public String encode(CharSequence rawPassword) {
        return bcrypt.encode(rawPassword);
    }

    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        if (encodedPassword == null) {
            return false;
        }

        // Dummy data compatibility: allow plain text password rows temporarily.
        if (isBcryptHash(encodedPassword)) {
            return bcrypt.matches(rawPassword, encodedPassword);
        }
        return rawPassword != null && rawPassword.toString().equals(encodedPassword);
    }

    private boolean isBcryptHash(String value) {
        return value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$");
    }
}
