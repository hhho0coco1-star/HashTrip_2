-- hifive schema bootstrap
-- 삭제 스크립트는 db_delete.sql에서 별도 관리합니다.
-- 이 파일은 생성 / 변경 / 초기 데이터 적재만 포함합니다.

CREATE TABLE Users (
    user_no NUMBER(19) PRIMARY KEY,
    user_type VARCHAR2(20),
    user_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_status CHAR(1) DEFAULT 'A' NOT NULL CHECK (user_status IN ('A', 'S', 'W')),
    user_name VARCHAR2(100),
    user_gender CHAR(1) CHECK (user_gender IN ('M', 'F')), -- 남/여 구분 예시
    user_phoneNumber VARCHAR2(50),
    user_registration_no VARCHAR2(100),
    user_nickName VARCHAR2(20),
    user_profile_img VARCHAR2(255),
    user_profile_blob BLOB,
    user_profile_mime_type VARCHAR2(100),
    user_profile_file_name VARCHAR2(255)
);

COMMENT ON COLUMN Users.user_status IS 'A:활성, S:휴면, W:탈퇴';

CREATE TABLE User_Authentication (
    user_auth_no NUMBER(19) PRIMARY KEY,
    user_no NUMBER(19) NOT NULL,
    user_auth_id VARCHAR2(100) UNIQUE, -- ID 중복 방지
    user_auth_pw VARCHAR2(255),
    user_auth_email VARCHAR2(100),
    user_auth_sns_type VARCHAR2(20), -- ENUM 대신 VARCHAR로 처리 (Oracle 기준)
    CONSTRAINT fk_auth_user_no FOREIGN KEY (user_no) REFERENCES Users(user_no) ON DELETE CASCADE
);

CREATE TABLE User_Address (
    user_address_no NUMBER(19) PRIMARY KEY,
    user_no NUMBER(19) NOT NULL,
    user_zip_code VARCHAR2(6),
    user_base_address VARCHAR2(255),
    user_detail_address VARCHAR2(255),
    CONSTRAINT fk_addr_user_no FOREIGN KEY (user_no) REFERENCES Users(user_no) ON DELETE CASCADE
);

-- 1. 공통 코드 그룹
CREATE TABLE code_group (
    group_code VARCHAR2(20) PRIMARY KEY,
    group_name VARCHAR2(50),
    is_used CHAR(1) CHECK (is_used IN ('Y', 'N'))
);

-- 2. 세부 공통 코드
CREATE TABLE Common_Code (
    common_code VARCHAR2(20) PRIMARY KEY,
    group_code VARCHAR2(20),
    code_name VARCHAR2(50),
    output_sort_order NUMBER(1),
    is_used CHAR(1) CHECK (is_used IN ('Y', 'N')),
    CONSTRAINT fk_common_group FOREIGN KEY (group_code) REFERENCES code_group(group_code)
);

-- 3. 태그 마스터 (여행지 및 성향 분석용)
CREATE TABLE Tag_Master (
    tag_code VARCHAR2(50) PRIMARY KEY,
    tag_name VARCHAR2(100) NOT NULL,
    tag_category VARCHAR2(20)
);

-- 4. 질문 카테고리
CREATE TABLE Questions_categories (
    question_no NUMBER(3) PRIMARY KEY,
    question_name VARCHAR2(50)
);

-- 5. 장소 마스터 데이터
CREATE TABLE Place (
    place_no NUMBER(19) PRIMARY KEY,
    place_content_id VARCHAR2(30 CHAR),
    place_name VARCHAR2(200 CHAR) NOT NULL,
    place_category VARCHAR2(50) NOT NULL,
    place_address VARCHAR2(500 CHAR),
    place_latitude NUMBER(12, 8),
    place_longitude NUMBER(13, 8),
    place_rating NUMBER(3, 2),
    place_number VARCHAR2(255 CHAR),
    place_thumbnail_url VARCHAR2(1000 CHAR)
);

CREATE TABLE Place_Hours (
    hours_id NUMBER(19) PRIMARY KEY,
    place_no NUMBER(19) NOT NULL,
    day_of_week NUMBER(10),
    open_time VARCHAR2(10),
    close_time VARCHAR2(10),
    break_strat_time VARCHAR2(10),
    break_end_time VARCHAR2(10),
    last_order VARCHAR2(10),
    is_closed CHAR(1) DEFAULT 'N',
    CONSTRAINT fk_hours_place FOREIGN KEY (place_no) REFERENCES Place(place_no) ON DELETE CASCADE,
    CONSTRAINT ck_hours_day CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT ck_hours_closed CHECK (is_closed IN ('Y', 'N'))
);

