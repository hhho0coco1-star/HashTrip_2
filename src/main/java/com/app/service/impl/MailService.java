package com.app.service.impl;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class MailService {

    private final JavaMailSender javaMailSender;

    @Value("${mail.enabled:false}")
    private boolean mailEnabled;

    @Value("${mail.from:no-reply@hifive.local}")
    private String fromAddress;

    @Autowired
    public MailService(JavaMailSender javaMailSender) {
        this.javaMailSender = javaMailSender;
    }

    public void sendTemporaryPassword(String toEmail, String userId, String temporaryPassword) {
        if (!mailEnabled) {
            throw new IllegalStateException("메일 발송 기능이 비활성화되어 있습니다. mail-local.properties에서 mail.enabled=true로 설정해 주세요.");
        }
        if (!StringUtils.hasText(toEmail)) {
            throw new IllegalArgumentException("메일 주소가 비어 있습니다.");
        }
        if (!StringUtils.hasText(fromAddress)) {
            throw new IllegalStateException("발신 메일 주소가 설정되지 않았습니다.");
        }
        if (isPlaceholder(fromAddress)) {
            throw new IllegalStateException("mail.from 값이 샘플 값입니다. 실제 발신 주소로 변경해 주세요.");
        }

        try {
            MimeMessage message = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
            helper.setTo(toEmail);
            helper.setFrom(fromAddress);
            helper.setSubject("[#trip] 임시 비밀번호 안내");
            helper.setText(buildTemporaryPasswordMailBody(userId, temporaryPassword), false);
            javaMailSender.send(message);
        } catch (MessagingException | MailException e) {
            throw new IllegalStateException("임시 비밀번호 메일 발송에 실패했습니다.", e);
        }
    }

    private String buildTemporaryPasswordMailBody(String userId, String temporaryPassword) {
        StringBuilder body = new StringBuilder();
        body.append("안녕하세요. #trip 입니다.\n\n");
        body.append("회원님의 임시 비밀번호를 안내드립니다.\n");
        body.append("아이디: ").append(userId).append("\n");
        body.append("임시 비밀번호: ").append(temporaryPassword).append("\n\n");
        body.append("로그인 후 반드시 비밀번호를 변경해 주세요.\n");
        return body.toString();
    }

    private boolean isPlaceholder(String value) {
        String normalized = value == null ? "" : value.trim().toUpperCase();
        return normalized.isEmpty()
                || normalized.contains("YOUR_")
                || normalized.contains("EXAMPLE")
                || normalized.contains("NO-REPLY@HIFIVE.LOCAL");
    }
}
