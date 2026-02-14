package com.app.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Component;

import com.app.dto.TourResponseDTO;

@Component
public class PlaceTagClassifier {

	private static final String LOC_NATURE_MT = "LOC_NATURE_MT";
	private static final String LOC_SEA_BEACH = "LOC_SEA_BEACH";
	private static final String LOC_CITY_CULTURE = "LOC_CITY_CULTURE";
	private static final String LOC_RURAL_COUNTRY = "LOC_RURAL_COUNTRY";

	private static final String PLAN_HIGH = "PLAN_HIGH";
	private static final String PLAN_MID = "PLAN_MID";
	private static final String SPONTANEOUS_HIGH = "SPONTANEOUS_HIGH";
	private static final String DEPENDENT_STYLE = "DEPENDENT_STYLE";

	private static final String MOVE_CAR_RENT = "MOVE_CAR_RENT";
	private static final String MOVE_PUBLIC_TRANSIT = "MOVE_PUBLIC_TRANSIT";
	private static final String MOVE_TAXI = "MOVE_TAXI";
	private static final String MOVE_WALK = "MOVE_WALK";

	private static final String STAY_HOTEL_RESORT = "STAY_HOTEL_RESORT";
	private static final String STAY_PENSION_ROOM = "STAY_PENSION_ROOM";
	private static final String STAY_CAMPING_GLAMP = "STAY_CAMPING_GLAMP";
	private static final String STAY_GUEST_SHARE = "STAY_GUEST_SHARE";

	private static final String BUDGET_LOW = "BUDGET_LOW";
	private static final String BUDGET_VALUE = "BUDGET_VALUE";
	private static final String BUDGET_MID_SATISFY = "BUDGET_MID_SATISFY";
	private static final String BUDGET_FLEX = "BUDGET_FLEX";

	private static final String COMP_SOLO = "COMP_SOLO";
	private static final String COMP_COUPLE = "COMP_COUPLE";
	private static final String COMP_FAMILY = "COMP_FAMILY";
	private static final String COMP_FRIENDS = "COMP_FRIENDS";

	private static final String FOOD_GOURMET = "FOOD_GOURMET";
	private static final String FOOD_LOCAL = "FOOD_LOCAL";
	private static final String FOOD_QUICK = "FOOD_QUICK";
	private static final String FOOD_MEAT_SEAFOOD = "FOOD_MEAT_SEAFOOD";

	private static final String PURPOSE_REST = "PURPOSE_REST";
	private static final String PURPOSE_ACTIVITY = "PURPOSE_ACTIVITY";
	private static final String PURPOSE_PHOTO = "PURPOSE_PHOTO";
	private static final String PURPOSE_HISTORY_CULTURE = "PURPOSE_HISTORY_CULTURE";

	private static final String INTENSITY_VERY_LOW = "INTENSITY_VERY_LOW";
	private static final String INTENSITY_LOW = "INTENSITY_LOW";
	private static final String INTENSITY_HIGH = "INTENSITY_HIGH";
	private static final String INTENSITY_VERY_HIGH = "INTENSITY_VERY_HIGH";

	private static final String MOOD_HOTPLACE = "MOOD_HOTPLACE";
	private static final String MOOD_STATIC = "MOOD_STATIC";
	private static final String MOOD_SEASONAL = "MOOD_SEASONAL";
	private static final String MOOD_NIGHT_VIEW = "MOOD_NIGHT_VIEW";

	private static final Map<String, String> TAG_NAME_BY_CODE = createTagNameMap();

	public List<String> classifyTagCodes(TourResponseDTO.PlaceDto item) {
		String contentTypeId = normalize(item.getContenttypeid());
		String cat1 = normalizeUpper(item.getCat1());
		String cat2 = normalizeUpper(item.getCat2());
		String cat3 = normalizeUpper(item.getCat3());
		String text = normalize(item.getTitle()) + " " + normalize(item.getAddr1()) + " " + cat1 + " " + cat2 + " " + cat3;

		Set<String> codes = new LinkedHashSet<>();
		codes.add(pickLocationTag(contentTypeId, cat1, text));
		codes.add(pickPlanningTag(contentTypeId, cat1, text));
		codes.add(pickMoveTag(contentTypeId, cat1, text));
		codes.add(pickBudgetTag(contentTypeId, cat1, text));
		codes.add(pickCompanionTag(contentTypeId, cat1, text));
		codes.add(pickPurposeTag(contentTypeId, cat1, text));
		codes.add(pickIntensityTag(contentTypeId, cat1, text));
		codes.add(pickSeasonMoodTag(contentTypeId, cat1, text));

		if (isStay(contentTypeId, cat1, text)) {
			codes.add(pickStayTag(text));
		}
		if (isFood(contentTypeId, cat1, text)) {
			codes.add(pickFoodTag(text));
		}

		return new ArrayList<>(codes);
	}

	public String classify(TourResponseDTO.PlaceDto item) {
		return toTagNamesCsv(classifyTagCodes(item));
	}