CREATE INDEX IDX_PLACE_HOURS_PLACE_NO ON Place_Hours(place_no);
CREATE UNIQUE INDEX UQ_PLACE_HOURS_PLACE_DAY ON Place_Hours(place_no, day_of_week);

-- 6. 질문 상세 및 선택지
CREATE TABLE Questions (
    question_number NUMBER(3) PRIMARY KEY,
    question_no NUMBER(3),
    question_content VARCHAR2(2000) NOT NULL,
    question_img VARCHAR2(1000) NOT NULL,
    CONSTRAINT fk_q_category FOREIGN KEY (question_no) REFERENCES Questions_categories(question_no)
);

CREATE TABLE Qusetion_options (
    option_id NUMBER(19) PRIMARY KEY,
    question_number NUMBER(3),
    question_no NUMBER(3),
    option_text VARCHAR2(500) NOT NULL,
    option_img VARCHAR2(1000) NOT NULL,
    CONSTRAINT fk_opt_q_num FOREIGN KEY (question_number) REFERENCES Questions(question_number)
);

-- 7. 사용자별 성향 태그 매핑 (Users 참조)
CREATE TABLE User_Tag_Map (
    mapping_no NUMBER PRIMARY KEY,
    user_no NUMBER(19), -- FK
    question_id VARCHAR2(10),
    tag_code VARCHAR2(50), -- FK
    CONSTRAINT fk_utag_user FOREIGN KEY (user_no) REFERENCES Users(user_no),
    CONSTRAINT fk_utag_tag FOREIGN KEY (tag_code) REFERENCES Tag_Master(tag_code)
);

-- 8. 장소 태그 매핑
CREATE TABLE Place_Tag_Map (
    place_tag_no NUMBER(19) PRIMARY KEY,
    place_no NUMBER(19) NOT NULL,
    tag_code VARCHAR2(50) NOT NULL,
    tag_weight NUMBER(4, 3) DEFAULT 1 NOT NULL CHECK (tag_weight >= 0 AND tag_weight <= 1),
    tag_source VARCHAR2(20) DEFAULT 'RULE' NOT NULL CHECK (tag_source IN ('RULE', 'MANUAL', 'ML')),
    tag_confidence NUMBER(4, 3) DEFAULT 1 NOT NULL CHECK (tag_confidence >= 0 AND tag_confidence <= 1),
    created_at DATE DEFAULT SYSDATE NOT NULL,
    updated_at DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT uk_ptag_place_tag UNIQUE (place_no, tag_code),
    CONSTRAINT fk_ptag_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
    CONSTRAINT fk_ptag_tag FOREIGN KEY (tag_code) REFERENCES Tag_Master(tag_code)
);

CREATE INDEX IDX_PLACE_TAG_MAP_TAG_CODE ON Place_Tag_Map(tag_code);
CREATE INDEX IDX_PLACE_TAG_MAP_PLACE_NO ON Place_Tag_Map(place_no);

