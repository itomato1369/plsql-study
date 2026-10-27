-- ============================================================
-- PL/SQL プロシージャの練習
-- 事前に sql/01_basics/01_test_data.sql を実行してください。
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- プロシージャの基本：INパラメータで社員番号を受け取る
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE show_employee (
  p_employee_id IN employees.employee_id%TYPE
)
IS
  v_last_name employees.last_name%TYPE;
  v_salary    employees.salary%TYPE;
BEGIN
  SELECT last_name, salary
  INTO   v_last_name, v_salary
  FROM   employees
  WHERE  employee_id = p_employee_id;

  DBMS_OUTPUT.PUT_LINE(
    '社員番号=' || p_employee_id ||
    ' 名前=' || v_last_name ||
    ' 給与=' || NVL(TO_CHAR(v_salary), 'NULL')
  );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('該当する社員がいません');
END;
/

BEGIN
  show_employee(176);
  show_employee(9999);
END;
/

-- ------------------------------------------------------------
-- 練習1：INパラメータを使い、個人番号を一部マスキングして表示する
-- 数値では先頭の0が失われる可能性があるため、文字列で受け取ります。
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE yedam_ju (
  p_personal_number IN VARCHAR2
)
IS
BEGIN
  IF p_personal_number IS NULL
     OR NOT REGEXP_LIKE(p_personal_number, '^[0-9]{13}$') THEN
    RAISE_APPLICATION_ERROR(-20001, '13桁の数字を指定してください');
  END IF;

  DBMS_OUTPUT.PUT_LINE(
    SUBSTR(p_personal_number, 1, 6) || '-' ||
    SUBSTR(p_personal_number, 7, 1) || '******'
  );
END;
/

BEGIN
  yedam_ju('950101166765666667');
END;
/
-- 出力: 950101-1******
-- 不正な入力を試す場合は、次を個別に実行してください。
-- EXECUTE yedam_ju('123');

-- ------------------------------------------------------------
-- 練習2：社員番号を指定して削除する
-- 該当なしをSQL%ROWCOUNTで判定します。COMMITは呼び出し元に任せます。
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE test_pro (
  p_employee_id IN employees.employee_id%TYPE
)
IS
BEGIN
  DELETE FROM employees
  WHERE employee_id = p_employee_id;

  IF SQL%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('該当社員がいません');
  ELSE
    DBMS_OUTPUT.PUT_LINE('社員番号 ' || p_employee_id || ' を削除しました');
  END IF;
END;
/

-- DELETE後、同じブロック内でROLLBACK TOして練習データを元に戻します。
SAVEPOINT before_test_pro;
BEGIN
  test_pro(176);
  ROLLBACK TO before_test_pro;
END;
/

BEGIN
  test_pro(9999);
END;
/

-- ------------------------------------------------------------
-- 練習3：社員名の先頭1文字以外を * に置き換える
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE yedam_emp (
  p_employee_id IN employees.employee_id%TYPE
)
IS
  v_last_name employees.last_name%TYPE;
BEGIN
  SELECT last_name
  INTO   v_last_name
  FROM   employees
  WHERE  employee_id = p_employee_id;

  DBMS_OUTPUT.PUT_LINE(
    v_last_name || ' -> ' ||
    SUBSTR(v_last_name, 1, 1) ||
    RPAD('*', GREATEST(LENGTH(v_last_name) - 1, 0), '*')
  );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('該当する社員がいません');
END;
/

BEGIN
  yedam_emp(176);
  yedam_emp(9999);
END;
/
-- 出力例: Taylor -> T*****

-- ------------------------------------------------------------
-- OUTパラメータ：処理結果を呼び出し元へ返す
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE get_employee_name (
  p_employee_id IN  employees.employee_id%TYPE,
  p_last_name   OUT employees.last_name%TYPE
)
IS
BEGIN
  SELECT last_name
  INTO   p_last_name
  FROM   employees
  WHERE  employee_id = p_employee_id;
END;
/

DECLARE
  v_last_name employees.last_name%TYPE;
BEGIN
  get_employee_name(176, v_last_name);
  DBMS_OUTPUT.PUT_LINE('OUTで受け取った名前=' || v_last_name);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('該当する社員がいません');
END;
/

-- ------------------------------------------------------------
-- IN OUTパラメータ：値を受け取り、変更した値を呼び出し元へ返す
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_raise_points (
  p_raise_pct IN OUT NUMBER
)
IS
BEGIN
  p_raise_pct := p_raise_pct + 5;
END;
/

DECLARE
  v_raise_pct NUMBER := 10;
BEGIN
  add_raise_points(v_raise_pct);
  DBMS_OUTPUT.PUT_LINE('変更後の昇給率=' || v_raise_pct || '%');
END;
/
-- 出力: 変更後の昇給率=15%

-- ------------------------------------------------------------
-- 既存の練習用シーケンスを使って部署を追加する例
-- INSERTは行いますがCOMMITしません。呼び出し元で確定・取消を決めます。
-- ------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_department (
  p_name IN departments.department_name%TYPE,
  p_mgr  IN departments.manager_id%TYPE,
  p_loc  IN departments.location_id%TYPE
)
IS
BEGIN
  INSERT INTO departments (
    department_id, department_name, manager_id, location_id
  )
  VALUES (
    departments_seq.NEXTVAL, p_name, p_mgr, p_loc
  );

  DBMS_OUTPUT.PUT_LINE('部署を追加しました: ' || p_name);
END;
/

SAVEPOINT before_add_department;
BEGIN
  add_department('練習用部署', NULL, 2000);
  ROLLBACK TO before_add_department;
END;
/

-- ------------------------------------------------------------
-- 学習ポイント
-- ------------------------------------------------------------
-- ・INは入力専用（省略時の既定値）。OUTは結果を呼び出し元へ返します。
-- ・プロシージャ内でCOMMIT/ROLLBACKを固定せず、呼び出し元が
--   トランザクションを制御すると再利用しやすくなります。
-- ・WHEN OTHERSでエラーを表示するだけにして握りつぶさず、
--   必要な例外だけを処理し、予期しない例外は呼び出し元へ伝えます。