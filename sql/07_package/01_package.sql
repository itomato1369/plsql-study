-- ============================================================
-- PL/SQL パッケージの練習
-- 事前に sql/01_basics/01_test_data.sql を実行してください。
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- 仕様部：公開する変数・型・サブプログラムを宣言する
-- ------------------------------------------------------------
CREATE OR REPLACE PACKAGE employee_tools IS
  g_call_count PLS_INTEGER := 0;

  PROCEDURE show_employee (
    p_employee_id IN employees.employee_id%TYPE
  );

  FUNCTION annual_salary (
    p_employee_id IN employees.employee_id%TYPE
  )
  RETURN NUMBER;

  FUNCTION mask_name (
    p_name IN VARCHAR2
  )
  RETURN VARCHAR2;

  FUNCTION mask_name (
    p_employee_id IN employees.employee_id%TYPE
  )
  RETURN VARCHAR2;

  PROCEDURE reset_call_count;
END employee_tools;
/

-- ------------------------------------------------------------
-- 本体部：公開サブプログラムの実装と非公開処理を定義する
-- ------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY employee_tools IS
  FUNCTION mask_text (
    p_name IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
  BEGIN
    IF p_name IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN SUBSTR(p_name, 1, 1) ||
           RPAD('*', GREATEST(LENGTH(p_name) - 1, 0), '*');
  END mask_text;

  PROCEDURE show_employee (
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

    g_call_count := g_call_count + 1;
    DBMS_OUTPUT.PUT_LINE(
      p_employee_id || ' ' || v_last_name ||
      ' 給与=' || NVL(TO_CHAR(v_salary), 'NULL')
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('該当する社員がいません');
  END show_employee;

  FUNCTION annual_salary (
    p_employee_id IN employees.employee_id%TYPE
  )
  RETURN NUMBER
  IS
    v_salary         employees.salary%TYPE;
    v_commission_pct employees.commission_pct%TYPE;
  BEGIN
    SELECT salary, commission_pct
    INTO   v_salary, v_commission_pct
    FROM   employees
    WHERE  employee_id = p_employee_id;

    IF v_salary IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN (v_salary + v_salary * NVL(v_commission_pct, 0)) * 12;
  END annual_salary;

  FUNCTION mask_name (
    p_name IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN mask_text(p_name);
  END mask_name;

  FUNCTION mask_name (
    p_employee_id IN employees.employee_id%TYPE
  )
  RETURN VARCHAR2
  IS
    v_last_name employees.last_name%TYPE;
  BEGIN
    SELECT last_name
    INTO   v_last_name
    FROM   employees
    WHERE  employee_id = p_employee_id;

    RETURN mask_text(v_last_name);
  END mask_name;

  PROCEDURE reset_call_count IS
  BEGIN
    g_call_count := 0;
  END reset_call_count;
END employee_tools;
/

-- ------------------------------------------------------------
-- 呼び出し例：ドット記法、オーバーロード、パッケージ変数
-- ------------------------------------------------------------
BEGIN
  employee_tools.show_employee(176);
  employee_tools.show_employee(9999);
  DBMS_OUTPUT.PUT_LINE(
    'このセッションでの呼び出し回数=' || employee_tools.g_call_count
  );
END;
/

SELECT employee_tools.annual_salary(103) AS annual_salary,
       employee_tools.mask_name('Taylor') AS masked_text,
       employee_tools.mask_name(176) AS masked_employee_name
FROM   dual;

BEGIN
  employee_tools.reset_call_count;
  DBMS_OUTPUT.PUT_LINE('リセット後=' || employee_tools.g_call_count);
END;
/

-- ------------------------------------------------------------
-- 学習ポイント
-- ------------------------------------------------------------
-- ・仕様部が公開インターフェース、本体部が実装です。
-- ・mask_textは本体部だけに定義され、外部から直接呼べない非公開関数です。
-- ・同名のmask_nameは引数型が異なるオーバーロードです。
-- ・パッケージ変数は同一セッション内で状態を保持します。
--   接続プールを使うアプリケーションでは、セッションをまたぐ状態に注意します。
-- ・本体を変更したときはCREATE OR REPLACE PACKAGE BODYを再実行します。
