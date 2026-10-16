-- ------------------------------------------------------------
-- DECLARE で変数を宣言する
-- ------------------------------------------------------------
-- 変数は「:=」で値を代入します（= ではありません）。
-- 変数は DECLAREの中で宣言します
-- 宣言した変数は、BEGIN 以降の処理で使えます。
-- 初期値を入れない変数は、中身が NULL（空）になります
-- NOT NULL を付けると、必ず値を入れる必要があります（宣言時に初期値も必要）
-- CONSTANT を付けると、値を変えられない変数（定数）になります
DECLARE 
    v_name VARCHAR2(20);
    v_score NUMBER;
BEGIN
    v_name := '山田';
    v_score := 85;
    DBMS_OUTPUT.PUT_LINE(v_name || v_score);
END;
/
-- System.out.println(); console.log(); '+'が '||'です。
DECLARE
    v_count NUMBER := 0;
    v_title VARCHAR2(30);
BEGIN
    v_count := v_count + 5;
    v_title := 'Hello';
    DBMS_OUTPUT.PUT_LINE(v_count || v_title);
END;
/

DECLARE
    v_tax CONSTANT NUMBER := 0.10;
    v_price NUMBER := 1000;
BEGIN
    v_price := v_price * v_tax;
    DBMS_OUTPUT.PUT_LINE(v_price);
END;
/
-- ------------------------------------------------------------
-- %TYPEで列の型をそのまま使うことをおすすめ
-- ------------------------------------------------------------
DECLARE
    v_dname departments.department_name%TYPE;
    v_did departments.department_id%TYPE;
BEGIN
    SELECT
        department_id,
        department_name
    INTO
        v_did,
        v_dname
    FROM
        departments
    WHERE
        department_id = 10;
    DBMS_OUTPUT.PUT_LINE(v_dname);
END;
/
-- できるだけSELECT文に '*'は使わないように
-- COUNT(*)を除く
-- 現場では SELECT * FROM テーブル を控える
DECLARE
    v_dept departments%ROWTYPE;
BEGIN
    SELECT
        department_id,
        department_name
    INTO
        v_dept.department_id,
        v_dept.department_name
    FROM
        departments
    WHERE
        department_id = 20;

    DBMS_OUTPUT.PUT_LINE(v_dept.department_name);
    DBMS_OUTPUT.PUT_LINE(v_dept.department_id);
END;
/