-- ------------------------------------------------------------
-- 制御 (LOOP文)
-- FOR i IN 1...10 LOOP = 回数が決まっている処理
-- WHILE 条件 LOOP = 条件で回数が変わる処理
-- LOOP EXIT WHEN 条件で終了 
-- LOOP文は最低1回は実行させる必要がある
-- 配列とLOOPはセット
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
-- ------------------------------------------------------------
-- * ピラミッドを出力
DECLARE
    v_star VARCHAR2(20);
BEGIN 
    FOR i IN 1..5 LOOP
        v_star := v_star||'*';
        DBMS_OUTPUT.PUT_LINE(v_star);
    END LOOP;

END;
/
-- ------------------------------------------------------------
-- 入力した数の九九
DECLARE
    v_num NUMBER(38) := &mtable;
BEGIN
    FOR i IN 1..9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_num || ' * ' || i || ' = ' || v_num * i); 
    END LOOP;
END;
/
-- ------------------------------------------------------------
-- 九九 2 ~ 9 LOOPの中のLOOP
BEGIN
    DBMS_OUTPUT.PUT_LINE('---九九---');
    
    FOR i IN 2..9 LOOP
        DBMS_OUTPUT.PUT_LINE('---------');
        DBMS_OUTPUT.PUT_LINE(i || '段');

        FOR j IN 1..9 LOOP
            DBMS_OUTPUT.PUT_LINE(i || ' * ' || j || ' = ' || (i * j));
        END LOOP;
    END LOOP;
END;
/
-- ------------------------------------------------------------
-- 偶数、奇数の九九
-- MOD(A, B) AをBに割り算する
BEGIN
    DBMS_OUTPUT.PUT_LINE('---九九---');
    
    FOR i IN 2..9 LOOP
        IF MOD(i, 2) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('---------');
            DBMS_OUTPUT.PUT_LINE(i || '段');

            FOR j IN 1..9 LOOP
                DBMS_OUTPUT.PUT_LINE(i || ' * ' || j || ' = ' || (i * j));
            END LOOP;
        END IF;
    END LOOP;
END;
/
-- ------------------------------------------------------------
-- 残高が目標に届くまでの年数を求める
DECLARE
    v_balance PLS_INTEGER := 1000; -- 初期残高
    v_target PLS_INTEGER := 2000; -- 目標額
    v_years PLS_INTEGER := 0;
BEGIN
    WHILE v_balance < v_target LOOP
        v_balance := v_balance + 300; -- 毎年300ずつ増える
        v_years := v_years + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('目標達成まで' || v_years || '年');
END;
/