-- ============================================================
-- PL/SQL ファンクションの練習
-- 事前に sql/01_basics/01_test_data.sql を実行してください。
-- 関数はSELECT文などの式としても呼び出せます。
-- ============================================================

-- ------------------------------------------------------------
-- 練習1：1から指定した整数までを合計する
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION ydsum (
  p_number IN NUMBER
)
RETURN NUMBER
IS
  v_total NUMBER := 0;
BEGIN
  IF p_number IS NULL
     OR p_number < 0
     OR p_number != TRUNC(p_number) THEN
    RAISE_APPLICATION_ERROR(-20011, '0以上の整数を指定してください');
  END IF;

  FOR i IN 1 .. p_number LOOP
    v_total := v_total + i;
  END LOOP;

  RETURN v_total;
END;
/

SELECT ydsum(10) AS total_1_to_10 FROM dual;
-- 結果: 55

-- ------------------------------------------------------------
-- 練習2：社員番号に応じた昇給後の給与を返す
-- 給与 <= 5,000: 20%増、<= 10,000: 15%増、
-- <= 20,000: 10%増、それを超える場合は据え置き。
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION ydinc (
  p_employee_id IN employees.employee_id%TYPE
)
RETURN employees.salary%TYPE
IS
  v_salary employees.salary%TYPE;
BEGIN
  SELECT salary
  INTO   v_salary
  FROM   employees
  WHERE  employee_id = p_employee_id;

  IF v_salary IS NULL THEN
    RETURN NULL;
  ELSIF v_salary <= 5000 THEN
    RETURN v_salary * 1.20;
  ELSIF v_salary <= 10000 THEN
    RETURN v_salary * 1.15;
  ELSIF v_salary <= 20000 THEN
    RETURN v_salary * 1.10;
  ELSE
    RETURN v_salary;
  END IF;
END;
/

SELECT employee_id, last_name, salary, ydinc(employee_id) AS raised_salary
FROM   employees
ORDER BY employee_id;

-- ------------------------------------------------------------
-- 練習3：社員番号から年俸を計算する
-- 年俸 = (給与 + 給与 * インセンティブ率) * 12
-- インセンティブ率がNULLの場合は0として扱います。
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION yd_func (
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
END;
/

SELECT employee_id, last_name, salary, yd_func(employee_id) AS annual_salary
FROM   employees
ORDER BY employee_id;

-- ------------------------------------------------------------
-- 練習4：名前の先頭1文字以外を * に置き換える
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION subname (
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
END;
/

SELECT last_name, subname(last_name) AS masked_name
FROM   employees
ORDER BY employee_id;

-- ------------------------------------------------------------
-- 練習5：社員番号と昇給率（%）から昇給後給与を返す
-- 例: 10を渡すと10%増。関数内では表を更新しません。
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION inc_sal (
  p_employee_id IN employees.employee_id%TYPE,
  p_raise_pct   IN NUMBER
)
RETURN employees.salary%TYPE
IS
  v_salary employees.salary%TYPE;
BEGIN
  IF p_raise_pct IS NULL OR p_raise_pct < 0 THEN
    RAISE_APPLICATION_ERROR(-20012, '昇給率には0以上の数値を指定してください');
  END IF;

  SELECT salary
  INTO   v_salary
  FROM   employees
  WHERE  employee_id = p_employee_id;

  IF v_salary IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN v_salary * (1 + p_raise_pct / 100);
END;
/

SELECT employee_id,
       last_name,
       salary,
       inc_sal(employee_id, 10) AS salary_after_10_percent_raise
FROM   employees
ORDER BY employee_id;

-- 存在しない社員番号の例（個別に実行するとNO_DATA_FOUNDになります）
-- SELECT inc_sal(100, 10) AS salary_after_raise
-- FROM   dual;

-- ------------------------------------------------------------
-- 学習ポイント
-- ------------------------------------------------------------
-- ・CREATE FUNCTIONには戻り値型と、実行経路上のRETURNが必要です。
-- ・表を参照する関数はSELECT文から利用できます。
-- ・SQL文から呼び出す関数に副作用（表の更新など）を持たせないでください。
-- ・社員が存在しない場合はSELECT ... INTOからNO_DATA_FOUNDが発生します。