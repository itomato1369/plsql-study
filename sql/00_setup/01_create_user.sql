-- ------------------------------------------------------------
-- XEからXEPDB1に切り替える一般的に学習ようではXEPDB1で作業
-- ------------------------------------------------------------
ALTER SESSION SET CONTAINER = XEPDB1;
-- ユーザーを生成
CREATE USER "ユーザー" IDENTIFIED BY "パスワード"
    DEFAULT TABLESPACE users
    QUOTA UNLIMITED ON users;
-- 一般ユーザーに権限を付与する
GRANT 
    CREATE SESSION, -- データベースへの接続を許可する（これがないとログインできない）
    CREATE TABLE, -- テーブルを作成できるようにする
    CREATE VIEW, -- ビューを作成できるようにする
    CREATE PROCEDURE, -- プロシージャ・ファンクション・パッケージを作成できるようにする
    CREATE TRIGGER, -- トリガーを作成できるようにする
    CREATE SEQUENCE -- シーケンス（連番を発行する仕組み）を作成できるようにする
TO "ユーザー";
-- ユーザーを確認
-- account_statusが'OPEN'と表示されれば完了
SELECT username, account_status
FROM dba_users
WHERE username = 'ユーザー';
