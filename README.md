# sample-go-mysql-k6-performance-improve
Sample Project that improve database query

あなたはDBクエリパフォーマンス改善に精通したエンジニアです。
以下のプロジェクトを作りたいので、まず、どういうディレクトリ構成にするか提案してください。

要件
- Go言語で書かれたWebアプリケーション(echoフレームワーク使用, なるだけシンプルに)
- MySQLを使用(v8以上)
- k6を使った負荷テストシナリオ
- Docker を使って環境構築
- docker composeで一括起動
- シードデータ投入機能 (.shファイルなどで簡単に実行できる)

前提条件（想定）

Todoアプリ

ユーザー数：10万

Todo件数：1ユーザーあたり平均100件（合計1,000万件想定）

よくある操作

自分のTodo一覧取得

ステータスで絞り込み

期限順で並び替え

初期設計の方針（あえて悪くする）

正規化しすぎない

インデックスを極力貼らない

曖昧な型を使う

検索条件と合わない設計にする

テーブル設計（わざと遅い）
users テーブル
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  email VARCHAR(255),
  created_at DATETIME
);


問題点

email に一意制約なし

検索用インデックスなし

todos テーブル（遅さの主役）
CREATE TABLE todos (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  title VARCHAR(255),
  description TEXT,
  status VARCHAR(50),
  due_date VARCHAR(50),
  created_at DATETIME,
  updated_at DATETIME
);


意図的な問題点

user_id にインデックスなし

status が文字列

due_date が文字列（並び替え不可）

複合インデックスなし

外部キー制約なし

想定する「遅い」クエリ
Todo一覧取得（典型）
SELECT *
FROM todos
WHERE user_id = 12345
  AND status = 'in_progress'
ORDER BY due_date
LIMIT 50 OFFSET 0;


この時点で起きること

全件走査が発生

並び替えで一時領域使用

件数増加で急激に遅くなる

負荷を増幅させる仕掛け

description に長文テキストを入れる

status の種類を増やす

due_date を不揃いな文字列形式にする
例: 2025/1/2, 2025-01-02, Jan 2 2025

これにより

インデックスが貼りにくい

並び替えのコストが跳ねる

この設計で検証できること

インデックスなしの恐怖

型設計の重要性

ORDER BY の重さ

LIMIT があっても遅い理由

データ量増加による非線形な劣化