	public String toTagNamesCsv(List<String> tagCodes) {
		List<String> names = new ArrayList<>();
		for (String code : tagCodes) {
			names.add(TAG_NAME_BY_CODE.getOrDefault(code, code));
		}
		return String.join(",", names);
	}

	private String pickLocationTag(String contentTypeId, String cat1, String text) {
		if (containsAny(text, "바다", "해변", "해수욕장", "섬", "해안", "항구", "등대")) {
			return LOC_SEA_BEACH;
		}
		if (isNatural(contentTypeId, cat1) || containsAny(text, "산", "숲", "계곡", "폭포", "호수", "자연", "트레킹", "둘레길")) {
			return LOC_NATURE_MT;
		}
		if (containsAny(text, "마을", "농촌", "전원", "목장", "한옥마을", "시골")) {
			return LOC_RURAL_COUNTRY;
		}
		return LOC_CITY_CULTURE;
	}

	private String pickPlanningTag(String contentTypeId, String cat1, String text) {
		if (isCourse(contentTypeId, cat1) || isCulture(contentTypeId, cat1) || containsAny(text, "전시", "공연", "박물관", "미술관")) {
			return PLAN_HIGH;
		}
		if (isLeports(contentTypeId, cat1)) {
			return DEPENDENT_STYLE;
		}
		if (isFood(contentTypeId, cat1, text) || isShopping(contentTypeId, cat1)) {
			return SPONTANEOUS_HIGH;
		}
		return PLAN_MID;
	}

	private String pickMoveTag(String contentTypeId, String cat1, String text) {
		if (containsAny(text, "도보", "산책", "골목", "거리", "한옥마을")) {
			return MOVE_WALK;
		}
		if (containsAny(text, "야경", "밤", "나이트")) {
			return MOVE_TAXI;
		}
		if (isNatural(contentTypeId, cat1) || isLeports(contentTypeId, cat1) || isStay(contentTypeId, cat1, text)) {
			return MOVE_CAR_RENT;
		}
		return MOVE_PUBLIC_TRANSIT;
	}

	private String pickStayTag(String text) {
		if (containsAny(text, "게스트하우스", "호스텔", "게하")) {
			return STAY_GUEST_SHARE;
		}
		if (containsAny(text, "캠핑", "글램핑")) {
			return STAY_CAMPING_GLAMP;
		}
		if (containsAny(text, "펜션")) {
			return STAY_PENSION_ROOM;
		}
		return STAY_HOTEL_RESORT;
	}

	private String pickBudgetTag(String contentTypeId, String cat1, String text) {
		if (isShopping(contentTypeId, cat1) || containsAny(text, "호텔", "리조트", "럭셔리", "프리미엄")) {
			return BUDGET_FLEX;
		}
		if (isFood(contentTypeId, cat1, text) || containsAny(text, "로컬", "분식", "시장", "가성비")) {
			return BUDGET_VALUE;
		}
		if (isNatural(contentTypeId, cat1) || containsAny(text, "공원", "해변", "둘레길")) {
			return BUDGET_LOW;
		}
		return BUDGET_MID_SATISFY;
	}

	private String pickCompanionTag(String contentTypeId, String cat1, String text) {
		if (containsAny(text, "키즈", "동물원", "아쿠아리움", "놀이공원", "가족") || "15".equals(contentTypeId)) {
			return COMP_FAMILY;
		}
		if (containsAny(text, "데이트", "커플", "야경", "감성")) {
			return COMP_COUPLE;
		}
		if (isLeports(contentTypeId, cat1) || containsAny(text, "친구", "액티비티", "레포츠")) {
			return COMP_FRIENDS;
		}
		return COMP_SOLO;
	}

	private String pickFoodTag(String text) {
		if (containsAny(text, "고기", "해산물", "회", "수산")) {
			return FOOD_MEAT_SEAFOOD;
		}
		if (containsAny(text, "전통", "로컬", "향토")) {
			return FOOD_LOCAL;
		}
		if (containsAny(text, "분식", "간편식", "패스트")) {
			return FOOD_QUICK;
		}
		return FOOD_GOURMET;
	}

	private String pickPurposeTag(String contentTypeId, String cat1, String text) {
		if (isLeports(contentTypeId, cat1) || containsAny(text, "서핑", "등산", "트레킹", "클라이밍", "래프팅", "집라인")) {
			return PURPOSE_ACTIVITY;
		}
		if (isCulture(contentTypeId, cat1) || containsAny(text, "유적", "역사", "사찰", "궁", "박물관", "미술관")) {
			return PURPOSE_HISTORY_CULTURE;
		}
		if (containsAny(text, "포토", "전망", "일몰", "일출", "감성", "야경")) {
			return PURPOSE_PHOTO;
		}
		return PURPOSE_REST;
	}

	private String pickIntensityTag(String contentTypeId, String cat1, String text) {
		if (isLeports(contentTypeId, cat1) || containsAny(text, "클라이밍", "래프팅", "서핑")) {
			return INTENSITY_VERY_HIGH;
		}
		if (isNatural(contentTypeId, cat1) || isCourse(contentTypeId, cat1) || containsAny(text, "등산", "트레킹", "자전거")) {
			return INTENSITY_HIGH;
		}
		if (isCulture(contentTypeId, cat1) || containsAny(text, "전시", "박물관", "미술관")) {
			return INTENSITY_LOW;
		}
		return INTENSITY_VERY_LOW;
	}

