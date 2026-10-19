-- ============================================================
-- GRANTで付与できる権限の一覧（コメントとして記載）
-- 「ユーザー」の部分は付与先のユーザー名に置き換えてください
-- 実行はしないでください（すべてコメント）
-- ============================================================

-- ------------------------------------------------------------
-- 【1】システム権限（データベース全体に関わる権限）
-- 書式：GRANT 権限名 TO ユーザー;
-- ------------------------------------------------------------

-- ■ 接続・セッション
-- GRANT CREATE SESSION TO ユーザー;            -- データベースへの接続を許可（これがないとログインできない）
-- GRANT ALTER SESSION TO ユーザー;             -- ALTER SESSION文（NLS設定、CONTAINERの切り替えなど）を許可

-- ■ テーブル
-- GRANT CREATE TABLE TO ユーザー;              -- 自分のスキーマにテーブルを作成
-- GRANT CREATE ANY TABLE TO ユーザー;          -- 他のスキーマにもテーブルを作成（※強い権限）
-- GRANT ALTER ANY TABLE TO ユーザー;           -- 他のスキーマのテーブルを変更（※強い権限）
-- GRANT DROP ANY TABLE TO ユーザー;            -- 他のスキーマのテーブルを削除（※強い権限）
-- GRANT SELECT ANY TABLE TO ユーザー;          -- 他のスキーマのテーブルを参照（※強い権限）
-- GRANT INSERT ANY TABLE TO ユーザー;          -- 他のスキーマのテーブルに追加（※強い権限）
-- GRANT UPDATE ANY TABLE TO ユーザー;          -- 他のスキーマのテーブルを更新（※強い権限）
-- GRANT DELETE ANY TABLE TO ユーザー;          -- 他のスキーマのテーブルから削除（※強い権限）

-- ■ ビュー
-- GRANT CREATE VIEW TO ユーザー;               -- 自分のスキーマにビューを作成
-- GRANT CREATE ANY VIEW TO ユーザー;           -- 他のスキーマにもビューを作成
-- GRANT DROP ANY VIEW TO ユーザー;             -- 他のスキーマのビューを削除

-- ■ シーケンス（連番）
-- GRANT CREATE SEQUENCE TO ユーザー;           -- 自分のスキーマにシーケンスを作成
-- GRANT CREATE ANY SEQUENCE TO ユーザー;       -- 他のスキーマにもシーケンスを作成
-- GRANT SELECT ANY SEQUENCE TO ユーザー;       -- 他のスキーマのシーケンスを参照

-- ■ プロシージャ・ファンクション・パッケージ
-- GRANT CREATE PROCEDURE TO ユーザー;          -- 自分のスキーマにプロシージャ・ファンクション・パッケージを作成
-- GRANT CREATE ANY PROCEDURE TO ユーザー;      -- 他のスキーマにも作成
-- GRANT ALTER ANY PROCEDURE TO ユーザー;       -- 他のスキーマのプロシージャを変更
-- GRANT DROP ANY PROCEDURE TO ユーザー;        -- 他のスキーマのプロシージャを削除
-- GRANT EXECUTE ANY PROCEDURE TO ユーザー;     -- 他のスキーマのプロシージャを実行（※強い権限）

-- ■ トリガー
-- GRANT CREATE TRIGGER TO ユーザー;            -- 自分のスキーマにトリガーを作成
-- GRANT CREATE ANY TRIGGER TO ユーザー;        -- 他のスキーマにもトリガーを作成
-- GRANT ALTER ANY TRIGGER TO ユーザー;         -- 他のスキーマのトリガーを変更
-- GRANT DROP ANY TRIGGER TO ユーザー;          -- 他のスキーマのトリガーを削除

-- ■ インデックス・同義語（別名）・型
-- GRANT CREATE ANY INDEX TO ユーザー;          -- 他のスキーマにインデックスを作成
-- GRANT CREATE SYNONYM TO ユーザー;            -- 自分用の同義語（別名）を作成
-- GRANT CREATE PUBLIC SYNONYM TO ユーザー;     -- 全ユーザー共通の同義語を作成（※強い権限）
-- GRANT CREATE TYPE TO ユーザー;               -- ユーザー定義型（オブジェクト型など）を作成

