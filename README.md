# PL/SQL 基礎まとめ

> 原典：Oracle PL/SQL 学習資料、要点を**Claude、VSCodeでのGitHub Copilot**を利用して圧縮したものです。

---

## 目次

1. PL/SQLとは
2. 基本構造（ブロック）
3. 変数・データ型
4. SQL文と演算子
5. 制御構造（条件分岐・繰り返し）
6. 複合データ型
7. 明示的カーソル（複数行の処理）
8. 例外処理（エラー対応）
9. プロシージャ（手続き）
10. ファンクション（関数）
11. パッケージ（関連する部品をまとめる）
12. トリガー（自動実行の仕組み）
13. トランザクション制御（TCL）と権限制御（DCL）
14. 覚えておきたいポイント（まとめ）

---

## 1. PL/SQLとは

SQLに手続き型の機能（変数・条件分岐・繰り返し・例外処理）を加えたOracle独自の言語です。
Oracle Server（DB本体）と Oracle開発ツールの両方で中心的に使われます。

SQLの処理をブロック単位のプログラムにまとめ、処理を一括で実行できるのが利点です。

---

## 2. 基本構造（ブロック）

```sql
DECLARE   -- 任意：変数・カーソル・例外の宣言
BEGIN     -- 必須：SQL文・PL/SQL文
EXCEPTION -- 任意：エラー時の処理
END;      -- 必須
```

- 文の終わりには `;`（セミコロン）を付けます。ただし `DECLARE` / `BEGIN` / `EXCEPTION` の直後には付けません。
- SQL\*Plus で `/` を入力すると実行されます。成功すると `PL/SQL procedure successfully completed.` と表示されます。
- ブロックは入れ子にできます。内側のブロックで宣言した変数は外側からは見えません（**変数の有効範囲**）。

**種類**：無名ブロック（その場実行）、プロシージャ、ファンクション、トリガー、パッケージ

---

## 3. 変数・データ型

### (1) 変数の宣言と代入

```sql
DECLARE
  v_hiredate DATE;
  v_deptno   NUMBER(2) NOT NULL := 10;  -- NOT NULLは初期化必須
  v_comm     CONSTANT NUMBER := 1400;   -- 定数
BEGIN
  v_hiredate := '15-SEP-99';            -- 代入は := を使用
END;
```

- **命名規則**：30文字以内、英字で開始。DB列名と同じ名前は避ける。
- **慣習**：変数は `v_`、グローバル変数は `g_`、定数は `c_` などの接頭辞を付けると、DBオブジェクトと区別しやすくなります。
- **%TYPE**：列の型を流用します（`v_ename emp.ename%TYPE;`）。テーブル定義が変わっても修正が少なくて済みます。
- **%ROWTYPE**：表の1行分をまとめて受け取る変数です（`emp_rec emp%ROWTYPE;`）。

### (2) 主なデータ型

| 分類 | 主な型 | 内容 |
|---|---|---|
| 文字 | `VARCHAR2(n)` | 可変長文字（最大32,767バイト）。通常はこれを使用 |
| 文字 | `CHAR(n)` | 固定長文字（既定は1バイト） |
| 数値 | `NUMBER(p,s)` | 整数・小数の基本型（p=桁数、s=小数桁数） |
| 数値 | `PLS_INTEGER` / `BINARY_INTEGER` | 整数専用。`NUMBER`より高速 |
| 日付 | `DATE` | 日付と時刻（BC4712年〜AC9999年） |
| 論理 | `BOOLEAN` | `TRUE` / `FALSE` / `NULL` のいずれか（SQL列には使えない） |
| 大容量 | `CLOB` / `BLOB` / `BFILE` | 文書・画像・動画などの大きなデータ |

### (3) 変数の値を画面に表示する

```sql
SET SERVEROUTPUT ON
BEGIN
  DBMS_OUTPUT.PUT_LINE('月給: ' || TO_CHAR(v_sal));
END;
```

> **ポイント**：`DBMS_OUTPUT.PUT_LINE` を使うには事前に `SET SERVEROUTPUT ON` が必要です。

---

## 4. SQL文と演算子

