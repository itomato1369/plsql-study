-- ------------------------------------------------------------
-- 制御 (LOOP文)
-- FOR i IN 1...10 LOOP 回数が決まっている処理
-- WHILE 条件 LOOP 条件で回数が変わる処理
-- LOOP EXIT WHEN 条件で終了 
-- LOOP文は最低1回は実行させる必要がある
-- ------------------------------------------------------------
-- 1から10までの和をもとめる
DECLARE
    v_sum NUMBER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        v_sum := v_sum + i;
        DBMS_OUTPUT.PUT_LINE(i || ' + ' || v_sum);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('総 = ' || v_sum);
END;
/
-- *ピラミッドを出力
DECLARE
    v_star VARCAR2(20) := '*';
BEGIN
    FOR i IN 1..5 LOOP
        v_star := '*';
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

END;
/

