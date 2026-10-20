-- ------------------------------------------------------------
-- 制御 (IF/ELSEIF文)
-- 条件の比較には = を使う(代入の := と混同しない)
-- 文字列の比較は、大文字と小文字を区別する
-- 入力値(&変数)は、実行時に値を入力する置換変数（ちかんへんすう）
-- ------------------------------------------------------------
-- 社員番号を入力したら、
-- 名前、給与、昇給後の給与が出力される
-- 現在の給与が 5,000以下 = 20%昇給
-- 現在の給与が 10,000以下 = 15%昇給
-- 現在の給与が 15,000以下 = 10%昇給
-- 現在の給与が 15,001以上 変化なし
DECLARE
    v_eno employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    v_change employees.salary%TYPE;
BEGIN
    SELECT
        employee_id,
        last_name,
        salary
    INTO
        v_eno,
        v_ename,
        v_salary
    FROM
        employees
    WHERE
        employee_id = &id;

    IF v_salary <= 5000 THEN
        v_change := v_salary + (v_salary * 0.2);
    ELSIF v_salary <= 10000 THEN
        v_change := v_salary + (v_salary * 0.15);
    ELSIF v_salary <= 15000 THEN
        v_change := v_salary + (v_salary * 0.1);
    ELSE
        v_change := v_salary;
    END IF;

    DBMS_OUTPUT.PUT_LINE('名前 =' || v_ename);
    DBMS_OUTPUT.PUT_LINE('元の給料 =' || v_salary);
    DBMS_OUTPUT.PUT_LINE('昇給 = ' || TO_CHAR(v_change, 'FM999,999,990'));

END;
/
    -- SQL%NOTFOUND（BOOLEAN型）
    -- 直前のSQL文で1行も対象にならなかったら場合 TRUE
    -- 1行以上あれば FALSE
    -- IF SQL%NOTFOUND THEN
    --     DBMS_OUTPUT.PUT_LINE('該当する値がいません');
    -- END IF;

    -- SQL%ROWCOUNT（NUMBER型）
    -- 直前のSQL文で処理された行数を返します。0件なら0
    -- 行数そのものが必要なとき
    -- IF SQL%ROWCOUNT = 0 THEN
    --     DBMS_OUTPUT.PUT_LINE('該当する値がいません');
    -- END IF;
DECLARE
    v_id employees.employee_id%TYPE := &id; -- リテラル入力
    v_cnt NUMBER;
    v_eno employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT COUNT(*)
    INTO v_cnt
    FROM employees
    WHERE employee_id = v_id;

    IF v_cnt = 0 THEN
        DBMS_OUTPUT.PUT_LINE('該当する社員がいません');
    ELSE
        SELECT
            employee_id,
            last_name
        INTO
            v_eno,
            v_ename
        FROM
            employees
        WHERE
            employee_id = v_id;

        DBMS_OUTPUT.PUT_LINE('社員番号 = ' || v_eno);
        DBMS_OUTPUT.PUT_LINE('該当する値がいません = ' || v_ename);
    END IF;
END;
/