-- 9. 여행 성향 분석 결과 (Users 참조)
CREATE TABLE Travel_Styles (
    style_user_no NUMBER(19) PRIMARY KEY,
    user_no NUMBER(19), -- 타입을 NUMBER(19)로 일치시킴
    travel_is_analyzde CHAR(1) CHECK (travel_is_analyzde IN ('Y', 'N')),
    travel_analyzed_date DATE,
    travel_type_name VARCHAR2(100),
    selected_place_codes VARCHAR2(200),
    selected_energy_codes VARCHAR2(200),
    selected_plan_codes VARCHAR2(200),
    travel_final_summary VARCHAR2(1000),
    CONSTRAINT fk_style_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 10. 여행 일정 마스터 및 상세
CREATE TABLE Travel_Plans (
    plan_no NUMBER(19) PRIMARY KEY,
    user_no NUMBER(19),
    plan_title VARCHAR2(200),
    plan_is_public CHAR(1) CHECK (plan_is_public IN ('Y', 'N')),
    plan_status VARCHAR2(20),
    plan_start_date DATE,
    plan_end_date DATE,
    created_date DATE DEFAULT SYSDATE NOT NULL,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_plan_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

CREATE TABLE Plan_Details (
    plan_detail_no NUMBER(19) PRIMARY KEY,
    plan_no NUMBER(19),
    place_no NUMBER(19),
    user_no NUMBER(19), -- 기존 VARCHAR2(100)에서 변경
    plan_visit_order NUMBER(5),
    plan_meno VARCHAR2(1000),
    detail_start_date DATE,
    detail_end_date DATE,
    CONSTRAINT fk_pdet_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no),
    CONSTRAINT fk_pdet_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
    CONSTRAINT fk_pdet_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

CREATE TABLE Route_Save_History (
    save_no NUMBER(19) PRIMARY KEY,
    source_plan_no NUMBER(19) NOT NULL,
    saved_user_no NUMBER(19) NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT uk_route_save_once UNIQUE (source_plan_no, saved_user_no),
    CONSTRAINT fk_route_save_plan FOREIGN KEY (source_plan_no) REFERENCES Travel_Plans(plan_no),
    CONSTRAINT fk_route_save_user FOREIGN KEY (saved_user_no) REFERENCES Users(user_no)
);

CREATE INDEX IDX_ROUTE_SAVE_PLAN_NO ON ROUTE_SAVE_HISTORY(source_plan_no);
CREATE INDEX IDX_ROUTE_SAVE_USER_NO ON ROUTE_SAVE_HISTORY(saved_user_no);

-- 11. 여행 로그 및 사진 (Review 포함)
CREATE TABLE Travel_Logs (
    log_no NUMBER(19) PRIMARY KEY,
    plan_no NUMBER(19),
    place_no NUMBER(19),
    user_no NUMBER(19),
    log_content VARCHAR2(4000),
    log_rating NUMBER(5),
    CONSTRAINT fk_log_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no),
    CONSTRAINT fk_log_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
    CONSTRAINT fk_log_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

CREATE TABLE Community (
    review_no NUMBER(19) PRIMARY KEY,
    plan_no NUMBER(19),
    user_no NUMBER(19),
    review_content VARCHAR2(2000),
    review_rating NUMBER(1),
    created_at DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_comm_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no),
    CONSTRAINT fk_comm_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

CREATE TABLE Place_Review (
    comment_no NUMBER(19) PRIMARY KEY,
    log_no NUMBER(19),
    place_no NUMBER(19),
    comment_content VARCHAR2(2000),
    rating NUMBER(1) DEFAULT 5 NOT NULL,
    created_by VARCHAR2(100), -- user_no 또는 nickName 기록
    created_at DATE DEFAULT SYSDATE,
    CONSTRAINT ck_place_review_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_rev_log FOREIGN KEY (log_no) REFERENCES Travel_Logs(log_no),
    CONSTRAINT fk_rev_place FOREIGN KEY (place_no) REFERENCES Place(place_no)
);

CREATE TABLE photo_data (
    photo_no NUMBER(19) PRIMARY KEY,
    comment_no NUMBER(19),
    log_photo_url VARCHAR2(1000),
    photo_binary BLOB,
    photo_mime_type VARCHAR2(100),
    photo_file_name VARCHAR2(255),
    CONSTRAINT fk_photo_comment FOREIGN KEY (comment_no) REFERENCES Place_Review(comment_no)
);

-- 12. 사용자의 찜 카테고리 관리
CREATE TABLE Category (
    category_no NUMBER(19) PRIMARY KEY,
    user_no NUMBER(19),
    category_type VARCHAR2(100),
    category_is_used CHAR(1) DEFAULT 'Y' NOT NULL CHECK (category_is_used IN ('Y', 'N')),
    CONSTRAINT fk_cat_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 13. 찜 목록 (장소-카테고리-사용자 연결)
CREATE TABLE wishlist (
    wish_no NUMBER(19) PRIMARY KEY,
    place_no NUMBER(19),
    category_no NUMBER(19),
    user_no NUMBER(19),
    wish_date DATE DEFAULT SYSDATE,
    CONSTRAINT uk_wish_user_place_category UNIQUE (user_no, place_no, category_no),
    CONSTRAINT fk_wish_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
    CONSTRAINT fk_wish_cat FOREIGN KEY (category_no) REFERENCES Category(category_no),
    CONSTRAINT fk_wish_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 질문 카테고리 시퀀스
CREATE SEQUENCE SEQ_QUESTION_CAT_NO START WITH 1 INCREMENT BY 1;

-- 태그 마스터는 코드를 직접 입력하는 경우가 많지만, 필요시 사용
-- CREATE SEQUENCE SEQ_TAG_CODE START WITH 1 INCREMENT BY 1;

-- 장소 고유 번호 시퀀스
CREATE SEQUENCE SEQ_PLACE_NO START WITH 1 INCREMENT BY 1;

-- 질문 및 옵션 번호 시퀀스
CREATE SEQUENCE SEQ_QUESTION_NUM START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_OPTION_ID START WITH 1 INCREMENT BY 1;
-- 운영시간 고유 번호 시퀀스
CREATE SEQUENCE SEQ_HOURS_ID START WITH 1 INCREMENT BY 1;

-- 사용자-태그 매핑 번호 시퀀스
CREATE SEQUENCE SEQ_USER_TAG_MAP_NO START WITH 1 INCREMENT BY 1;

-- 장소-태그 매핑 번호 시퀀스
CREATE SEQUENCE SEQ_PLACE_TAG_MAP_NO START WITH 1 INCREMENT BY 1;

-- 여행 성향 분석 결과 번호 시퀀스
CREATE SEQUENCE SEQ_STYLE_USER_NO START WITH 1 INCREMENT BY 1;

-- 여행 일정 마스터 및 상세 시퀀스
CREATE SEQUENCE SEQ_PLAN_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PLAN_DETAIL_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ROUTE_SAVE_NO START WITH 1 INCREMENT BY 1;

-- 여행 로그 및 리뷰 시퀀스
CREATE SEQUENCE SEQ_LOG_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_COMMENT_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_COMMUNITY_REVIEW_NO START WITH 1 INCREMENT BY 1;

-- 사진 데이터 고유 번호 시퀀스
CREATE SEQUENCE SEQ_PHOTO_NO START WITH 1 INCREMENT BY 1;

-- 찜 카테고리 및 찜 목록 시퀀스
CREATE SEQUENCE SEQ_CATEGORY_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_WISH_NO START WITH 1 INCREMENT BY 1;

-- Users 테이블용 시퀀스
CREATE SEQUENCE SEQ_USER_NO
START WITH 1
INCREMENT BY 1
NOCACHE;

-- User_Authentication 테이블용 시퀀스
CREATE SEQUENCE SEQ_USER_AUTH_NO
START WITH 1
INCREMENT BY 1
NOCACHE;

-- User_Address 테이블용 시퀀스
CREATE SEQUENCE SEQ_USER_ADDRESS_NO
START WITH 1
INCREMENT BY 1
NOCACHE;

-- 사용자 1:1 문의 DB 테이블 추가
CREATE TABLE PLACE_INQUIRY (
    INQUIRY_NO      NUMBER PRIMARY KEY,          -- 문의 고유 번호
    USER_NO         NUMBER NOT NULL,             -- 작성자 번호 (FK)
    INQUIRY_TYPE    VARCHAR2(50) NOT NULL,       -- [추가] 문의 유형 (예: 서비스 이용, 정보 오류, 기타)
    INQUIRY_EMAIL   VARCHAR2(100) NOT NULL,      -- [추가] 답변받을 이메일 주소
    INQUIRY_TITLE   VARCHAR2(200) NOT NULL,      -- 문의 제목
    INQUIRY_CONTENT CLOB NOT NULL,               -- 문의 내용
    REPLY_CONTENT   CLOB,                        -- 관리자 답변 내용
    INQUIRY_DATE    DATE DEFAULT SYSDATE,        -- 작성일
    REPLY_DATE      DATE,                        -- 답변일
    STATUS          CHAR(1) DEFAULT 'N',         -- 답변 여부 ('N': 미답변, 'Y': 답변완료)
    
    -- 외래키 설정
    CONSTRAINT FK_INQUIRY_USER FOREIGN KEY (USER_NO) REFERENCES USERS(USER_NO)
);

-- 번호 자동 생성을 위한 시퀀스
CREATE SEQUENCE SEQ_INQUIRY_NO START WITH 1 INCREMENT BY 1;

-- 여행 성향 시퀀스 생성
CREATE SEQUENCE SEQ_TRAVEL_STYLE
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- 1. 각 태그별 가중치를 정의하는 테이블
CREATE TABLE TAG_WEIGHT_MASTER (
    CATEGORY VARCHAR2(20),     -- PLACE, ENERGY, PLAN
    TAG_VALUE VARCHAR2(50),    -- NATURE, SEA, ...
    WEIGHT NUMBER              -- 1, 2, 4, 8...
);

-- 2. 가중치 합계에 따른 결과 문구를 저장하는 테이블
CREATE TABLE TRAVEL_RESULT_MAPPING (
    CATEGORY VARCHAR2(20),
    TOTAL_WEIGHT NUMBER,       -- 가중치 합계 (예: 3)
    RESULT_TEXT VARCHAR2(200)  -- 산과 바다를 누비는 자유로운 영혼
);

-- 태그 마스터 데이터
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('LOC_NATURE_MT', '산·자연', 'LOCATION');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('LOC_SEA_BEACH', '바다·해변', 'LOCATION');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('LOC_CITY_CULTURE', '도시·문화', 'LOCATION');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('LOC_RURAL_COUNTRY', '시골·온천', 'LOCATION');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('PLAN_HIGH', '분 단위 계획형', 'PLANNING');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('PLAN_MID', '주요 스팟만 선정', 'PLANNING');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('SPONTANEOUS_HIGH', '발길 닿는 대로 즉흥', 'PLANNING');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('DEPENDENT_STYLE', '남이 짜준 대로', 'PLANNING');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOVE_CAR_RENT', '자가용·렌트카', 'MOVE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOVE_PUBLIC_TRANSIT', '대중교통', 'MOVE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOVE_TAXI', '택시', 'MOVE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOVE_WALK', '도보 여행', 'MOVE');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('STAY_HOTEL_RESORT', '호텔·리조트', 'STAY');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('STAY_PENSION_ROOM', '감성 에어비앤비', 'STAY');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('STAY_CAMPING_GLAMP', '자연 속 캠핑', 'STAY');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('STAY_GUEST_SHARE', '가성비 게하', 'STAY');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('BUDGET_LOW', '철저한 예산형', 'BUDGET');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('BUDGET_VALUE', '가성비 중심', 'BUDGET');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('BUDGET_MID_SATISFY', '쓸 땐 쓰는 스타일', 'BUDGET');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('BUDGET_FLEX', '플렉스 스타일', 'BUDGET');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('COMP_SOLO', '혼자만의 여행', 'COMPANION');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('COMP_COUPLE', '사랑하는 연인', 'COMPANION');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('COMP_FAMILY', '가족과 함께', 'COMPANION');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('COMP_FRIENDS', '즐거운 친구들', 'COMPANION');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('FOOD_GOURMET', '유명 맛집 탐방', 'FOOD_STYLE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('FOOD_LOCAL', '로컬 현지 음식', 'FOOD_STYLE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('FOOD_QUICK', '간편식·편의점', 'FOOD_STYLE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('FOOD_MEAT_SEAFOOD', '직접 요리', 'FOOD_STYLE');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('PURPOSE_REST', '완전한 휴식', 'PURPOSE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('PURPOSE_ACTIVITY', '액티비티·체험', 'PURPOSE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('PURPOSE_PHOTO', '인생샷 남기기', 'PURPOSE');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('PURPOSE_HISTORY_CULTURE', '문화·역사 공부', 'PURPOSE');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('INTENSITY_VERY_LOW', '숙소에서 힐링', 'INTENSITY');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('INTENSITY_LOW', '여유로운 일정', 'INTENSITY');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('INTENSITY_HIGH', '바쁜 관광 일정', 'INTENSITY');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('INTENSITY_VERY_HIGH', '밤까지 풀코스', 'INTENSITY');

INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOOD_HOTPLACE', '북적이는 핫플', 'MOOD');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOOD_STATIC', '조용한 숨은 명소', 'MOOD');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOOD_SEASONAL', '계절감이 있는 곳', 'MOOD');
INSERT INTO TAG_MASTER (TAG_CODE, TAG_NAME, TAG_CATEGORY) VALUES ('MOOD_NIGHT_VIEW', '화려한 야경', 'MOOD');

-- 질문/선택지 기본 데이터
INSERT INTO Questions_categories (question_no, question_name) VALUES (1, '선호지형');
INSERT INTO Questions_categories (question_no, question_name) VALUES (2, '계획스타일');
INSERT INTO Questions_categories (question_no, question_name) VALUES (3, '이동수단');
INSERT INTO Questions_categories (question_no, question_name) VALUES (4, '숙소스타일');
INSERT INTO Questions_categories (question_no, question_name) VALUES (5, '예산규모');
INSERT INTO Questions_categories (question_no, question_name) VALUES (6, '동행자');
INSERT INTO Questions_categories (question_no, question_name) VALUES (7, '식도락');
INSERT INTO Questions_categories (question_no, question_name) VALUES (8, '여행목적');
INSERT INTO Questions_categories (question_no, question_name) VALUES (9, '활동강도');
INSERT INTO Questions_categories (question_no, question_name) VALUES (10, '선호분위기');

INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (1, 1, '어떤 여행지를 선호하세요?', 'q1.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (2, 2, '여행 계획 스타일은?', 'q2.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (3, 3, '주로 어떤 이동 수단을 쓰나요?', 'q3.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (4, 4, '숙소는 어떤 스타일을 선호하시나요?', 'q4.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (5, 5, '여행 예산 스타일은 어떤가요?', 'q5.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (6, 6, '주로 누구와 여행하시나요?', 'q6.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (7, 7, '여행 중 음식 스타일은 어떤가요?', 'q7.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (8, 8, '이번 여행의 가장 큰 목적은?', 'q8.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (9, 9, '평소 여행의 활동 강도는 어느 정도인가요?', 'q9.jpg');
INSERT INTO Questions (question_no, question_number, question_content, question_img) VALUES (10, 10, '선호하는 여행 시기나 분위기는?', 'q10.jpg');

INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (1, 1, 1, '산 · 계곡 · 자연', 'opt1_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (2, 1, 1, '바다 · 해변 · 섬', 'opt1_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (3, 1, 1, '도시 · 골목 · 문화', 'opt1_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (4, 1, 1, '시골 · 온천 · 전원', 'opt1_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (5, 2, 2, '분 단위 계획형', 'opt2_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (6, 2, 2, '주요 스팟만 정하는 형', 'opt2_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (7, 2, 2, '발길 닿는 대로 즉흥형', 'opt2_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (8, 2, 2, '남이 짜주는 대로 따라 가는 형', 'opt2_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (9, 3, 3, '자가용 · 렌트카', 'opt3_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (10, 3, 3, '대중교통', 'opt3_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (11, 3, 3, '택시', 'opt3_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (12, 3, 3, '뚜벅이', 'opt3_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (13, 4, 4, '호텔 · 리조트', 'opt4_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (14, 4, 4, '펜션 · 에어비앤비', 'opt4_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (15, 4, 4, '캠핑 · 글램핑', 'opt4_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (16, 4, 4, '게스트하우스', 'opt4_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (17, 5, 5, '알뜰 여행', 'opt5_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (18, 5, 5, '가성비 우선', 'opt5_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (19, 5, 5, '예산보다 만족도', 'opt5_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (20, 5, 5, '예산 제한 없는 플렉스', 'opt5_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (21, 6, 6, '혼자(혼행)', 'opt6_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (22, 6, 6, '연인 · 커플', 'opt6_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (23, 6, 6, '가족', 'opt6_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (24, 6, 6, '친구 · 지인', 'opt6_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (25, 7, 7, '미식 · 맛집 탐방', 'opt7_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (26, 7, 7, '현지 음식 위주', 'opt7_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (27, 7, 7, '간편식 · 편의점', 'opt7_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (28, 7, 7, '해산물 · 고기 특화', 'opt7_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (29, 8, 8, '완전한 힐링 · 휴식', 'opt8_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (30, 8, 8, '액티비티 · 도전', 'opt8_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (31, 8, 8, '사진 · 감성', 'opt8_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (32, 8, 8, '문화 · 역사 탐방', 'opt8_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (33, 9, 9, '숙소 근처에서만 머물기', 'opt9_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (34, 9, 9, '하루에 1~2곳만 천천히', 'opt9_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (35, 9, 9, '부지런히 여러 곳 찍기', 'opt9_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (36, 9, 9, '아침부터 밤까지 꽉찬 일정', 'opt9_4.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (37, 10, 10, '사람 북적이는 핫플레이스', 'opt10_1.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (38, 10, 10, '한적하고 조용한 숨은 명소', 'opt10_2.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (39, 10, 10, '계절감이 뚜렷한 곳', 'opt10_3.jpg');
INSERT INTO Qusetion_options (option_id, question_number, question_no, option_text, option_img) VALUES (40, 10, 10, '야경이 예쁜 밤 중심', 'opt10_4.jpg');

-- PLACE 결과 매핑
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 1, '자연 속 탐험가');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 2, '바다의 낭만가');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 4, '도시의 산책가');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 8, '전원 속 사색가');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 3, '산과 바다를 누비는 자유로운 영혼');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 5, '도심 속 숲을 찾는 어반 테라피스트');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 9, '고요한 숲과 들판을 사랑하는 자연인');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 6, '화려한 야경과 해변을 즐기는 시티러버');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 10, '파도 소리와 시골의 정취를 찾는 여행자');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 12, '세련된 일상과 소박한 휴식을 오가는 산책자');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 7, '어디든 떠날 준비가 된 올라운드 여행가');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 11, '문명보다 풍경에 진심인 풍경 수집가');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 13, '발길 닿는 곳마다 쉼표를 찍는 프로 여행러');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 14, '낭만과 활기, 여유를 모두 놓치지 않는 욕심쟁이');
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLACE', 15, '세상의 모든 길을 사랑하는 진정한 방랑자');

-- 나머지 ENERGY, PLAN 데이터도 동일한 방식으로 WEIGHT 합계를 넣어 INSERT 하시면 됩니다.

-- ENERGY 결과 매핑
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 1, '정적인 무드로'); -- LOW
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 2, '여유를 즐기며'); -- NORMAL
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 4, '생기 가득하게'); -- HIGH
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 8, '에너지 넘치게'); -- MAX
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 3, '아주 차분하고 여유롭게'); -- LOW + NORMAL
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 12, '지칠 줄 모르는 에너지가 가득하게'); -- HIGH + MAX
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 5, '쉼과 활기 사이의 밸런스를 찾으며'); -- HIGH + LOW (제공 데이터 기준)
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('ENERGY', 0, '다채로운 텐션으로 반전 매력을 뽐내며'); -- 기타 조합 (0은 예시이며, 실제 구현시 기타 조합의 합계를 넣으세요)

-- PLAN 결과 매핑
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 1, '철저히 대비하는'); -- STRICT
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 2, '적당히 느낌대로'); -- SPOT
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 4, '오직 자유를 만끽하는'); -- IMPROMPTU
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 8, '든든한 가이드에 몸을 맡기는'); -- DEPENDENT
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 3, '꼼꼼하면서도 유연하게'); -- SPOT + STRICT
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 12, '흘러가는 대로 운명에 맡기는'); -- DEPENDENT + IMPROMPTU
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 5, '계획과 번개 사이를 즐기는'); -- IMPROMPTU + STRICT (제공 데이터 기준)
INSERT INTO TRAVEL_RESULT_MAPPING VALUES ('PLAN', 0, '상황에 따라 완벽하게 적응하는'); -- 기타 조합

