-- ============================================================
-- 明示カーソルの練習
-- 事前に sql/01_basics/01_test_data.sql を実行してください。
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- 練習1：部署IDが10の社員を1行ずつ取得して表示する
-- 確認ポイント：宣言 -> OPEN -> FETCH -> %NOTFOUND -> CLOSE
-- ------------------------------------------------------------
DECLARE
  CURSOR c_employees IS
    SELECT employee_id, last_name, salary
    FROM   employees
    WHERE  department_id = 10
    ORDER BY employee_id;

  v_employee_id employees.employee_id%TYPE;
  v_last_name   employees.last_name%TYPE;
  v_salary      employees.salary%TYPE;
BEGIN
  OPEN c_employees;

  IF c_employees%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('カーソルを開きました');
  END IF;

  LOOP
    FETCH c_employees
      INTO v_employee_id, v_last_name, v_salary;

    EXIT WHEN c_employees%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(
      v_employee_id || ' ' ||
      v_last_name || ' 給与=' ||
      NVL(TO_CHAR(v_salary), 'NULL')
    );
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('取得した行数=' || c_employees%ROWCOUNT);
  CLOSE c_employees;
END;
/

-- ------------------------------------------------------------
-- 練習2：%ROWTYPEを使い、部署30の社員情報を取得する
-- 確認ポイント：SELECT * の結果を表の行型レコードにFETCHする
-- ------------------------------------------------------------
DECLARE
  CURSOR c_employees IS
    SELECT *
    FROM   employees
    WHERE  department_id = 30
    ORDER BY employee_id;

  v_employee employees%ROWTYPE;
BEGIN
  OPEN c_employees;

  LOOP
    FETCH c_employees INTO v_employee;
    EXIT WHEN c_employees%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(
      v_employee.employee_id || ' ' ||
      v_employee.last_name || ' 部署=' ||
      v_employee.department_id
    );
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('取得した行数=' || c_employees%ROWCOUNT);
  CLOSE c_employees;
END;
/

-- ------------------------------------------------------------
-- 練習3：社員がいない部署70を検索し、0件でも正常に終了することを確認する
-- 確認ポイント：FETCHが0件でも例外は発生せず、%NOTFOUNDがTRUEになる
-- ------------------------------------------------------------
DECLARE
  CURSOR c_department_employees (
    p_department_id employees.department_id%TYPE
  ) IS
    SELECT employee_id, last_name
    FROM   employees
    WHERE  department_id = p_department_id;

  v_employee_id employees.employee_id%TYPE;
  v_last_name   employees.last_name%TYPE;
BEGIN
  OPEN c_department_employees(70);

  LOOP
    FETCH c_department_employees INTO v_employee_id, v_last_name;
    EXIT WHEN c_department_employees%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(v_employee_id || ' ' || v_last_name);
  END LOOP;

  IF c_department_employees%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('対象社員はいません');
  END IF;

  CLOSE c_department_employees;
END;
/

-- 練習：部署IDを30に変えて、練習3の出力と取得行数を比べてみましょう。
-- FETCHと%NOTFOUNDの判定を逆にした場合に何が起きるかも考えてください。