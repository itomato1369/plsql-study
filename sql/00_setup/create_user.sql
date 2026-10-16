-- XEからXEPDB1に切り替える
ALTER SESSION SET CONTAINER = XEPDB1;
-- kensyuユーザーを生成
CREATE USER kensyu IDENTIFIED BY kensyu
    DEFAULT TABLESPACE users
    QUOTA UNLIMITED ON users;
-- 一般ユーザーに権限を付与する
GRANT 
    CREATE SESSION, 
    CREATE TABLE, 
    CREATE VIEW, 
    CREATE PROCEDURE,
    CREATE TRIGGER,
    CREATE SEQUENCE
TO kensyu;
-- ユーザーkensyuを確認
-- account_statusが'OPEN'と表示されれば完了
SELECT username, account_status
FROM dba_users
WHERE username = 'KENSYU';
