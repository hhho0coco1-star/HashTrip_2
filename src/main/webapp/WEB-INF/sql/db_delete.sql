-- hifive schema reset script
-- Safe to rerun: missing objects are ignored.
-- Table drops remove dependent indexes automatically.
DECLARE
    PROCEDURE drop_trigger_if_exists(p_trigger_name IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE 'DROP TRIGGER ' || p_trigger_name;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -4080 THEN
                RAISE;
            END IF;
    END;

    PROCEDURE drop_table_if_exists(p_table_name IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || p_table_name || ' CASCADE CONSTRAINTS PURGE';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                RAISE;
            END IF;
    END;

    PROCEDURE drop_sequence_if_exists(p_sequence_name IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || p_sequence_name;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN
                RAISE;
            END IF;
    END;
BEGIN
    -- Triggers
    drop_trigger_if_exists('TRG_FAQ_NO');
    drop_trigger_if_exists('TRG_NOTICE_NO');

    -- Child tables first
    drop_table_if_exists('PHOTO_DATA');
    drop_table_if_exists('PLACE_REVIEW');
    drop_table_if_exists('COMMUNITY');
    drop_table_if_exists('TRAVEL_LOGS');
    drop_table_if_exists('PLAN_DETAILS');
    drop_table_if_exists('ROUTE_SAVE_HISTORY');
    drop_table_if_exists('WISHLIST');
    drop_table_if_exists('PLACE_HOURS');
    drop_table_if_exists('PLACE_TAG_MAP');
    drop_table_if_exists('USER_TAG_MAP');
    drop_table_if_exists('TRAVEL_STYLES');
    drop_table_if_exists('PLACE_INQUIRY');
    drop_table_if_exists('QUSETION_OPTIONS');
    drop_table_if_exists('QUESTIONS');
    drop_table_if_exists('COMMON_CODE');
    drop_table_if_exists('USER_AUTHENTICATION');
    drop_table_if_exists('USER_ADDRESS');

    -- Parent and standalone tables
    drop_table_if_exists('TRAVEL_PLANS');
    drop_table_if_exists('CATEGORY');
    drop_table_if_exists('PLACE');
    drop_table_if_exists('TAG_MASTER');
    drop_table_if_exists('QUESTIONS_CATEGORIES');
    drop_table_if_exists('CODE_GROUP');
    drop_table_if_exists('TAG_WEIGHT_MASTER');
    drop_table_if_exists('TRAVEL_RESULT_MAPPING');
    drop_table_if_exists('FAQ');
    drop_table_if_exists('NOTICE');
    drop_table_if_exists('USERS');

    -- Sequences
    drop_sequence_if_exists('SEQ_QUESTION_CAT_NO');
    drop_sequence_if_exists('SEQ_PLACE_NO');
    drop_sequence_if_exists('SEQ_QUESTION_NUM');
    drop_sequence_if_exists('SEQ_OPTION_ID');
    drop_sequence_if_exists('SEQ_HOURS_ID');
    drop_sequence_if_exists('SEQ_USER_TAG_MAP_NO');
    drop_sequence_if_exists('SEQ_PLACE_TAG_MAP_NO');
    drop_sequence_if_exists('SEQ_STYLE_USER_NO');
    drop_sequence_if_exists('SEQ_PLAN_NO');
    drop_sequence_if_exists('SEQ_PLAN_DETAIL_NO');
    drop_sequence_if_exists('SEQ_ROUTE_SAVE_NO');
    drop_sequence_if_exists('SEQ_LOG_NO');
    drop_sequence_if_exists('SEQ_COMMENT_NO');
    drop_sequence_if_exists('SEQ_COMMUNITY_REVIEW_NO');
    drop_sequence_if_exists('SEQ_PHOTO_NO');
    drop_sequence_if_exists('SEQ_CATEGORY_NO');
    drop_sequence_if_exists('SEQ_WISH_NO');
    drop_sequence_if_exists('SEQ_USER_NO');
    drop_sequence_if_exists('SEQ_USER_AUTH_NO');
    drop_sequence_if_exists('SEQ_USER_ADDRESS_NO');
    drop_sequence_if_exists('SEQ_INQUIRY_NO');
    drop_sequence_if_exists('SEQ_TRAVEL_STYLE');
    drop_sequence_if_exists('FAQ_SEQ');
    drop_sequence_if_exists('NOTICE_SEQ');
END;
/