- **SELECT ... INTO**：結果を変数に格納します。1行だけ返す必要があり、0行または2行以上だと例外が発生します。
- **INSERT / UPDATE / DELETE**：ブロック内で直接実行できます。
- **COMMIT / ROLLBACK / SAVEPOINT**：トランザクション制御に使えます。
- **DDL（CREATE等）とDCL（GRANT等）**：PL/SQL内では直接使えません。
- **SQL関数**：単一行の関数（文字・数値・日付・変換）は使えます。`DECODE` と グループ関数（`SUM` 等）はPL/SQL文の中では使えず、SQL文の中でのみ使えます。

```sql
SELECT SUM(sal) INTO v_sum_sal   -- SQL文の中のSUMは可
FROM emp WHERE deptno = v_deptno;
```

### 演算子の優先順位（高→低）

| 優先順位 | 演算子 |
|---|---|
| 1 | `**`（累乗）、`AND` → `OR`（論理積・論理和） |
| 2 | `+` / `-`（符号） |
| 3 | `*` / `/`（乗除） |
| 4 | `+` `-` `\|\|`（加減・文字連結） |
| 5 | `=`, `!=`, `<`, `>`, `IS NULL`, `LIKE`, `BETWEEN`, `IN`（比較） |
| 6 | `NOT`（否定） |

### 暗黙カーソルの属性（DML結果の確認）

| 属性 | 意味 |
|---|---|
| `SQL%ROWCOUNT` | 直前のSQLで処理された行数 |
| `SQL%FOUND` | 1行以上処理されたら `TRUE` |
| `SQL%NOTFOUND` | 1行も処理されなかったら `TRUE` |
| `SQL%ISOPEN` | 常に `FALSE`（暗黙カーソルは実行後すぐ閉じられるため） |

---

## 5. 制御構造（条件分岐・繰り返し）

### (1) 条件分岐 IF

```sql
IF v_deptno = 10 THEN
  v_comm := 5000;
ELSIF v_deptno = 20 THEN   -- ELSIFは1語、END IFは2語
  v_comm := 7500;
ELSE
  v_comm := 2000;
END IF;
```

- 条件が `NULL` の場合は `FALSE` と同じ扱いになり、THEN部分は実行されません。
- `ELSIF` を使うと、IFの入れ子より読みやすくなります。

### (2) 繰り返し LOOP

| 種類 | 書き方の要点 | 使いどころ |
|---|---|---|
| 基本LOOP | `EXIT WHEN 条件` で終了。最低1回は実行される | 回数が決まっていない処理 |
| FOR LOOP | `FOR i IN 1..10 LOOP`。カウンタ変数は宣言不要 | 回数が決まっている処理 |
| WHILE LOOP | `WHILE 条件 LOOP`。条件がTRUEの間繰り返す | 条件で回数が変わる処理 |

```sql
FOR i IN 1..10 LOOP        -- REVERSEを付けると逆順
  INSERT INTO emp (empno, mgr) VALUES (v_empno, i);
  v_empno := v_empno + 1;
END LOOP;
```

> **注意**：LOOP内で終了条件の変数を更新し忘れると無限ループになります。また、FORのカウンタには代入できません。

---

## 6. 複合データ型

| 型 | 概要 | 特徴 |
|---|---|---|
| RECORD | 型の異なる項目を1つにまとめた構造体 | 項目は `変数名.項目名` で参照 |
| %ROWTYPE | 表（またはビュー）の1行分と同じ構造の変数 | 列数や型の変更に自動で追従 |
| PL/SQL TABLE | `INDEX BY BINARY_INTEGER` を使う配列 | サイズ無制限、添字は整数 |

```sql
DECLARE
  emp_rec emp%ROWTYPE;   -- 行全体を受け取る
BEGIN
  -- SELECT * FROM TABLE よりは
  -- 抽出したいカラム名を確実に記入した方が良いs
  SELECT * INTO emp_rec FROM emp WHERE empno = 7369;
  DBMS_OUTPUT.PUT_LINE(emp_rec.ename);   -- 項目名で参照
END;
```

