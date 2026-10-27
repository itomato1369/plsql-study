-- ============================================================
-- カーソルFORループの練習
-- 事前に sql/01_basics/01_test_data.sql を実行してください。
-- 各練習の内容を考えてから、続く模範解答を実行してみましょう。
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- 練習1：部署IDが30の社員について、社員ID・姓・給与を表示する
-- 確認ポイント：カーソルFORループではOPEN・FETCH・CLOSEが自動で行われる
-- ------------------------------------------------------------
DECLARE
  CURSOR c_employees IS
    SELECT employee_id, last_name, salary
    FROM   employees
    WHERE  department_id = 30
    ORDER BY employee_id;
BEGIN
  FOR emp_rec IN c_employees LOOP
    DBMS_OUTPUT.PUT_LINE(
      emp_rec.employee_id || ' ' ||
      emp_rec.last_name || ' 給与=' ||
      NVL(TO_CHAR(emp_rec.salary), 'NULL')
    );
  END LOOP;
END;
/

-- ------------------------------------------------------------
-- 練習2：カーソルに部署IDを渡し、部署60の社員を表示する
-- 確認ポイント：カーソルパラメータと %TYPE
-- ------------------------------------------------------------
DECLARE
  CURSOR c_department_employees (
    p_department_id employees.department_id%TYPE
  ) IS
    SELECT employee_id, last_name, salary
    FROM   employees
    WHERE  department_id = p_department_id
    ORDER BY employee_id;
BEGIN
  FOR emp_rec IN c_department_employees(60) LOOP
    DBMS_OUTPUT.PUT_LINE(
      emp_rec.employee_id || ' ' ||
      emp_rec.last_name || ' 給与=' ||
      NVL(TO_CHAR(emp_rec.salary), 'NULL')
    );
  END LOOP;
END;
/

-- ------------------------------------------------------------
-- 練習3：名前付きカーソルを宣言せず、給与が15,000以上の社員を表示する
-- 確認ポイント：SELECTを直接カーソルFORループに書く方法
-- ------------------------------------------------------------
BEGIN
  FOR emp_rec IN (
    SELECT employee_id, last_name, salary
    FROM   employees
    WHERE  salary >= 15000
    ORDER BY salary, employee_id
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(
      emp_rec.employee_id || ' ' ||
      emp_rec.last_name || ' 給与=' ||
      TO_CHAR(emp_rec.salary)
    );
  END LOOP;
END;
/

-- 練習：部署IDを10に変えて実行し、給与がNULLの社員も表示されることを確認する。
-- NULLを文字列に変換するNVLは、練習1・2の出力で使用しています。