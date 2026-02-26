-- ==============================
-- FULL RESET (DROP ALL)
-- ==============================
-- Run this section first when you want a clean rebuild.

BEGIN
    FOR t IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'PHOTO_DATA',
            'PLACE_REVIEW',
            'COMMUNITY',
            'TRAVEL_LOGS',
            'PLAN_DETAILS',
            'ROUTE_SAVE_HISTORY',
            'WISHLIST',
            'CATEGORY',
            'TRAVEL_PLANS',
            'TRAVEL_STYLES',
            'PLACE_TAG_MAP',
            'PLACE_HOURS',
            'USER_TAG_MAP',
            'QUSETION_OPTIONS',
            'QUESTIONS',
            'PLACE',
            'TAG_MASTER',
            'QUESTIONS_CATEGORIES',
            'COMMON_CODE',
            'CODE_GROUP',
            'USER_ADDRESS',
            'USER_AUTHENTICATION',
            'USERS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

BEGIN
    FOR s IN (
        SELECT sequence_name
        FROM user_sequences
        WHERE sequence_name IN (
            'SEQ_QUESTION_CAT_NO',
            'SEQ_PLACE_NO',
            'SEQ_QUESTION_NUM',
            'SEQ_OPTION_ID',
            'SEQ_USER_TAG_MAP_NO',
            'SEQ_PLACE_TAG_MAP_NO',
            'SEQ_HOURS_ID',
            'SEQ_STYLE_USER_NO',
            'SEQ_PLAN_NO',
            'SEQ_PLAN_DETAIL_NO',
            'SEQ_ROUTE_SAVE_NO',
            'SEQ_LOG_NO',
            'SEQ_COMMENT_NO',
            'SEQ_COMMUNITY_REVIEW_NO',
            'SEQ_PHOTO_NO',
            'SEQ_CATEGORY_NO',
            'SEQ_WISH_NO',
            'SEQ_USER_NO',
            'SEQ_USER_AUTH_NO',
            'SEQ_USER_ADDRESS_NO'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

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
    user_profile_img VARCHAR2(255)
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
    question_no NUMBER(1) PRIMARY KEY,
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
    question_number NUMBER(1) PRIMARY KEY,
    question_no NUMBER(3),
    question_content VARCHAR2(2000) NOT NULL,
    question_img VARCHAR2(1000) NOT NULL,
    CONSTRAINT fk_q_category FOREIGN KEY (question_no) REFERENCES Questions_categories(question_no)
);

CREATE TABLE Qusetion_options (
    option_id NUMBER(19) PRIMARY KEY,
    question_number NUMBER(3),
    question_no NUMBER(1),
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
    travel_type_name VARCHAR2(50),
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

-- 조회성능을 높이기 위한 인덱스 이걸 하면 자동으로 오라클이 빨리 조회 할수 있음 물론 PLACE_TAG_MAP테이블을 테그 코드와 플레이스번호로 조회했을떄,,,
CREATE INDEX IDX_PLACE_TAG_MAP_TAG_CODE ON PLACE_TAG_MAP(TAG_CODE);
CREATE INDEX IDX_PLACE_TAG_MAP_PLACE_NO ON PLACE_TAG_MAP(PLACE_NO);

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

-- 사용자 성향 분석 저장 테이블 컬럼 추가
ALTER TABLE Travel_Styles ADD (
    -- 사용자가 선택한 원본 코드들 (나중에 다시 분석할 때 필요)
    selected_place_codes   VARCHAR2(200), 
    selected_energy_codes  VARCHAR2(200),
    selected_plan_codes    VARCHAR2(200),
    -- 최종 조합된 문구 저장 (매번 로직을 돌리지 않기 위해 결과 저장)
    travel_final_summary   VARCHAR2(1000) 
);

-- 1. 성향 조합 마스터 테이블
CREATE TABLE TRAVEL_ANALYSIS_MASTER (
    ANALYSIS_ID NUMBER PRIMARY KEY,
    CATEGORY VARCHAR2(20) NOT NULL, -- PLACE, ENERGY, PLAN
    COMBINATION_KEY VARCHAR2(200) NOT NULL, -- 정렬된 코드 조합 (예: 'CODE1,CODE2')
    RESULT_TEXT VARCHAR2(500) NOT NULL
);

-- 단일 선택
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (1, 'PLACE', 'NATURE', '자연 속 탐험가');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (2, 'PLACE', 'SEA', '바다의 낭만가');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (3, 'PLACE', 'CITY', '도시의 산책가');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (4, 'PLACE', 'RURAL', '전원 속 사색가');

-- 2개 조합 (알파벳 순 정렬)
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (5, 'PLACE', 'NATURE,SEA', '산과 바다를 누비는 자유로운 영혼');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (6, 'PLACE', 'CITY,NATURE', '도심 속 숲을 찾는 어반 테라피스트');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (7, 'PLACE', 'NATURE,RURAL', '고요한 숲과 들판을 사랑하는 자연인');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (8, 'PLACE', 'CITY,SEA', '화려한 야경과 해변을 즐기는 시티러버');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (9, 'PLACE', 'RURAL,SEA', '파도 소리와 시골의 정취를 찾는 여행자');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (10, 'PLACE', 'CITY,RURAL', '세련된 일상과 소박한 휴식을 오가는 산책자');

-- 3개 이상 조합 및 전체 선택
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (11, 'PLACE', 'CITY,NATURE,SEA', '어디든 떠날 준비가 된 올라운드 여행가');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (12, 'PLACE', 'NATURE,RURAL,SEA', '문명보다 풍경에 진심인 풍경 수집가');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (13, 'PLACE', 'CITY,NATURE,RURAL', '발길 닿는 곳마다 쉼표를 찍는 프로 여행러');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (14, 'PLACE', 'CITY,RURAL,SEA', '낭만과 활기, 여유를 모두 놓치지 않는 욕심쟁이');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (15, 'PLACE', 'CITY,NATURE,RURAL,SEA', '세상의 모든 길을 사랑하는 진정한 방랑자');

-- 단일 선택
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (16, 'ENERGY', 'LOW_ENERGY', '정적인 무드로');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (17, 'ENERGY', 'NORMAL_ENERGY', '여유를 즐기며');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (18, 'ENERGY', 'HIGH_ENERGY', '생기 가득하게');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (19, 'ENERGY', 'MAX_ENERGY', '에너지 넘치게');

-- 조합 선택
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (20, 'ENERGY', 'LOW_ENERGY,NORMAL_ENERGY', '아주 차분하고 여유롭게');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (21, 'ENERGY', 'HIGH_ENERGY,MAX_ENERGY', '지칠 줄 모르는 에너지가 가득하게');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (22, 'ENERGY', 'HIGH_ENERGY,LOW_ENERGY', '쉼과 활기 사이의 밸런스를 찾으며');

-- 기타 (3개 이상 선택 시 로직에서 'ENERGY_ETC'로 치환한다고 가정)
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (23, 'ENERGY', 'ENERGY_ETC', '다채로운 텐션으로 반전 매력을 뽐내며');

-- 단일 선택
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (24, 'PLAN', 'STRICT_PLAN', '철저히 대비하여');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (25, 'PLAN', 'SPOT_PLAN', '적당히 느낌대로');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (26, 'PLAN', 'IMPROMPTU', '오직 자유를 만끽하며');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (27, 'PLAN', 'DEPENDENT', '든든한 가이드에 몸을 맡기고');

-- 조합 선택
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (28, 'PLAN', 'SPOT_PLAN,STRICT_PLAN', '꼼꼼하면서도 유연하게');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (29, 'PLAN', 'DEPENDENT,IMPROMPTU', '흘러가는 대로 운명에 맡기며');
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (30, 'PLAN', 'IMPROMPTU,STRICT_PLAN', '계획과 번개 사이를 즐기며');

-- 기타 (3개 이상 선택 시 로직에서 'PLAN_ETC'로 치환한다고 가정)
INSERT INTO TRAVEL_ANALYSIS_MASTER (ANALYSIS_ID, CATEGORY, COMBINATION_KEY, RESULT_TEXT) VALUES (31, 'PLAN', 'PLAN_ETC', '상황에 따라 완벽하게 적응하며');