**PL/SQL TABLEのメソッド**：`COUNT`（件数）、`FIRST` / `LAST`（最初・最後の添字）、`EXISTS(n)`（存在確認）、`DELETE`（削除）、`NEXT` / `PRIOR`（前後の添字）、`EXTEND` / `TRIM`（サイズ変更）

---

## 7. 明示的カーソル（複数行の処理）

SELECTが複数行を返す場合は、カーソルを宣言して1行ずつ処理します。

### (1) 基本の4ステップ

| 手順 | 命令 | 内容 |
|---|---|---|
| 1 | `CURSOR 名 IS SELECT ...` | 宣言（DECLARE部分） |
| 2 | `OPEN 名;` | SQLを実行し、結果の集合を用意 |
| 3 | `FETCH 名 INTO 変数;` | 1行ずつ取り出す（ループで繰り返す） |
| 4 | `CLOSE 名;` | 使い終わったら閉じる |

```sql
DECLARE
  CURSOR emp_cursor IS
    SELECT employee_id, last_name FROM employees ORDER BY employee_id;
  v_employee_id employees.employee_id%TYPE;
  v_last_name employees.last_name%TYPE;
BEGIN
  OPEN emp_cursor;
  LOOP
    FETCH emp_cursor INTO v_employee_id, v_last_name;
    EXIT WHEN emp_cursor%NOTFOUND;   -- FETCHの直後に終了判定
    DBMS_OUTPUT.PUT_LINE(v_employee_id || ' ' || v_last_name);
  END LOOP;
  CLOSE emp_cursor;
END;
```

この例は、事前に `sql/01_basics/01_test_data.sql` を実行して `employees` 表を作成してから実行します。練習用スクリプト：

- [カーソルFORループ](sql/04_cursor/01_loop_cursor.sql)：名前付きカーソル、パラメータ付きカーソル、SELECTを直接書く方法
- [明示カーソル](sql/04_cursor/02_explicit_cursor.sql)：`OPEN`・`FETCH`・`CLOSE`、`%TYPE`・`%ROWTYPE`、カーソル属性、0件の場合

参考：Oracle公式リファレンス [カーソル概要](https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/cursors-overview.html)、[カーソルFORループ](https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/cursor-FOR-LOOP-statement.html)、[明示カーソルの宣言と定義](https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/explicit-cursor-declaration-and-definition.html)（Oracle AI Database 26ai）

### (2) カーソルFORループ（最も簡単な書き方）

OPEN・FETCH・CLOSE を自動で行い、レコード変数も自動で宣言されます。

```sql
FOR emp_rec IN emp_cursor LOOP
  DBMS_OUTPUT.PUT_LINE(emp_rec.last_name);
END LOOP;
```

### (3) カーソルの主な属性

| 属性 | 意味 |
|---|---|
| `%ISOPEN` | 開いていれば `TRUE` |
| `%FOUND` / `%NOTFOUND` | 直前のFETCHで行が取れたか（`%NOTFOUND`でループ終了判定） |
| `%ROWCOUNT` | これまでFETCHした行数 |

### (4) その他の機能

- **パラメータ付きカーソル**：`CURSOR c(p_deptno NUMBER) IS ...` のように引数を渡せます。
- **FOR UPDATE / WHERE CURRENT OF**：行をロックしてから、そのカーソル位置の行を `UPDATE` / `DELETE` します。
- **サブクエリ**：カーソルの中でサブクエリを使えます。

> **注意**：OPEN後にFETCHしないままループすると無限ループになるため、`%NOTFOUND` での終了判定を忘れないようにしましょう。

---

## 8. 例外処理（エラー対応）

例外が発生すると、ブロックは途中で停止します。EXCEPTION部分で処理すれば、正常終了させることもできます。処理されない場合は、呼び出し元へ例外が伝播します。

**例外の種類**

- **事前定義例外**：よく起きるエラー（例：`NO_DATA_FOUND`、`TOO_MANY_ROWS`、`ZERO_DIVIDE`、`DUP_VAL_ON_INDEX`）
- **その他のOracleエラー**：`PRAGMA EXCEPTION_INIT` で名前を付けて扱う
- **ユーザー定義例外**：宣言して、`RAISE` で明示的に発生させる

