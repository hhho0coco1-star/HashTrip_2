package com.app.service.impl;

import com.app.dto.RouteDTO;
import com.app.dto.TagCategoryDTO;
import com.app.dto.TravelerTypeDTO;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class RouteService {

    // 상세 조회용 메서드
    public RouteDTO getRouteById(Long routeId) {
        return getAllRoutes().stream()
                .filter(r -> r.getId().equals(routeId))
                .findFirst()
                .orElse(null);
    }

    // 추천 루트 데이터 (총 6개)
    public List<RouteDTO> getAllRoutes() {
        List<RouteDTO> list = new ArrayList<>();

        // 1. 제주도 (기존)
        list.add(new RouteDTO(1L, "여행가 민수", "✈️", "adventurer", "제주도 서쪽 정복", 
                "에메랄드빛 바다와 오름을 동시에 즐기는 환상의 코스입니다.", 
                Arrays.asList("협재해수욕장", "금오름", "싱계물공원"), 
                buildTagMap("place:#바다", "plan:#무계획"), 120, 45, 98));

        // 2. 포천 (기존)
        list.add(new RouteDTO(2L, "힐러 지수", "🌿", "healer", "포천 숲길 산책", 
                "피로가 싹 가시는 초록빛 힐링 루트. 주말 나들이로 최고!", 
                Arrays.asList("고모리 저수지", "국립수목원", "광릉숲"), 
                buildTagMap("place:#숲", "plan:#계획형"), 85, 32, 82));

        // 3. 서울 (신규: 도시형)
        list.add(new RouteDTO(3L, "시티러버 현우", "🏙️", "explorer", "서울 감성 골목 투어", 
                "서촌의 고즈넉함과 힙지로의 활기를 한 번에 느끼는 서울 여행.", 
                Arrays.asList("경복궁 서촌", "익선동", "을지로 노가리골목"), 
                buildTagMap("place:#도시", "plan:#무계획"), 245, 112, 75));

        // 4. 강릉 (신규: 식도락)
        list.add(new RouteDTO(4L, "먹보 유진", "🍜", "foodie", "강릉 맛집 도장깨기", 
                "입이 즐거운 여행! 강릉에서만 맛볼 수 있는 특별한 메뉴들입니다.", 
                Arrays.asList("초당순두부마을", "중앙시장", "안목커피거리"), 
                buildTagMap("place:#바다", "plan:#계획형"), 310, 89, 92));

        // 5. 부산 (신규: 야경)
        list.add(new RouteDTO(5L, "밤하늘 준호", "🌃", "romantic", "부산 밤바다 야경 투어", 
                "부산의 진짜 매력은 밤에 나타납니다. 인생샷 명소만 골랐어요.", 
                Arrays.asList("더베이101", "광안리", "영도 흰여울마을"), 
                buildTagMap("place:#바다", "plan:#계획형"), 156, 67, 88));

        // 6. 단양 (신규: 액티비티)
        list.add(new RouteDTO(6L, "액션 가영", "🪂", "adventurer", "단양 하늘을 날다", 
                "익스트림한 여행을 원한다면? 패러글라이딩과 만천하 스카이워크!", 
                Arrays.asList("패러마을", "고수동굴", "만천하스카이워크"), 
                buildTagMap("place:#산", "plan:#무계획"), 92, 41, 64));

        return list;
    }

    public List<TagCategoryDTO> getAllTagCategories() {
        return Arrays.asList(
            new TagCategoryDTO("place", "장소", "📍", "#5B8DEE", "#E8F0FE", "tag-place"),
            new TagCategoryDTO("plan", "계획", "📝", "#22C55E", "#DCFCE7", "tag-plan")
        );
    }

    public List<TravelerTypeDTO> getAllTravelerTypes() {
        List<TravelerTypeDTO> types = new ArrayList<>();
        types.add(new TravelerTypeDTO("adventurer", "🤠", "프로 모험가", "#5B8DEE", "#E8F0FE", "도전적인 여행", null));
        types.add(new TravelerTypeDTO("healer", "🌿", "평화로운 힐러", "#22C55E", "#DCFCE7", "여유로운 여행", null));
        types.add(new TravelerTypeDTO("explorer", "🏙️", "도시 탐험가", "#A78BFA", "#F3F0FF", "도시의 매력을 찾는 여행", null));
        types.add(new TravelerTypeDTO("foodie", "🍜", "식도락가", "#F87171", "#FEF2F2", "맛집이 제일 중요함", null));
        types.add(new TravelerTypeDTO("romantic", "🌃", "낭만주의자", "#F5A623", "#FFFBEB", "분위기를 중시하는 여행", null));
        return types;
    }

    private Map<String, String> buildTagMap(String... tags) {
        Map<String, String> map = new LinkedHashMap<>();
        for (String t : tags) {
            String[] kv = t.split(":");
            if(kv.length == 2) map.put(kv[0], kv[1]);
        }
        return map;
    }
}