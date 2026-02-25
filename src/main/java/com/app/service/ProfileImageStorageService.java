package com.app.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ProfileImageStorageService {

	private static final long MAX_PROFILE_IMAGE_SIZE_BYTES = 5L * 1024L * 1024L;
	private static final String PROFILE_UPLOAD_WEB_PATH = "/resources/uploads/profile";
	private static final Set<String> ALLOWED_EXTENSIONS = buildAllowedExtensions();

	@Autowired
	private ServletContext servletContext;

	public String store(MultipartFile profileImage) throws IOException {
		if (profileImage == null || profileImage.isEmpty()) {
			return null;
		}

		validateProfileImage(profileImage);

		String extension = resolveExtension(profileImage.getOriginalFilename(), profileImage.getContentType());
		String savedName = UUID.randomUUID().toString().replace("-", "") + extension;

		String uploadRoot = servletContext.getRealPath(PROFILE_UPLOAD_WEB_PATH);
		if (!StringUtils.hasText(uploadRoot)) {
			throw new IllegalStateException("프로필 업로드 경로를 확인할 수 없습니다.");
		}

		Path uploadDir = Paths.get(uploadRoot);
		Files.createDirectories(uploadDir);

		Path targetPath = uploadDir.resolve(savedName);
		profileImage.transferTo(targetPath.toFile());

		return PROFILE_UPLOAD_WEB_PATH + "/" + savedName;
	}

	public void deleteIfManaged(String imagePath) {
		if (!StringUtils.hasText(imagePath)) {
			return;
		}
		String trimmed = imagePath.trim();
		if (!trimmed.startsWith(PROFILE_UPLOAD_WEB_PATH + "/")) {
			return;
		}

		String realPath = servletContext.getRealPath(trimmed);
		if (!StringUtils.hasText(realPath)) {
			return;
		}

		try {
			Files.deleteIfExists(Paths.get(realPath));
		} catch (IOException ignored) {
			// Ignore cleanup failures to avoid breaking user update flow.
		}
	}

	private void validateProfileImage(MultipartFile profileImage) {
		String contentType = profileImage.getContentType();
		if (!StringUtils.hasText(contentType) || !contentType.toLowerCase().startsWith("image/")) {
			throw new IllegalArgumentException("프로필 이미지는 이미지 파일만 업로드할 수 있습니다.");
		}
		if (profileImage.getSize() > MAX_PROFILE_IMAGE_SIZE_BYTES) {
			throw new IllegalArgumentException("프로필 이미지는 5MB 이하만 업로드할 수 있습니다.");
		}
	}

	private String resolveExtension(String originalFilename, String contentType) {
		String extension = "";
		if (StringUtils.hasText(originalFilename)) {
			int dotIndex = originalFilename.lastIndexOf('.');
			if (dotIndex > -1 && dotIndex < originalFilename.length() - 1) {
				extension = originalFilename.substring(dotIndex).toLowerCase();
			}
		}

		if (!StringUtils.hasText(extension)) {
			extension = fromContentType(contentType);
		}
		if (!ALLOWED_EXTENSIONS.contains(extension)) {
			throw new IllegalArgumentException("지원하지 않는 이미지 확장자입니다.");
		}
		return extension;
	}

	private String fromContentType(String contentType) {
		if (!StringUtils.hasText(contentType)) {
			return "";
		}
		String lowered = contentType.toLowerCase();
		if ("image/jpeg".equals(lowered) || "image/jpg".equals(lowered)) {
			return ".jpg";
		}
		if ("image/png".equals(lowered)) {
			return ".png";
		}
		if ("image/gif".equals(lowered)) {
			return ".gif";
		}
		if ("image/webp".equals(lowered)) {
			return ".webp";
		}
		return "";
	}

	private static Set<String> buildAllowedExtensions() {
		Set<String> extensions = new HashSet<>();
		extensions.add(".jpg");
		extensions.add(".jpeg");
		extensions.add(".png");
		extensions.add(".gif");
		extensions.add(".webp");
		return extensions;
	}
}

