-- ==============================
-- FULL RESET (DROP ALL)
-- ==============================
-- Run this section first when you want a clean rebuild.

BEGIN
FOR t IN (
SELECT table_name
FROM user_tables
WHERE table_name IN (
PHOTO_DATA',
PLACE_REVIEW',
COMMUNITY',
TRAVEL_LOGS',
PLAN_DETAILS',
WISHLIST',
CATEGORY',
TRAVEL_PLANS',
TRAVEL_STYLES',
PLACE_TAG_MAP',
USER_TAG_MAP',
QUSETION_OPTIONS',
QUESTIONS',
PLACE',
TAG_MASTER',
QUESTIONS_CATEGORIES',
COMMON_CODE',
CODE_GROUP',
USER_ADDRESS',
USER_AUTHENTICATION',
USERS'
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
SEQ_QUESTION_CAT_NO',
SEQ_PLACE_NO',
SEQ_QUESTION_NUM',
SEQ_OPTION_ID',
SEQ_USER_TAG_MAP_NO',
SEQ_PLACE_TAG_MAP_NO',
SEQ_STYLE_USER_NO',
SEQ_PLAN_NO',
SEQ_PLAN_DETAIL_NO',
SEQ_LOG_NO',
SEQ_COMMENT_NO',
SEQ_COMMUNITY_REVIEW_NO',
SEQ_PHOTO_NO',
SEQ_CATEGORY_NO',
SEQ_WISH_NO',
SEQ_USER_NO',
SEQ_USER_AUTH_NO',
SEQ_USER_ADDRESS_NO'
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
user_gender CHAR(1) CHECK (user_gender IN ('M', 'F')), -- ????援щ텇 ?덉떆
user_phoneNumber VARCHAR2(50),
user_registration_no VARCHAR2(100),
user_nickName VARCHAR2(20),
user_profile_img VARCHAR2(255)
);

COMMENT ON COLUMN Users.user_status IS 'A:?쒖꽦, S:?대㈃, W:?덊눜';

CREATE TABLE User_Authentication (
user_auth_no NUMBER(19) PRIMARY KEY,
user_no NUMBER(19) NOT NULL,
user_auth_id VARCHAR2(100) UNIQUE, -- ID 以묐났 諛⑹?
user_auth_pw VARCHAR2(255),
user_auth_email VARCHAR2(100),
user_auth_sns_type VARCHAR2(20), -- ENUM ???VARCHAR濡?泥섎━ (Oracle 湲곗?)
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

-- 1. 怨듯넻 肄붾뱶 洹몃９
CREATE TABLE code_group (
group_code VARCHAR2(20) PRIMARY KEY,
group_name VARCHAR2(50),
is_used CHAR(1) CHECK (is_used IN ('Y', 'N'))
);

-- 2. ?몃? 怨듯넻 肄붾뱶
CREATE TABLE Common_Code (
common_code VARCHAR2(20) PRIMARY KEY,
group_code VARCHAR2(20),
code_name VARCHAR2(50),
output_sort_order NUMBER(1),
is_used CHAR(1) CHECK (is_used IN ('Y', 'N')),
CONSTRAINT fk_common_group FOREIGN KEY (group_code) REFERENCES code_group(group_code)
);

-- 3. ?쒓렇 留덉뒪??(?ы뻾吏 諛??깊뼢 遺꾩꽍??
CREATE TABLE Tag_Master (
tag_code VARCHAR2(50) PRIMARY KEY,
tag_name VARCHAR2(100) NOT NULL,
tag_category VARCHAR2(20)
);

-- 4. 吏덈Ц 移댄뀒怨좊━
CREATE TABLE Questions_categories (
question_no NUMBER(1) PRIMARY KEY,
question_name VARCHAR2(10)
);

-- 5. ?μ냼 留덉뒪???곗씠??
CREATE TABLE Place (
place_no NUMBER(19) PRIMARY KEY,
place_name VARCHAR2(200 CHAR) NOT NULL,
place_category VARCHAR2(50) NOT NULL,
place_address VARCHAR2(500 CHAR),
place_latitude NUMBER(12, 8),
place_longitude NUMBER(13, 8),
place_rating NUMBER(3, 2),
place_number VARCHAR2(255 CHAR),
place_thumbnail_url VARCHAR2(1000 CHAR)
);

-- 6. 吏덈Ц ?곸꽭 諛??좏깮吏
CREATE TABLE Questions (
question_number NUMBER(1) PRIMARY KEY,
question_no NUMBER(1),
question_content VARCHAR2(2000) NOT NULL,
question_img VARCHAR2(1000) NOT NULL,
CONSTRAINT fk_q_category FOREIGN KEY (question_no) REFERENCES Questions_categories(question_no)
);

CREATE TABLE Qusetion_options (
option_id NUMBER(19) PRIMARY KEY,
question_number NUMBER(1),
question_no NUMBER(1),
option_text VARCHAR2(500) NOT NULL,
option_img VARCHAR2(1000) NOT NULL,
CONSTRAINT fk_opt_q_num FOREIGN KEY (question_number) REFERENCES Questions(question_number)
);

-- 7. ?ъ슜?먮퀎 ?깊뼢 ?쒓렇 留ㅽ븨 (Users 李몄“)
CREATE TABLE User_Tag_Map (
mapping_no NUMBER PRIMARY KEY,
user_no NUMBER(19), -- FK
question_id VARCHAR2(10),
tag_code VARCHAR2(50), -- FK
CONSTRAINT fk_utag_user FOREIGN KEY (user_no) REFERENCES Users(user_no),
CONSTRAINT fk_utag_tag FOREIGN KEY (tag_code) REFERENCES Tag_Master(tag_code)
);

-- 8. ?μ냼 ?쒓렇 留ㅽ븨
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

-- 9. ?ы뻾 ?깊뼢 遺꾩꽍 寃곌낵 (Users 李몄“)
CREATE TABLE Travel_Styles (
style_user_no NUMBER(19) PRIMARY KEY,
user_no NUMBER(19), -- ??낆쓣 NUMBER(19)濡??쇱튂?쒗궡
travel_is_analyzde CHAR(1) CHECK (travel_is_analyzde IN ('Y', 'N')),
travel_analyzed_date DATE,
travel_type_name VARCHAR2(50),
CONSTRAINT fk_style_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 10. ?ы뻾 ?쇱젙 留덉뒪??諛??곸꽭
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
user_no NUMBER(19), -- 湲곗〈 VARCHAR2(100)?먯꽌 蹂寃?
plan_visit_order NUMBER(5),
plan_meno VARCHAR2(1000),
detail_start_date DATE,
detail_end_date DATE,
CONSTRAINT fk_pdet_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no),
CONSTRAINT fk_pdet_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
CONSTRAINT fk_pdet_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 11. ?ы뻾 濡쒓렇 諛??ъ쭊 (Review ?ы븿)
CREATE TABLE Travel_Logs (
log_no NUMBER(19) PRIMARY KEY,
plan_no NUMBER(19),
place_no NUMBER(19),
user_no NUMBER(19),
review_content VARCHAR2(4000),
log_rating NUMBER(5),
CONSTRAINT fk_log_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no),
CONSTRAINT fk_log_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
CONSTRAINT fk_log_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

CREATE TABLE Place_Review (
comment_no NUMBER(19) PRIMARY KEY,
log_no NUMBER(19),
place_no NUMBER(19),
review_content VARCHAR2(2000),
created_by VARCHAR2(100), -- user_no ?먮뒗 nickName 湲곕줉
created_at DATE DEFAULT SYSDATE,
CONSTRAINT fk_rev_log FOREIGN KEY (log_no) REFERENCES Travel_Logs(log_no),
CONSTRAINT fk_rev_place FOREIGN KEY (place_no) REFERENCES Place(place_no)
);

CREATE TABLE Community (
review_no NUMBER(19) PRIMARY KEY,
plan_no NUMBER(19) NOT NULL,
user_no NUMBER(19) NOT NULL,
review_content VARCHAR2(2000),
review_rating NUMBER(1),
CONSTRAINT fk_community_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no),
CONSTRAINT fk_community_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

CREATE TABLE photo_data (
photo_no NUMBER(19) PRIMARY KEY,
comment_no NUMBER(19),
log_photo_url VARCHAR2(1000),
CONSTRAINT fk_photo_comment FOREIGN KEY (comment_no) REFERENCES Place_Review(comment_no)
);

-- 12. ?ъ슜?먯쓽 李?移댄뀒怨좊━ 愿由?
CREATE TABLE Category (
category_no NUMBER(19) PRIMARY KEY,
user_no NUMBER(19),
category_type VARCHAR2(100),
category_is_used CHAR(1) CHECK (category_is_used IN ('Y', 'N')),
CONSTRAINT fk_cat_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 13. 李?紐⑸줉 (?μ냼-移댄뀒怨좊━-?ъ슜???곌껐)
CREATE TABLE wishlist (
wish_no NUMBER(19) PRIMARY KEY,
place_no NUMBER(19),
category_no NUMBER(19),
user_no NUMBER(19),
wish_date DATE DEFAULT SYSDATE,
CONSTRAINT fk_wish_place FOREIGN KEY (place_no) REFERENCES Place(place_no),
CONSTRAINT fk_wish_cat FOREIGN KEY (category_no) REFERENCES Category(category_no),
CONSTRAINT fk_wish_user FOREIGN KEY (user_no) REFERENCES Users(user_no)
);

-- 14. 猷⑦듃 醫뗭븘??(?좎?蹂?以묐났 諛⑹?)
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE PLAN_LIKES CASCADE CONSTRAINTS PURGE';
EXCEPTION
	WHEN OTHERS THEN
		IF SQLCODE != -942 THEN
			RAISE;
		END IF;
END;
/

CREATE TABLE Plan_Likes (
plan_no NUMBER(19) NOT NULL,
user_no NUMBER(19) NOT NULL,
liked_at DATE DEFAULT SYSDATE NOT NULL,
CONSTRAINT pk_plan_likes PRIMARY KEY (plan_no, user_no),
CONSTRAINT fk_plike_plan FOREIGN KEY (plan_no) REFERENCES Travel_Plans(plan_no) ON DELETE CASCADE,
CONSTRAINT fk_plike_user FOREIGN KEY (user_no) REFERENCES Users(user_no) ON DELETE CASCADE
);

CREATE INDEX IDX_PLAN_LIKES_PLAN_NO ON Plan_Likes(plan_no);

-- 吏덈Ц 移댄뀒怨좊━ ?쒗??
CREATE SEQUENCE SEQ_QUESTION_CAT_NO START WITH 1 INCREMENT BY 1;

-- ?쒓렇 留덉뒪?곕뒗 肄붾뱶瑜?吏곸젒 ?낅젰?섎뒗 寃쎌슦媛 留롮?留? ?꾩슂???ъ슜
-- CREATE SEQUENCE SEQ_TAG_CODE START WITH 1 INCREMENT BY 1;

-- ?μ냼 怨좎쑀 踰덊샇 ?쒗??
CREATE SEQUENCE SEQ_PLACE_NO START WITH 1 INCREMENT BY 1;

-- 吏덈Ц 諛??듭뀡 踰덊샇 ?쒗??
CREATE SEQUENCE SEQ_QUESTION_NUM START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_OPTION_ID START WITH 1 INCREMENT BY 1;

-- ?ъ슜???쒓렇 留ㅽ븨 踰덊샇 ?쒗??
CREATE SEQUENCE SEQ_USER_TAG_MAP_NO START WITH 1 INCREMENT BY 1;

-- ?μ냼-?쒓렇 留ㅽ븨 踰덊샇 ?쒗??
CREATE SEQUENCE SEQ_PLACE_TAG_MAP_NO START WITH 1 INCREMENT BY 1;

-- ?ы뻾 ?깊뼢 遺꾩꽍 寃곌낵 踰덊샇 ?쒗??
CREATE SEQUENCE SEQ_STYLE_USER_NO START WITH 1 INCREMENT BY 1;

-- ?ы뻾 ?쇱젙 留덉뒪??諛??곸꽭 ?쒗??
CREATE SEQUENCE SEQ_PLAN_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PLAN_DETAIL_NO START WITH 1 INCREMENT BY 1;

-- ?ы뻾 濡쒓렇 諛?由щ럭 ?쒗??
CREATE SEQUENCE SEQ_LOG_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_COMMENT_NO START WITH 1 INCREMENT BY 1;

-- ?ъ쭊 ?곗씠??怨좎쑀 踰덊샇 ?쒗??
CREATE SEQUENCE SEQ_COMMUNITY_REVIEW_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PHOTO_NO START WITH 1 INCREMENT BY 1;

-- 李?移댄뀒怨좊━ 諛?李?紐⑸줉 ?쒗??
CREATE SEQUENCE SEQ_CATEGORY_NO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_WISH_NO START WITH 1 INCREMENT BY 1;

-- Users ?뚯씠釉붿슜 ?쒗??
CREATE SEQUENCE SEQ_USER_NO
START WITH 1
INCREMENT BY 1
NOCACHE;

-- User_Authentication ?뚯씠釉붿슜 ?쒗??
CREATE SEQUENCE SEQ_USER_AUTH_NO
START WITH 1
INCREMENT BY 1
NOCACHE;

-- User_Address ?뚯씠釉붿슜 ?쒗??
CREATE SEQUENCE SEQ_USER_ADDRESS_NO
START WITH 1
INCREMENT BY 1
NOCACHE;

-- 議고쉶?깅뒫???믪씠湲??꾪븳 ?몃뜳???닿구 ?섎㈃ ?먮룞?쇰줈 ?ㅻ씪?댁씠 鍮⑤━ 議고쉶 ?좎닔 ?덉쓬 臾쇰줎 PLACE_TAG_MAP?뚯씠釉붿쓣 ?뚭렇 肄붾뱶? ?뚮젅?댁뒪踰덊샇濡?議고쉶?덉쓣??,,
CREATE INDEX IDX_PLACE_TAG_MAP_TAG_CODE ON PLACE_TAG_MAP(TAG_CODE);
CREATE INDEX IDX_PLACE_TAG_MAP_PLACE_NO ON PLACE_TAG_MAP(PLACE_NO);