```sql
DECLARE
  e_emps_remaining EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_emps_remaining, -2292);  -- Oracleエラー番号と結び付け
BEGIN
  DELETE FROM dept WHERE deptno = 10;
EXCEPTION
  WHEN e_emps_remaining THEN
    DBMS_OUTPUT.PUT_LINE('社員が存在するため削除できません');
  WHEN OTHERS THEN           -- 最後に置く（1つだけ）
    ROLLBACK;
    INSERT INTO log_table VALUES (SQLCODE, SQLERRM, '未処理エラー');
END;
```

- **SQLCODE**：エラー番号（0=正常、1=ユーザー定義、+100=`NO_DATA_FOUND`、負数=Oracleエラー）
- **SQLERRM**：エラーメッセージ
- **RAISE_APPLICATION_ERROR(番号, メッセージ)**：-20000〜-20999 の範囲で独自のエラーを返す

例外の発生・捕捉・ユーザー定義例外・再送出の実行例は、[例外処理の学習スクリプト](sql/05_exception/01_exception_handling.sql)を参照してください。参考：Oracle公式 [例外処理](https://docs.oracle.com/en/database/oracle/oracle-database/26/lnpls/overview-exception-handling.html)。

---

## 9. プロシージャ（手続き）

名前を付けて保存するPL/SQLブロックで、パラメータを使って呼び出します。値を返すことは必須ではありません。

- **作成**：`CREATE OR REPLACE PROCEDURE 名前 (引数) IS ... BEGIN ... END;`
- **実行**：`EXECUTE 名前(値);`、またはPL/SQLブロック内から名前を直接書いて呼び出す
- **削除**：`DROP PROCEDURE 名前;`

### パラメータのモード

| モード | 方向 | 特徴 |
|---|---|---|
| IN（既定） | 呼び出し元 → 中 | 値の受け渡しのみ。中で変更不可 |
| OUT | 中 → 呼び出し元 | 結果を返す。変数を渡す必要あり |
| IN OUT | 両方向 | 値を受け取り、変更して返す |

```sql
CREATE OR REPLACE PROCEDURE query_emp
  (v_id IN emp.empno%TYPE, v_name OUT emp.ename%TYPE)
IS
BEGIN
  SELECT ename INTO v_name FROM emp WHERE empno = v_id;
END;
/

-- 呼び出し例（バインド変数を使用）
VARIABLE g_name VARCHAR2(15)
EXECUTE query_emp(7654, :g_name)
PRINT g_name
```

この章の実行例（IN/OUT、例外、社員の表示・削除、部署の追加）：[プロシージャの学習スクリプト](sql/06_subprogram/01_procedure.sql)。実行前に [テストデータ](sql/01_basics/01_test_data.sql) を作成してください。

---

## 10. ファンクション（関数）

値を計算して1つの値を必ず返すPL/SQLブロックです。

- ヘッダーに `RETURN 型` が必要で、本体に `RETURN` 文が必要です。
- **SQL文の中で呼び出せる**（SELECT・WHERE・VALUES・SET句など）のが大きな特徴です。
- **SQL文から呼び出す場合の制限**：SQLから渡せるのはIN引数で、関数は表の更新など副作用を起こさないようにします。SQL文から呼ぶときはSQLで使用できる型を使います。

```sql
CREATE OR REPLACE FUNCTION get_sal (v_id IN emp.empno%TYPE)
  RETURN NUMBER
IS
  v_salary emp.sal%TYPE := 0;
BEGIN
  SELECT sal INTO v_salary FROM emp WHERE empno = v_id;
  RETURN v_salary;
END;
/

SELECT ename, get_sal(empno) FROM emp;   -- SQL内で利用
```

指定された練習問題を含む実行例（合計、昇給額、年俸、名前のマスキング）：[ファンクションの学習スクリプト](sql/06_subprogram/02_function.sql)。

### プロシージャとファンクションの違い

| 項目 | プロシージャ | ファンクション |
|---|---|---|
| 呼び出し方 | PL/SQL文として単独で実行 | 式の一部として使用（SQL内でも可） |
| 戻り値 | なし、またはOUTで複数返せる | RETURNで1つ返す（必須） |
| 主な用途 | 処理の実行（更新・登録など） | 計算・値の取得 |

**サーバー側に保存（ストアド）しておく利点**
- 性能向上（解析済みのコードを再利用）
- 保守性向上（修正が1か所で済む）
- セキュリティ向上（権限を与えて間接的にアクセスさせられる）

---

## 11. パッケージ（関連する部品をまとめる）

関連する変数・型・プロシージャ・ファンクションを1つにまとめる仕組みです。

- **仕様部（Specification）**：外部に公開する部分（インターフェース）
- **本体部（Body）**：公開部分の実装と、非公開（PRIVATE）の処理を書く部分
- 非公開の処理は外部から呼べず、中身も隠せます（**情報隠蔽**）。
- パッケージの変数はセッション中保持され、初回参照時にメモリへ読み込まれます。
- **オーバーロード**：同じ名前で、引数の数・順番・型が異なる処理を複数定義できます（戻り値型だけの違いは不可）。

```sql
CREATE OR REPLACE PACKAGE comm_package IS          -- 仕様部
  g_comm NUMBER := 10;                             -- 公開変数
  PROCEDURE reset_comm(v_comm IN NUMBER);          -- 公開プロシージャ
END comm_package;
/

CREATE OR REPLACE PACKAGE BODY comm_package IS     -- 本体部
  FUNCTION validate_comm(v_comm IN NUMBER) RETURN BOOLEAN IS  -- 非公開
    v_max NUMBER;
  BEGIN
    SELECT MAX(comm) INTO v_max FROM emp;
    RETURN v_comm <= v_max;
  END;

  PROCEDURE reset_comm(v_comm IN NUMBER) IS
  BEGIN
    IF validate_comm(v_comm) THEN
      g_comm := v_comm;
    ELSE
      RAISE_APPLICATION_ERROR(-20210, '不正な手数料');
    END IF;
  END;
END comm_package;
/

EXECUTE comm_package.reset_comm(1500);   -- 呼び出し
```

- **削除**：`DROP PACKAGE 名前;`（仕様部と本体部の両方）、`DROP PACKAGE BODY 名前;`（本体部のみ）

仕様部・本体部、公開／非公開処理、オーバーロード、パッケージ変数の例：[パッケージの学習スクリプト](sql/07_package/01_package.sql)。

---

## 12. トリガー（自動実行の仕組み）

`INSERT` / `UPDATE` / `DELETE` などのイベントが発生したときに、自動で実行されるPL/SQLブロックです。

- **用途**：監査ログの記録、データ整合性チェック、入力ルールの強制など
- **注意**：多用すると依存関係が複雑になり保守が難しくなります。必要な場面に限定しましょう。

| 構成要素 | 内容・選択肢 |
|---|---|
| タイミング | `BEFORE`（実行前） / `AFTER`（実行後） / `INSTEAD OF`（ビュー用：代わりに実行） |
| イベント | `INSERT` / `UPDATE [OF 列]` / `DELETE`（`OR` で複数指定可） |
| レベル | **文（Statement）トリガー**：1文につき1回 ／ **行（Row）トリガー**：`FOR EACH ROW` 指定、影響を受けた行ごとに1回 |
| 行の値 | `:OLD`（変更前）、`:NEW`（変更後）。WHEN句では `:` を付けない |
| 条件述語 | `INSERTING` / `UPDATING` / `DELETING` で処理を振り分け |

```sql
CREATE OR REPLACE TRIGGER derive_commission_pct
  BEFORE INSERT OR UPDATE OF sal ON emp
  FOR EACH ROW
  WHEN (NEW.job = 'SALESMAN')
BEGIN
  IF INSERTING THEN
    :NEW.comm := 0;
  ELSE
    :NEW.comm := :OLD.comm * (:NEW.sal / :OLD.sal);
  END IF;
END;
/
```

- **例**：AFTER行トリガーで `emp` テーブルの変更内容を `audit_emp_table` に記録すると、「誰が・いつ・何を変更したか」を追跡できます。
- **管理用ビュー**：`USER_TRIGGERS` で定義内容と状態（STATUS）を確認できます。
- **有効化・無効化**：`ALTER TRIGGER 名前 ENABLE | DISABLE;`、テーブル単位では `ALTER TABLE 表名 ENABLE ALL TRIGGERS;`
- **削除**：`DROP TRIGGER 名前;`

BEFORE/AFTER、行／文トリガー、`:OLD` / `:NEW`、監査ログの練習：[トリガーの学習スクリプト](sql/08_trigger/01_trigger.sql)。このスクリプトは専用のデモ表を作成し、同名のデモ表があれば削除して作り直します。

---

## 13. トランザクション制御（TCL）と権限制御（DCL）

| 命令 | 役割 |
|---|---|
| COMMIT | 現在のトランザクションの変更を確定する。他のセッションからも見えるようになり、ロックも解放される |
| ROLLBACK | 最後のCOMMIT以降の変更をすべて取り消す。ロックも解放される |
| SAVEPOINT 名前 | 作業の途中に目印を付ける |
| ROLLBACK TO SAVEPOINT 名前 | 目印の時点まで戻す。目印より前の変更は残る |
| SET TRANSACTION READ ONLY | 読み取り専用のトランザクションを開始する（変更はできない）

```sql
SET SERVEROUTPUT ON;

DECLARE
  v_balance NUMBER;
  e_insufficient EXCEPTION:
BEGIN
  SELECT balance INTO v_balance FROM accounts WHERE account_id = 'A' FOR UPDATE;

  IF v_balance < 1000 THEN
    RAISE e_insufficient;
  END IF;

  UPDATE accounts SET balance = balance - 1000 WHERE account_id = 'A';
  SAVEPOINT after_withdraw;

  UPDATE accounts SET balance = balance + 1000 WHERE account_id = 'B';

  COMMIT;
EXCEPTION
  WHEN e_insufficient THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, '残高不足');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
```

| 命令 | 役割 |
|---|---|
| GRANT | 権限を与える |
| REVOKE | 権限を取り消す |

権限の種類
- オブジェクト権限：特定のオブジェクトに対する操作権限（SELECT・INSERT・UPDATE・DELETE・EXECUTEなど）
- システム権限：データベース全体に関わる操作の権限（CREATE TABLE・CREATE SESSIONなど）

```sql
-- オブジェクト権限
GRANT SELECT, INSERT ON accounts TO app_user;

-- 別のユーザーに権限を再付与できる権限も付ける
GRANT UPDATE ON accounts TO app_user WITH GRANT OPTION;

-- プロシージャの実行権限だけを与える（テーブルへの直接アクセスは不要）
-- 実際の現場ではテーブルへの直接アクセスができない
-- 会社のデータベースを操作したら大きな問題になる
GRANT EXECUTE ON transfer_funds TO app_user;

-- システム権限
GRANT CREATE TABLE TO app_user;

-- 取り消し
REVOKE INSERT ON accounts FROM app_user;
```

ロール（権限のグループ）
- 多数のユーザーに同じ権限を与える場合は、ロールにまとめて付与すると管理しやすくなります。

```sql
CREATE ROLE teller_role;
GRANT SELECT, UPDATE ON accounts TO teller_role;
GRANT teller_role TO app_user;
```


## 14. 覚えておきたいポイント（まとめ）

| テーマ | 押さえるポイント |
|---|---|
| 基本 | `DECLARE` / `BEGIN` / `EXCEPTION` / `END`。文末は `;` |
| 変数 | `:=` で代入。`%TYPE`・`%ROWTYPE` で列の型に合わせる |
| SELECT INTO | 必ず1行。0行・複数行は例外になる |
| 複数行の処理 | カーソル（OPEN→FETCH→CLOSE）またはカーソルFORループ |
| 例外 | `WHEN OTHERS` は最後に1つだけ。`ROLLBACK` も忘れずに |
| 格納モジュール | プロシージャ（処理）、ファンクション（値を返す・SQL内で使用可）、パッケージ（まとめて管理） |
| トリガー | DML時に自動実行。乱用は避ける |

---

> ※ 本まとめは原典の内容を日本語に訳し、学習しやすいように要点を抜粋・整理したものです。例のコードは一部簡略化しています。実際の開発ではOracleのバージョンに応じた公式ドキュメントも確認してください。