	private String pickSeasonMoodTag(String contentTypeId, String cat1, String text) {
		if ("15".equals(contentTypeId) || containsAny(text, "벚꽃", "단풍", "축제", "스키", "눈꽃", "계절")) {
			return MOOD_SEASONAL;
		}
		if (containsAny(text, "야경", "밤", "나이트")) {
			return MOOD_NIGHT_VIEW;
		}
		if (isCulture(contentTypeId, cat1) || isStay(contentTypeId, cat1, text) || containsAny(text, "조용", "정적")) {
			return MOOD_STATIC;
		}
		return MOOD_HOTPLACE;
	}

	private boolean isNatural(String contentTypeId, String cat1) {
		return "12".equals(contentTypeId) || cat1.startsWith("A01");
	}

	private boolean isCulture(String contentTypeId, String cat1) {
		return "14".equals(contentTypeId) || "15".equals(contentTypeId) || cat1.startsWith("A02");
	}

	private boolean isLeports(String contentTypeId, String cat1) {
		return "28".equals(contentTypeId) || cat1.startsWith("A03");
	}

	private boolean isShopping(String contentTypeId, String cat1) {
		return "38".equals(contentTypeId) || cat1.startsWith("A04");
	}

	private boolean isFood(String contentTypeId, String cat1, String text) {
		return "39".equals(contentTypeId) || cat1.startsWith("A05")
				|| containsAny(text, "맛집", "식당", "레스토랑", "카페", "푸드");
	}

	private boolean isStay(String contentTypeId, String cat1, String text) {
		return "32".equals(contentTypeId) || cat1.startsWith("B02")
				|| containsAny(text, "호텔", "리조트", "펜션", "캠핑", "게스트하우스");
	}

	private boolean isCourse(String contentTypeId, String cat1) {
		return "25".equals(contentTypeId) || cat1.startsWith("C01");
	}

	private boolean containsAny(String text, String... keywords) {
		for (String keyword : keywords) {
			if (text.contains(keyword)) {
				return true;
			}
		}
		return false;
	}

	private String normalize(String value) {
		return value == null ? "" : value.trim();
	}

	private String normalizeUpper(String value) {
		return value == null ? "" : value.trim().toUpperCase();
	}

	private static Map<String, String> createTagNameMap() {
		Map<String, String> map = new LinkedHashMap<>();
		map.put(LOC_NATURE_MT, "자연/산");
		map.put(LOC_SEA_BEACH, "바다/해변");
		map.put(LOC_CITY_CULTURE, "도시/문화");
		map.put(LOC_RURAL_COUNTRY, "시골/전원");

		map.put(PLAN_HIGH, "계획(High)");
		map.put(PLAN_MID, "계획(Mid)");
		map.put(SPONTANEOUS_HIGH, "즉흥(High)");
		map.put(DEPENDENT_STYLE, "의존형");

		map.put(MOVE_CAR_RENT, "자차/렌트");
		map.put(MOVE_PUBLIC_TRANSIT, "대중교통");
		map.put(MOVE_TAXI, "택시");
		map.put(MOVE_WALK, "도보");

		map.put(STAY_HOTEL_RESORT, "호텔/리조트");
		map.put(STAY_PENSION_ROOM, "펜션/객실");
		map.put(STAY_CAMPING_GLAMP, "캠핑/글램핑");
		map.put(STAY_GUEST_SHARE, "게하/공유");

		map.put(BUDGET_LOW, "저예산");
		map.put(BUDGET_VALUE, "가성비");
		map.put(BUDGET_MID_SATISFY, "중가/만족");
		map.put(BUDGET_FLEX, "고예산/플렉스");

		map.put(COMP_SOLO, "혼자");
		map.put(COMP_COUPLE, "커플");
		map.put(COMP_FAMILY, "가족");
		map.put(COMP_FRIENDS, "친구");

		map.put(FOOD_GOURMET, "미식/맛집");
		map.put(FOOD_LOCAL, "로컬푸드");
		map.put(FOOD_QUICK, "간편식");
		map.put(FOOD_MEAT_SEAFOOD, "고기/해산물");

		map.put(PURPOSE_REST, "휴식");
		map.put(PURPOSE_ACTIVITY, "도전/활동");
		map.put(PURPOSE_PHOTO, "사진/감성");
		map.put(PURPOSE_HISTORY_CULTURE, "역사/문화");

		map.put(INTENSITY_VERY_LOW, "매우 낮음");
		map.put(INTENSITY_LOW, "낮음");
		map.put(INTENSITY_HIGH, "높음");
		map.put(INTENSITY_VERY_HIGH, "매우 높음");

		map.put(MOOD_HOTPLACE, "핫플레이스");
		map.put(MOOD_STATIC, "정적인");
		map.put(MOOD_SEASONAL, "계절성");
		map.put(MOOD_NIGHT_VIEW, "야경/밤");
		return map;
	}
}