-- PLACE 가중치 정의
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLACE', 'NATURE', 1);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLACE', 'SEA', 2);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLACE', 'CITY', 4);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLACE', 'RURAL', 8);

-- ENERGY 가중치 정의
INSERT INTO TAG_WEIGHT_MASTER VALUES ('ENERGY', 'LOW_ENERGY', 1);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('ENERGY', 'NORMAL_ENERGY', 2);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('ENERGY', 'HIGH_ENERGY', 4);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('ENERGY', 'MAX_ENERGY', 8);

-- PLAN 가중치 정의
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLAN', 'STRICT_PLAN', 1);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLAN', 'SPOT_PLAN', 2);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLAN', 'IMPROMPTU', 4);
INSERT INTO TAG_WEIGHT_MASTER VALUES ('PLAN', 'DEPENDENT', 8);

-- 1. FAQ 테이블 생성
CREATE TABLE faq (
    faq_no      NUMBER PRIMARY KEY,          -- 고유 번호
    category    VARCHAR2(50) NOT NULL,       -- 카테고리
    question    VARCHAR2(500) NOT NULL,      -- 질문
    answer      CLOB NOT NULL,               -- 답변 (긴 텍스트를 위해 CLOB 사용)
    order_no    NUMBER DEFAULT 0,            -- 노출 순서
    created_at  DATE DEFAULT SYSDATE,
    updated_at  DATE DEFAULT SYSDATE
);

