-- ============================================================
-- PL/SQL トリガーの練習
-- このスクリプトは専用のtrigger_demo_*表を作り直します。
-- 同じ名前の既存学習用表がある場合、その表のデータは削除されます。
-- DDLは暗黙COMMITするため、未確定の作業がない学習用接続で実行してください。
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- 専用デモ表があれば削除して、繰り返し実行できるようにする
-- ------------------------------------------------------------
BEGIN
  FOR t IN (
    SELECT table_name
    FROM   user_tables
    WHERE  table_name IN ('TRIGGER_DEMO_AUDIT', 'TRIGGER_DEMO')
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

CREATE TABLE trigger_demo (
  item_id    NUMBER        CONSTRAINT pk_trigger_demo PRIMARY KEY,
  item_name  VARCHAR2(30)  NOT NULL,
  amount     NUMBER(9, 2)  NOT NULL,
  created_at TIMESTAMP     NOT NULL
);

CREATE TABLE trigger_demo_audit (
  audit_id   NUMBER GENERATED ALWAYS AS IDENTITY
             CONSTRAINT pk_trigger_demo_audit PRIMARY KEY,
  item_id    NUMBER,
  action     VARCHAR2(10)  NOT NULL,
  old_amount NUMBER(9, 2),
  new_amount NUMBER(9, 2),
  action_at  TIMESTAMP     NOT NULL
);

-- ------------------------------------------------------------
-- BEFORE行トリガー：入力値を検証し、作成日時を設定する
-- :NEWはINSERTされる値、UPDATE後の値を表します。
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_demo_before_row
  BEFORE INSERT OR UPDATE ON trigger_demo
  FOR EACH ROW
BEGIN
  IF :NEW.amount <= 0 THEN
    RAISE_APPLICATION_ERROR(-20021, '金額には0より大きい値を指定してください');
  END IF;

  IF INSERTING THEN
    :NEW.created_at := SYSTIMESTAMP;
  END IF;
END;
/

-- ------------------------------------------------------------
-- AFTER行トリガー：各行のINSERT/UPDATE/DELETEを監査表に記録する
-- DELETEでは:OLD、INSERTでは:NEWを使います。
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_demo_audit_row
  AFTER INSERT OR UPDATE OR DELETE ON trigger_demo
  FOR EACH ROW
DECLARE
  v_action VARCHAR2(10);
BEGIN
  IF INSERTING THEN
    v_action := 'INSERT';
    INSERT INTO trigger_demo_audit (
      item_id, action, old_amount, new_amount, action_at
    )
    VALUES (
      :NEW.item_id, v_action, NULL, :NEW.amount, SYSTIMESTAMP
    );
  ELSIF UPDATING THEN
    v_action := 'UPDATE';
    INSERT INTO trigger_demo_audit (
      item_id, action, old_amount, new_amount, action_at
    )
    VALUES (
      :NEW.item_id, v_action, :OLD.amount, :NEW.amount, SYSTIMESTAMP
    );
  ELSIF DELETING THEN
    v_action := 'DELETE';
    INSERT INTO trigger_demo_audit (
      item_id, action, old_amount, new_amount, action_at
    )
    VALUES (
      :OLD.item_id, v_action, :OLD.amount, NULL, SYSTIMESTAMP
    );
  END IF;
END;
/

-- ------------------------------------------------------------
-- AFTER文トリガー：UPDATE文につき1回実行（行単位ではない）
-- 文トリガーでは:OLD / :NEWを参照できません。
-- ------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_demo_after_update_stmt
  AFTER UPDATE ON trigger_demo
BEGIN
  DBMS_OUTPUT.PUT_LINE('UPDATE文が完了しました');
END;
/

-- ------------------------------------------------------------
-- 動作確認：行トリガー、文トリガー、監査記録を確認する
-- ------------------------------------------------------------
INSERT INTO trigger_demo (item_id, item_name, amount, created_at)
VALUES (1, 'ノート', 250, SYSTIMESTAMP);

INSERT INTO trigger_demo (item_id, item_name, amount, created_at)
VALUES (2, 'ペン', 120, SYSTIMESTAMP);

UPDATE trigger_demo
SET amount = amount + 30
WHERE item_id IN (1, 2);

DELETE FROM trigger_demo
WHERE item_id = 2;

SELECT item_id, item_name, amount, created_at
FROM   trigger_demo
ORDER BY item_id;

SELECT audit_id, item_id, action, old_amount, new_amount, action_at
FROM   trigger_demo_audit
ORDER BY audit_id;

-- INSERT後のcreated_atはBEFORE行トリガーが設定し、
-- 監査表にはINSERT 2件、UPDATE 2件、DELETE 1件が記録されます。

-- ------------------------------------------------------------
-- 入力チェックを確認する（意図的にエラーになるため個別に実行）
-- ------------------------------------------------------------
-- INSERT INTO trigger_demo (item_id, item_name, amount, created_at)
-- VALUES (3, '不正な金額', 0, SYSTIMESTAMP);
-- 期待する結果: ORA-20021

-- ------------------------------------------------------------
-- 練習後の片付け（監査ログも含め、今回の変更を取り消す）
-- ------------------------------------------------------------
ROLLBACK;

-- トリガーの定義・デモ表は残ります。定義は次で確認できます。
SELECT trigger_name, triggering_event, trigger_type, status
FROM   user_triggers
WHERE  trigger_name IN (
  'TRG_DEMO_BEFORE_ROW',
  'TRG_DEMO_AUDIT_ROW',
  'TRG_DEMO_AFTER_UPDATE_STMT'
)
ORDER BY trigger_name;

-- 練習
-- 1. UPDATEのWHERE句を外し、文トリガーの出力が1回であることを確認する。
-- 2. UPDATEを2文に分け、文トリガーが文ごとに実行されることを確認する。
-- 3. trg_demo_audit_rowを一時的に無効化し、監査表への記録を比較する。
--    ALTER TRIGGER trg_demo_audit_row DISABLE;
--    ALTER TRIGGER trg_demo_audit_row ENABLE;
-- 4. 読み取り専用のビューに対するINSTEAD OFトリガーも調べてみる。
