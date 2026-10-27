-- ============================================================
-- PL/SQLの例外処理
-- 事前に sql/01_basics/01_test_data.sql を実行してください。
-- SQL*Plus / SQLcl / VS CodeのOracle接続から実行できます。
-- 練習6・7は意図的に未処理例外を返すため、個別に実行してください。
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- 例外処理の基本
-- 例外が発生するとBEGIN内の残りの処理を中断し、
-- EXCEPTION節にある該当するハンドラへ制御が移ります。
-- ------------------------------------------------------------
DECLARE
  v_numerator   NUMBER := 10;
  v_denominator NUMBER := 0;
  v_result      NUMBER;
BEGIN
  v_result := v_numerator / v_denominator;
  DBMS_OUTPUT.PUT_LINE('計算結果=' || v_result);
  -- v_numeratorがピザでv_denominatorが人
  -- 10 ピースのピザを 0人が食べると 1人当たり食べられるピザは? = ありえない
  -- 0 ピースのピザを 10人が食べると 1人当たり食べられるピザは = 0
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('0では割り算できません');
END;
/
-- 出力: 0では割り算できません

-- ------------------------------------------------------------
-- 練習1：事前定義例外 NO_DATA_FOUND
-- SELECT ... INTO が0行の場合に発生します。
-- ------------------------------------------------------------
DECLARE
  v_last_name employees.last_name%TYPE;
BEGIN
  SELECT last_name
  INTO   v_last_name
  FROM   employees
  WHERE  employee_id = 999;

  DBMS_OUTPUT.PUT_LINE('社員名=' || v_last_name);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('社員が見つかりません');
END;
/
-- 出力: 社員が見つかりません

-- ------------------------------------------------------------
-- 練習2：事前定義例外 TOO_MANY_ROWS
-- SELECT ... INTO が2行以上の場合に発生します。
-- 部署10には社員が複数人います。
-- ------------------------------------------------------------
DECLARE
  v_employee_id employees.employee_id%TYPE;
BEGIN
  SELECT employee_id
  INTO   v_employee_id
  FROM   employees
  WHERE  department_id = 10;

  DBMS_OUTPUT.PUT_LINE('社員番号=' || v_employee_id);
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('複数行が返りました。1行だけ必要な検索か確認してください');
END;
/
-- 出力: 複数行が返りました。1行だけ必要な検索か確認してください

-- ------------------------------------------------------------
-- 練習3：例外を発生前に防ぐ
-- エラーにならない条件分岐が可能なら、例外処理より先に検討します。
-- ------------------------------------------------------------
DECLARE
  v_numerator   NUMBER := 10;
  v_denominator NUMBER := 0;
  v_result      NUMBER;
BEGIN
  IF v_denominator = 0 THEN
    DBMS_OUTPUT.PUT_LINE('分母が0のため計算しません');
  ELSE
    v_result := v_numerator / v_denominator;
    DBMS_OUTPUT.PUT_LINE('計算結果=' || v_result);
  END IF;
END;
/

-- ------------------------------------------------------------
-- 練習4：ユーザー定義例外を宣言してRAISEする
-- RAISEは、プログラムで定義した例外を明示的に発生させます。
-- ------------------------------------------------------------
DECLARE
  e_invalid_salary EXCEPTION;
  v_salary         employees.salary%TYPE := -100;
BEGIN
  IF v_salary < 0 THEN
    RAISE e_invalid_salary;
  END IF;

  DBMS_OUTPUT.PUT_LINE('給与=' || v_salary);
EXCEPTION
  WHEN e_invalid_salary THEN
    DBMS_OUTPUT.PUT_LINE('給与に負数は指定できません');
END;
/
-- 出力: 給与に負数は指定できません

-- ------------------------------------------------------------
-- 練習5：Oracleエラー番号に名前を付ける
-- PRAGMA EXCEPTION_INITで、名前のないOracleエラーを捕捉できます。
-- 社員105はEMP_HISTORYから参照されているため削除できません。
-- ------------------------------------------------------------
DECLARE
  e_child_record_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_child_record_exists, -2292);