-- 2. 자동 증가 시퀀스 생성
CREATE SEQUENCE faq_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- 3. INSERT 시 faq_no 자동 증가 트리거 생성
CREATE OR REPLACE TRIGGER trg_faq_no
BEFORE INSERT ON faq
FOR EACH ROW
BEGIN
    SELECT faq_seq.NEXTVAL INTO :new.faq_no FROM DUAL;
END;
/

-- 자주 묻는 질문(테이블) : 기본값
-- 1. 카테고리: 서비스 이용
INSERT INTO faq (category, question, answer, order_no)
VALUES ('서비스 이용', '#Trip은 어떤 서비스인가요?', ' #Trip은 사용자의 여행 취향을 분석하여 최적의 여행지와 코스를 제안하는 취향 기반 여행 분석 플랫폼입니다. 간단한 테스트를 통해 나만의 여행 스타일을 확인해 보세요!', 1);

-- 2. 카테고리: 분석 결과
INSERT INTO faq (category, question, answer, order_no)
VALUES ('분석 결과', '여행 성향 결과는 어디서 다시 볼 수 있나요?', '로그인 후 ''마이페이지 > 나의 분석 이력'' 메뉴에서 언제든지 과거에 진행했던 성향 테스트 결과를 다시 확인하고 비교해 보실 수 있습니다.', 2);

