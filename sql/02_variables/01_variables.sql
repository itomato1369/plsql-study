-- ------------------------------------------------------------
-- DECLARE で変数を宣言する
-- 変数は「:=」で値を代入します（= ではありません）。
-- 変数は DECLAREの中で宣言します
-- 宣言した変数は、BEGIN 以降の処理で使えます。
-- 初期値を入れない変数は、中身が NULL（空）になります
-- NOT NULL を付けると、必ず値を入れる必要があります（宣言時に初期値も必要）
-- CONSTANT を付けると、値を変えられない変数（定数）になります
-- カラム := &変数 はリテラル入力値
DECLARE 
    v_name VARCHAR2(20);
    v_score NUMBER;
BEGIN
    v_name := '山田';
    v_score := 85;
-- ------------------------------------------------------------
-- System.out.println(); console.log();での '+'が '||'です。
-- ------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE(v_name || v_score);
END;
/

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
-- ------------------------------------------------------------
-- できるだけSELECT文に '*'は使わないように、但し、COUNT(*)を除く
-- 現場では SELECT * FROM テーブル を控える
-- ------------------------------------------------------------
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

DECLARE
    v_a NUMBER := 10;
BEGIN
    DECLARE 
        v_b NUMBER := 20;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(v_a + v_b);
    END;
    -- DBMS_OUTPUT.PUT_LINE(v_b);
END;
/
-- ------------------------------------------------------------
-- 社員番号を入力し、
-- 社員番号、名前、部署名を出力する PL/SQL
-- ------------------------------------------------------------
DECLARE
    v_employee_id employees.employee_id%TYPE;
    v_last_name employees.last_name%TYPE;
    v_depmartment_name departments.department_name%TYPE;
BEGIN
    SELECT
        e.employee_id,
        e.last_name,
        d.department_name
    INTO
        v_employee_id,
        v_last_name,
        v_depmartment_name
    FROM
        employees e, departments d
    WHERE
        e.department_id = d.department_id
    AND
        e.employee_id = &id;
        -- &変数 はリテラル入力値

    DBMS_OUTPUT.PUT_LINE(v_employee_id || v_last_name || v_depmartment_name);
    END;
/
-- ------------------------------------------------------------
-- 社員番号を入力し、
-- 名前、給与、年収(給与 * 12 + (NVL(給与, 0) * NVL(賞与, 0) * 12))
-- 値がNULLである場合計算結果がNULLになるエラー発生
-- ------------------------------------------------------------
DECLARE
    v_empno employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_annual employees.salary%TYPE;
BEGIN
    SELECT
        employee_id,
        last_name,
        NVL(salary, 0) * 12 + (NVL(salary, 0) * NVL(commission_pct, 0) * 12) AS annual_salary
    INTO
        v_empno,
        v_ename,
        v_annual
    FROM
        employees
    WHERE
        employee_id = &id;

    DBMS_OUTPUT.PUT_LINE('社員番号は = ' || v_empno);
    DBMS_OUTPUT.PUT_LINE('名前は = ' || v_ename);
    -- salaryはNUMBERですが、表示するだけだとエラーにならない
    DBMS_OUTPUT.PUT_LINE('年収は = ' || TO_CHAR(v_annual, 'FM999,999,990') || '円');

END;
/
-- ------------------------------------------------------------
-- 社員番号を入力し、
-- 入社日が2000年以降であれば 'NEW employee'
-- 2000年以前であれば 'Carrer employee'を出力
-- ------------------------------------------------------------
DECLARE
    v_empno employees.employee_id%TYPE;
    v_state VARCHAR2(20); -- 
BEGIN
    SELECT
        employee_id,
        CASE
            WHEN hire_date >= DATE '2000-01-01' THEN 'New employee'
            ELSE 'Career employee'
        END
    INTO
        v_empno,
        v_state
    FROM
        employees
    WHERE
        employee_id = &id;

    DBMS_OUTPUT.PUT_LINE('社員番号は = ' || v_empno);
    DBMS_OUTPUT.PUT_LINE('区分 = ' || v_state);

END;
/