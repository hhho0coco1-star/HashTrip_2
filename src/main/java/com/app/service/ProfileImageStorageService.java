package com.app.service;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.app.dto.UsersDTO;

@Service
public class ProfileImageStorageService {

	private static final long MAX_PROFILE_IMAGE_SIZE_BYTES = 5L * 1024L * 1024L;
	private static final Set<String> ALLOWED_EXTENSIONS = buildAllowedExtensions();
	private static final Set<String> ALLOWED_MIME_TYPES = buildAllowedMimeTypes();

	public ProfileImageData parse(MultipartFile profileImage) throws IOException {
		if (profileImage == null || profileImage.isEmpty()) {
			return null;
		}

		validateProfileImage(profileImage);

		String mimeType = normalizeMimeType(profileImage.getContentType());
		String extension = resolveExtension(profileImage.getOriginalFilename(), mimeType);
		String safeFileName = resolveSafeFileName(profileImage.getOriginalFilename(), extension);
		byte[] binary = profileImage.getBytes();

		return new ProfileImageData(binary, mimeType, safeFileName);
	}

	public void applyToUser(UsersDTO usersDTO, MultipartFile profileImage) throws IOException {
		if (usersDTO == null) {
			throw new IllegalArgumentException("프로필 대상 사용자 정보가 없습니다.");
		}
		ProfileImageData profileImageData = parse(profileImage);
		if (profileImageData == null) {
			return;
		}

		usersDTO.setUserProfileBinary(profileImageData.getBinary());
		usersDTO.setUserProfileMimeType(profileImageData.getMimeType());
		usersDTO.setUserProfileFileName(profileImageData.getFileName());
		// BLOB 저장 우선.
		usersDTO.setUserProfileImg(null);
	}

	private void validateProfileImage(MultipartFile profileImage) {
		String mimeType = normalizeMimeType(profileImage.getContentType());
		if (!StringUtils.hasText(mimeType) || !ALLOWED_MIME_TYPES.contains(mimeType)) {
			throw new IllegalArgumentException("프로필 이미지는 JPG, PNG, GIF, WEBP만 업로드할 수 있습니다.");
		}
		if (profileImage.getSize() > MAX_PROFILE_IMAGE_SIZE_BYTES) {
			throw new IllegalArgumentException("프로필 이미지는 5MB 이하만 업로드할 수 있습니다.");
		}
	}

	private String normalizeMimeType(String mimeType) {
		if (!StringUtils.hasText(mimeType)) {
			return null;
		}
		return mimeType.trim().toLowerCase();
	}

	private String resolveExtension(String originalFilename, String mimeType) {
		String extension = "";
		if (StringUtils.hasText(originalFilename)) {
			String cleaned = StringUtils.cleanPath(originalFilename);
			int dotIndex = cleaned.lastIndexOf('.');
			if (dotIndex > -1 && dotIndex < cleaned.length() - 1) {
				extension = cleaned.substring(dotIndex).toLowerCase();
			}
		}

		if (!StringUtils.hasText(extension)) {
			extension = extensionFromMimeType(mimeType);
		}

		if (!ALLOWED_EXTENSIONS.contains(extension)) {
			throw new IllegalArgumentException("지원하지 않는 이미지 확장자입니다.");
		}
		return extension;
	}

	private String extensionFromMimeType(String mimeType) {
		if (!StringUtils.hasText(mimeType)) {
			return "";
		}
		if ("image/jpeg".equals(mimeType) || "image/jpg".equals(mimeType)) {
			return ".jpg";
		}
		if ("image/png".equals(mimeType)) {
			return ".png";
		}
		if ("image/gif".equals(mimeType)) {
			return ".gif";
		}
		if ("image/webp".equals(mimeType)) {
			return ".webp";
		}
		return "";
	}

	private String resolveSafeFileName(String originalFilename, String extension) {
		if (!StringUtils.hasText(originalFilename)) {
			return "profile" + extension;
		}
		String cleaned = StringUtils.cleanPath(originalFilename);
		int slash = Math.max(cleaned.lastIndexOf('/'), cleaned.lastIndexOf('\\'));
		if (slash >= 0) {
			cleaned = cleaned.substring(slash + 1);
		}
		if (!StringUtils.hasText(cleaned)) {
			return "profile" + extension;
		}
		return cleaned.length() > 255 ? cleaned.substring(0, 255) : cleaned;
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

	private static Set<String> buildAllowedMimeTypes() {
		Set<String> mimeTypes = new HashSet<>();
		mimeTypes.add("image/jpeg");
		mimeTypes.add("image/jpg");
		mimeTypes.add("image/png");
		mimeTypes.add("image/gif");
		mimeTypes.add("image/webp");
		return mimeTypes;
	}

	public static final class ProfileImageData {
		private final byte[] binary;
		private final String mimeType;
		private final String fileName;

		public ProfileImageData(byte[] binary, String mimeType, String fileName) {
			this.binary = binary;
			this.mimeType = mimeType;
			this.fileName = fileName;
		}

		public byte[] getBinary() {
			return binary;
		}

		public String getMimeType() {
			return mimeType;
		}

		public String getFileName() {
			return fileName;
		}
	}
}