BEGIN
  DELETE FROM employees
  WHERE employee_id = 105;

  DBMS_OUTPUT.PUT_LINE('削除した社員数=' || SQL%ROWCOUNT);
EXCEPTION
  WHEN e_child_record_exists THEN
    DBMS_OUTPUT.PUT_LINE('関連する履歴があるため社員105を削除できません');
END;
/
-- 出力: 関連する履歴があるため社員105を削除できません

-- ------------------------------------------------------------
-- 例外の伝播：内側のブロックで処理されない例外は外側へ伝わる
-- 内側のNO_DATA_FOUNDハンドラには一致せず、外側のZERO_DIVIDEに届きます。
-- ------------------------------------------------------------
DECLARE
  v_result NUMBER;
BEGIN
  BEGIN
    v_result := 10 / 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('このハンドラは実行されません');
  END;
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('外側のブロックでZERO_DIVIDEを捕捉しました');
END;
/
-- 出力: 外側のブロックでZERO_DIVIDEを捕捉しました

-- ------------------------------------------------------------
-- 練習6：RAISE_APPLICATION_ERRORで呼び出し元へエラーを返す
-- -20000から-20999までの番号を指定します。
-- この例は意図的にエラーを発生させるため、実行後にエラー表示されます。
-- ------------------------------------------------------------
DECLARE
  v_salary employees.salary%TYPE := -100;
BEGIN
  IF v_salary < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, '給与に負数は指定できません');
  END IF;
END;
/
-- 期待する結果: ORA-20001: 給与に負数は指定できません
-- クライアントにはエラーが返ります。以降のスクリプト実行方法は
-- 使用するツールの設定によって異なるため、この例は最後に実行してください。

-- ------------------------------------------------------------
-- 練習7：SQLCODEとSQLERRMでエラー情報を確認する
-- WHEN OTHERSは他のハンドラに一致しない例外を処理します。
-- 原因を隠すだけの処理にせず、必要ならRAISEで再送出します。
-- ------------------------------------------------------------
DECLARE
  v_numerator   NUMBER := 10;
  v_denominator NUMBER := 0;
  v_result      NUMBER;
BEGIN
  v_result := v_numerator / v_denominator;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SQLCODE=' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('SQLERRM=' || SQLERRM);
    RAISE;
END;
/
-- 期待する結果: エラー番号とメッセージを表示した後、ZERO_DIVIDEが再送出されます。

-- ------------------------------------------------------------
-- 例外ハンドラの書き方と注意点
-- ------------------------------------------------------------
-- EXCEPTION
--   WHEN 例外名1 THEN
--     -- 対応する処理
--   WHEN 例外名2 OR 例外名3 THEN
--     -- 複数の例外を同じ処理にまとめることもできます
--   WHEN OTHERS THEN
--     -- 必ず最後に置く。通常は再送出するか、明確に処理を完了する
--
-- ・ハンドラに一致しない例外は、外側のブロックへ伝わります。
-- ・例外ハンドラ内で別の例外が発生すると、そのブロックの外側へ伝わります。
-- ・例外が発生しても、トランザクション全体が自動的にROLLBACKされるとは限りません。
--   COMMIT / ROLLBACKの責任範囲を明確にしてください。
-- ・WHEN OTHERSで何もせず握りつぶすと、呼び出し元が失敗を検知できません。

-- ------------------------------------------------------------
-- 自分で試す
-- ------------------------------------------------------------
-- 1. 練習1の社員番号を101に変え、NO_DATA_FOUNDにならない場合を確認する。
-- 2. 練習2のWHERE条件をemployee_id = 101に変える。
-- 3. 練習4で給与を0にした場合と、正の値にした場合を比べる。
-- 4. 練習5の社員番号を101に変えて実行し、削除件数を確認する。
--    この練習ではemployeesのデータを変更するので、必要なら
--    sql/01_basics/01_test_data.sql を再実行して初期状態に戻す。
-- 5. 練習6と練習7は、意図的に未処理例外を返す。必要に応じて個別に実行する。

-- 参考資料
-- Oracle PL/SQL Language Reference 26ai:
-- https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/overview-exception-handling.html
-- 例外一覧（提示された公式サイト）:
-- https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/lot.html