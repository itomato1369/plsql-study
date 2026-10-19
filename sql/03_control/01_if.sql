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
BEGIN
    SELECT
        employee_id,
        last_name,
        salary
    INTO
        v_eno,
        v_enmae,
        v_salary
    FROM
        employees
    WHERE
        employee_id = &id;

    --IF salary <= 5000 THEN


    DBMS_OUTPUT.PUT_LINE('名前 =' || v_ename);
    DBMS_OUTPUT.PUT_LINE('昇給 = ' || v_salary);


END;
/