-- ■ マテリアライズドビュー
-- GRANT CREATE MATERIALIZED VIEW TO ユーザー;  -- マテリアライズドビューを作成

-- ■ データベースリンク（別のDBへの接続）
-- GRANT CREATE DATABASE LINK TO ユーザー;      -- データベースリンクを作成

-- ■ 表領域（保存領域）
-- GRANT UNLIMITED TABLESPACE TO ユーザー;      -- 全表領域の容量制限を解除（※強い権限）
-- GRANT CREATE TABLESPACE TO ユーザー;         -- 表領域を作成（※管理者向け）

-- ■ ユーザー・ロール・権限の管理（管理者向け）
-- GRANT CREATE USER TO ユーザー;               -- ユーザーを作成（※強い権限）
-- GRANT ALTER USER TO ユーザー;                -- ユーザーを変更（※強い権限）
-- GRANT DROP USER TO ユーザー;                 -- ユーザーを削除（※強い権限）
-- GRANT CREATE ROLE TO ユーザー;               -- ロールを作成
-- GRANT GRANT ANY PRIVILEGE TO ユーザー;       -- 任意のシステム権限を付与（※強い権限）
-- GRANT GRANT ANY ROLE TO ユーザー;            -- 任意のロールを付与（※強い権限）
-- GRANT SELECT ANY DICTIONARY TO ユーザー;     -- データディクショナリ（DBA_*ビューなど）を参照


-- ------------------------------------------------------------
-- 【2】オブジェクト権限（特定のテーブルなどに対する権限）
-- 書式：GRANT 権限名 ON 対象オブジェクト TO ユーザー;
-- ------------------------------------------------------------

-- GRANT SELECT ON 表名 TO ユーザー;             -- 参照（SELECT）
-- GRANT INSERT ON 表名 TO ユーザー;             -- 追加（INSERT）
-- GRANT UPDATE ON 表名 TO ユーザー;             -- 更新（UPDATE）
-- GRANT UPDATE (列名) ON 表名 TO ユーザー;      -- 特定の列だけ更新
-- GRANT DELETE ON 表名 TO ユーザー;             -- 削除（DELETE）
-- GRANT ALTER ON 表名 TO ユーザー;              -- 表の定義変更（ALTER TABLE）
-- GRANT INDEX ON 表名 TO ユーザー;              -- インデックスの作成
-- GRANT REFERENCES ON 表名 TO ユーザー;         -- 外部キー制約の参照設定
-- GRANT ALL ON 表名 TO ユーザー;                -- 上記すべて（※必要最小限にすること）
-- GRANT EXECUTE ON プロシージャ名 TO ユーザー; -- プロシージャ・ファンクション・パッケージの実行
-- GRANT SELECT ON シーケンス名 TO ユーザー;    -- シーケンスの値の取得（NEXTVAL / CURRVAL）

-- ■ 他のユーザーに再付与できる権限を付ける場合
-- GRANT SELECT ON 表名 TO ユーザー WITH GRANT OPTION;


-- ------------------------------------------------------------
-- 【3】ロール（権限のまとまり）
-- 書式：GRANT ロール名 TO ユーザー;
-- ------------------------------------------------------------

-- GRANT CONNECT TO ユーザー;     -- 接続用の基本ロール（CREATE SESSIONなど）
-- GRANT RESOURCE TO ユーザー;    -- 開発用ロール（CREATE TABLEなど）。古いバージョンでの利用が中心
-- GRANT DBA TO ユーザー;         -- 管理者ロール（※学習用ユーザーには付与しない）


-- ------------------------------------------------------------
-- 【4】すべてのシステム権限を確認する方法
-- ------------------------------------------------------------

-- SELECT name FROM system_privilege_map ORDER BY name;
-- ※ 使用できる権限名を、バージョンに合わせて一覧表示します


-- ------------------------------------------------------------
-- 【注意】
-- ・「※強い権限」は、他のユーザーのデータにも影響するため、学習用ユーザーには付与しないでください。
-- ・学習用ユーザーには、CREATE SESSION、CREATE TABLE、CREATE VIEW、CREATE PROCEDURE、
--   CREATE TRIGGER、CREATE SEQUENCE の6つで十分です。
-- ・DBAロールは、学習用ユーザーには付与しないでください。
-- ============================================================
