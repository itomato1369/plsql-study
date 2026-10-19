-- ============================================================
-- 練習用テーブル・シーケンス・テストデータ（架空データ）
-- 実行ユーザー："ユーザー"（接続先：XEPDB1）
-- 何度実行しても作り直せるように、最初に既存のものを削除します
-- ============================================================

-- ------------------------------------------------------------
-- 0. 既存テーブル・シーケンスの削除
-- ------------------------------------------------------------
BEGIN
  FOR t IN (
    SELECT table_name
    FROM   user_tables
    WHERE  table_name IN ('EMPLOYEES', 'DEPARTMENTS', 'EMP10', 'EMP20', 'EMP30',
                          'EMP40', 'EMP50', 'EMP00', 'TEST01', 'TEST02',
                          'AAA', 'BBB', 'EMP', 'RETIRED_EMPS', 'TEMP_LIST',
                          'EMP_HISTORY', 'EMP_TEST')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;

  FOR s IN (
    SELECT sequence_name
    FROM   user_sequences
    WHERE  sequence_name = 'DEPARTMENTS_SEQ'
  ) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

-- ------------------------------------------------------------
-- 1. 部署テーブル（manager_id・location_id を追加）
-- ------------------------------------------------------------
CREATE TABLE departments (
    department_id    NUMBER(4)     CONSTRAINT pk_departments PRIMARY KEY,
    department_name  VARCHAR2(30)  NOT NULL,
    manager_id       NUMBER(6),
    location_id      NUMBER(4)
);

-- ------------------------------------------------------------
-- 2. 社員テーブル
-- ------------------------------------------------------------
CREATE TABLE employees (
    employee_id      NUMBER(6)     CONSTRAINT pk_employees PRIMARY KEY,
    last_name        VARCHAR2(25)  NOT NULL,
    hire_date        DATE          NOT NULL,
    salary           NUMBER(8,2),
    commission_pct   NUMBER(2,2),
    department_id    NUMBER(4)     CONSTRAINT fk_emp_dept REFERENCES departments(department_id),
    job_id           VARCHAR2(10),
    manager_id       NUMBER(6)
);

-- ------------------------------------------------------------
-- 3. 子テーブル（ORA-02292 の確認用：社員を削除できないケース）
-- ------------------------------------------------------------
CREATE TABLE emp_history (
    history_id       NUMBER(6)     CONSTRAINT pk_emp_history PRIMARY KEY,
    employee_id      NUMBER(6)     CONSTRAINT fk_hist_emp REFERENCES employees(employee_id),
    memo             VARCHAR2(50)
);

-- ------------------------------------------------------------
-- 4. シーケンス（add_department プロシージャ用）
-- ------------------------------------------------------------
CREATE SEQUENCE departments_seq
    START WITH 80
    INCREMENT BY 10
    NOCACHE;

-- ------------------------------------------------------------
-- 5. テストデータ：部署
-- ------------------------------------------------------------
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (10, '総務部', 101, 1700);
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (20, '営業部', 103, 1800);
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (30, '開発部', 105, 1700);
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (40, '経理部', 107, 1800);
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (50, '人事部', 109, 1900);
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (60, '研究部', 105, 1900);
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (70, '広報部', NULL, 2000);   -- 社員がいない部署（「部署に社員がいない」問題用）

-- ------------------------------------------------------------
-- 6. テストデータ：社員
-- ------------------------------------------------------------
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (101, 'Sato',      DATE '1999-03-15', 4800,  NULL, 10,   'AD_ASST',    NULL);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (102, 'Suzuki',    DATE '2003-07-01', 5000,  NULL, 10,   'AD_ASST',    101);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (103, 'Takahashi', DATE '2005-01-01', 9000,  0.10, 20,   'SA_REP',     NULL);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (104, 'Tanaka',    DATE '2004-12-31', 9500,  NULL, 20,   'SA_REP',     103);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (105, 'Ito',       DATE '2008-04-10', 12000, 0.15, 30,   'IT_PROG',    NULL);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (106, 'Watanabe',  DATE '2001-06-20', 15000, NULL, 30,   'IT_PROG',    105);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (107, 'Yamamoto',  DATE '2012-09-01', 15001, 0.20, 40,   'FI_ACCOUNT', NULL);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (108, 'Nakamura',  DATE '2010-02-14', 18000, NULL, 40,   'FI_MGR',     107);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (109, 'Kobayashi', DATE '1998-11-30', 7000,  0.05, 50,   'HR_REP',     NULL);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (110, 'Kato',      DATE '2015-05-05', 3000,  NULL, NULL, 'ST_CLERK',   NULL);  -- 部署なし
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (111, 'Yoshida',   DATE '2000-01-01', NULL,  NULL, 10,   'AD_ASST',    101);   -- 給与 NULL
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (112, 'Yamada',    DATE '2000-12-31', 6500,  0.25, 20,   'SA_REP',     103);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (113, 'Sasaki',    DATE '2019-08-19', 11000, NULL, NULL, 'SA_MAN',     NULL);  -- 部署なし
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (114, 'Yamaguchi', DATE '2020-10-01', 13000, 0.10, 30,   'IT_PROG',    105);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (115, 'Matsumoto', DATE '2007-03-03', 16000, NULL, 50,   'HR_MGR',     109);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (116, 'Hayashi',   DATE '2016-04-01', 7800,  NULL, 60,   'IT_PROG',    105);
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (117, 'Shimizu',   DATE '2017-10-16', 20000, NULL, 60,   'IT_PROG',    116);  -- 給与 20000（境界値）
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (124, 'Ogawa',     DATE '2021-03-01', 8000,  NULL, 60,   'IT_PROG',    116);  -- ROWTYPE問題用
INSERT INTO employees (employee_id, last_name, hire_date, salary, commission_pct, department_id, job_id, manager_id)
VALUES (176, 'Taylor',    DATE '1998-03-24', 8600,  0.20, 60,   'SA_REP',     103);  -- プロシージャの実行例用

-- ------------------------------------------------------------
-- 7. テストデータ：子テーブル（社員105は削除できない）
-- ------------------------------------------------------------
INSERT INTO emp_history (history_id, employee_id, memo) VALUES (1, 105, '研修受講');
INSERT INTO emp_history (history_id, employee_id, memo) VALUES (2, 105, '資格取得');
INSERT INTO emp_history (history_id, employee_id, memo) VALUES (3, 106, '異動');

COMMIT;

-- ------------------------------------------------------------
-- 8. if文・RECORD問題用（employees と同じ列構成）
-- ------------------------------------------------------------
CREATE TABLE emp10 AS SELECT * FROM employees WHERE 1 = 0;
CREATE TABLE emp20 AS SELECT * FROM employees WHERE 1 = 0;
CREATE TABLE emp30 AS SELECT * FROM employees WHERE 1 = 0;
CREATE TABLE emp40 AS SELECT * FROM employees WHERE 1 = 0;
CREATE TABLE emp50 AS SELECT * FROM employees WHERE 1 = 0;
CREATE TABLE emp00 AS SELECT * FROM employees WHERE 1 = 0;

-- ------------------------------------------------------------
-- 9. INSERT・カーソル問題用
-- ------------------------------------------------------------
CREATE TABLE test01 (empid, ename, hiredate) AS
  SELECT employee_id, last_name, hire_date FROM employees WHERE employee_id = 0;

CREATE TABLE test02 (empid, ename, hiredate) AS
  SELECT employee_id, last_name, hire_date FROM employees WHERE employee_id = 0;

-- ------------------------------------------------------------
-- 10. 制御文の練習用
-- ------------------------------------------------------------
CREATE TABLE aaa (a NUMBER(3));
CREATE TABLE bbb (b NUMBER(3));

-- ------------------------------------------------------------
-- 11. PL/SQL TABLE・一時リスト用
-- ------------------------------------------------------------
CREATE TABLE emp (empid, empname) AS
  SELECT employee_id, last_name FROM employees WHERE employee_id = 0;

CREATE TABLE temp_list (empid, empname) AS
  SELECT employee_id, last_name FROM employees WHERE employee_id = 0;

-- ------------------------------------------------------------
-- 12. ROWTYPE問題用
-- ------------------------------------------------------------
CREATE TABLE retired_emps (empno, ename, job, mgr, hiredate,
                           leavedate, sal, comm, deptno) AS
  SELECT employee_id, last_name, job_id, manager_id, hire_date,
         SYSDATE, salary, commission_pct, department_id
  FROM   employees
  WHERE  employee_id = 0;

-- ------------------------------------------------------------
-- 13. 例外処理問題用（emp_test：employee_id < 200 の社員をコピー）
-- ------------------------------------------------------------
CREATE TABLE emp_test AS
  SELECT employee_id, last_name
  FROM   employees
  WHERE  employee_id < 200;

-- ------------------------------------------------------------
-- 14. 作成確認
-- ------------------------------------------------------------
SELECT table_name FROM user_tables ORDER BY table_name;
SELECT COUNT(*) AS dept_count FROM departments;   -- 7件
SELECT COUNT(*) AS emp_count  FROM employees;     -- 19件
SELECT COUNT(*) AS hist_count FROM emp_history;   -- 3件