-- 3. 카테고리: 계정
INSERT INTO faq (category, question, answer, order_no)
VALUES ('계정', '회원 탈퇴는 어떻게 하나요?', '''마이페이지 > 회원 정보 수정'' 하단의 ''회원 탈퇴'' 버튼을 통해 진행하실 수 있습니다. 탈퇴 시 기존의 분석 데이터는 모두 삭제되며 복구가 불가능하니 유의해 주세요.', 3);

-- 4. 카테고리: 위치 정보
INSERT INTO faq (category, question, answer, order_no)
VALUES ('위치 정보', '위치 정보 권한이 꼭 필요한가요?', '필수는 아니지만, 위치 권한을 허용하시면 현재 계신 곳을 중심으로 실시간 주변 여행지 및 맛집 추천 서비스를 더욱 정확하게 받아보실 수 있습니다.', 4);

-- 데이터 확정
COMMIT;

-- 공지사항 테이블 생성
CREATE TABLE notice (
    notice_no   NUMBER PRIMARY KEY,          -- 공지사항 고유 번호
    title       VARCHAR2(200) NOT NULL,      -- 제목
    content     CLOB NOT NULL,               -- 내용 (긴 텍스트 처리를 위해 CLOB 사용)
    view_count  NUMBER DEFAULT 0,            -- 조회수
    created_at  DATE DEFAULT SYSDATE,        -- 작성일
    updated_at  DATE DEFAULT SYSDATE         -- 수정일
);

CREATE SEQUENCE notice_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
    
CREATE OR REPLACE TRIGGER trg_notice_no
BEFORE INSERT ON notice
FOR EACH ROW
BEGIN
    SELECT notice_seq.NEXTVAL INTO :new.notice_no FROM DUAL;
END;
/

-- 1. 신규 여행 성향 테스트 질문 업데이트
INSERT INTO notice (title, content)
VALUES ('신규 여행 성향 테스트 질문 업데이트', '안녕하세요. #Trip 팀입니다. <br><br> 겨울 시즌을 맞아 새로운 성향 분석 알고리즘이 업데이트되었습니다. 더욱 정교해진 질문들로 나만의 겨울 여행지를 찾아보세요!');

-- 2. 시스템 점검 작업 안내
INSERT INTO notice (title, content)
VALUES ('시스템 점검 작업 안내 (01월 05일 02:00 ~ 04:00)', '안정적인 서비스 제공을 위해 서버 점검이 진행될 예정입니다.<br> 해당 시간에는 서비스 접속이 원활하지 않을 수 있으니 양해 부탁드립니다.');

-- 3. ☀️ 2026 새해 맞이
INSERT INTO notice (title, content)
VALUES ('☀️ 2026 새해 맞이, #Trip과 함께하는 새로운 여정', '안녕하세요, <strong>#Trip</strong>입니다. 어느덧 새로운 한 해가 밝았습니다! <br><br> 새해를 맞아 본인의 여행 취향을 다시 한번 점검해 보실 수 있도록 <strong>''신년 맞이 성향 분석 알고리즘''</strong>을 정교하게 업데이트했습니다.<br> 올 한 해, 여러분의 발길이 닿는 곳마다 행복이 가득하기를 #Trip이 응원하겠습니다.<br><br> 지금 바로 새로워진 질문들로 2026년 첫 여행지를 발견해 보세요!');


COMMIT;
