-- USERS profile image migration (path -> blob-ready)
-- Safe to run on existing schema. Each block adds one column only when missing.

DECLARE
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(1)
      INTO v_count
      FROM USER_TAB_COLUMNS
     WHERE TABLE_NAME = 'USERS'
       AND COLUMN_NAME = 'USER_PROFILE_BLOB';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE USERS ADD (USER_PROFILE_BLOB BLOB)';
    END IF;
END;
/

DECLARE
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(1)
      INTO v_count
      FROM USER_TAB_COLUMNS
     WHERE TABLE_NAME = 'USERS'
       AND COLUMN_NAME = 'USER_PROFILE_MIME_TYPE';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE USERS ADD (USER_PROFILE_MIME_TYPE VARCHAR2(100))';
    END IF;
END;
/

DECLARE
    v_count NUMBER := 0;
BEGIN
    SELECT COUNT(1)
      INTO v_count
      FROM USER_TAB_COLUMNS
     WHERE TABLE_NAME = 'USERS'
       AND COLUMN_NAME = 'USER_PROFILE_FILE_NAME';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLE USERS ADD (USER_PROFILE_FILE_NAME VARCHAR2(255))';
    END IF;
END;
/
