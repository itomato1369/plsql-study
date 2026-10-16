# セットアップ手順

本リポジトリのSQL・PL/SQLを実行するための、Oracle Database 21c Express Edition（以下 Oracle XE）の環境構築手順です。

## 動作環境

| 項目 | 内容 |
|---|---|
| OS | Windows 11 |
| データベース | Oracle Database 21c Express Edition |
| 接続ツール | Visual Studio Code（Oracle系拡張機能） |

## 1. Oracle XE のインストール

1. Oracle公式サイトから [Oracle Database 21c Express Edition](https://www.oracle.com/jp/database/technologies/xe-downloads.html) のインストーラーをダウンロードします。
2. インストーラーを **管理者として実行** します。
3. 画面の指示に従い、インストールを進めます。
4. 途中で、SYS・SYSTEM などの管理者パスワードを設定します。**このパスワードは必ずメモーしてください。**
5. インストールには時間がかかる場合があります（数十分程度）。完了するまで、PCの電源を切らないようにしてください。

## 2. サービスの起動確認

インストール後、次の2つのサービスが「実行中」になっているか確認します。

- `OracleServiceXE`
- `OracleXETNSListener`

## 3. VSCodeでのOracleデータベース接続

VSCodeからOracle XEに接続するには、Oracle用の拡張機能を使います。以下は、VSCodeを初めて使う場合の手順です。

### 3-1. 拡張機能をインストールする

1. VSCodeを開き、右のアクティビティバーの「拡張機能」(または`Ctrl + Shift + X`)をクリックします。
2. 検索欄に `Database Client`または`Oracle SQL Developer for VSCode`を入力します。
3. Oracleデータベースに接続するための拡張機能を選び、「インストール」をクリックします。
4. インストール後、必要に応じてVSCodeを再起動します。

### 3-2. Java (JDK)をインストールする

拡張機能の中には、Oracleへの接続に **JDBC**（Javaで動く接続ドライバー）を使うものがあります。その場合、Javaが入っていないと「jdbc」に関するエラーが表示されることがあります。

次のコマンドで、JDK 21をインストールします（管理者権限のPowerShellまたはターミナルで実行します）。

```powershell
winget install Microsoft.OpenJDK.21
```

- 初回は、Microsoft Storeの利用規約への同意を求められる場合があります。「Y」を入力して進めてください。
- インストーラーの実行中に、管理者権限の確認画面が表示されることがあります。「はい」を選択してください。
- インストールが完了したら、VSCodeを再起動します。

インストールされたかどうかは、新しいターミナルを開いて次のコマンドで確認できます。

```powershell
java -version
```

`openjdk version "21..."` のように表示されれば、正常にインストールされています。

> `java -version` で「認識されていません」と表示される場合は、VSCodeとターミナルを完全に閉じてから開き直してください。それでも表示されない場合は、拡張機能の設定で Java の場所（JAVA_HOME）を指定する必要があります。`openjdk version "21..."` のように表示されれば、正常にインストールされています。

> `java -version` で「認識されていません」と表示される場合は、VSCodeとターミナルを完全に閉じてから開き直してください。それでも表示されない場合は、拡張機能の設定で Java の場所（JAVA_HOME）を指定する必要があります。

### 3-3. 接続情報を入力する

1. サイドバーのデータベースのアイコンをクリックします。
2. 接続一覧の `+`（新規接続）ボタンをクリックします。
3. 接続の種類で「Oracle」を選択します。
4. 該当する項目に値を入力します。

### 3-4. 接続を確認して保存する

1. 「Test」や「接続」ボタンがある場合は、先に押して接続を確認します。
2. 接続に成功したら「Save」（保存）をクリックします。
3. 保存後は、接続一覧から選ぶだけで接続できます。