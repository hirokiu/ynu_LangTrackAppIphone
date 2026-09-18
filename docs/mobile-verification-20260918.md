# モバイル検証とdev版準備（2026-09-18）

## 全体と現在地
保全 → 新環境準備 → proto確認公開まで完了。現在は共同研究者の確認待ちとアプリ実装・検証を並行。最終移行、旧サーバー解約は未実施。

## 今回の確認
- iOS：専用iPhone 16 / iOS 26.4.1シミュレーターにProtoDebugをインストールし、起動とログイン画面を確認。
- Android：KIROKUN_API_37エミュレーターにprotoDebugをインストールし、起動画面からログイン画面への遷移を確認。
- 両OSで英語・日本語のログイン画面、KIROKUN表記を確認。日本語のユーザー名、パスワード、ログイン、説明文が表示された。
- iOSはアプリの言語のみ日本語指定。OSの通知許可ダイアログは英語のまま（OS言語は変更していない）。
- ログイン・Survey取得・回答送信・通知受信は未実施。今回の確認だけで配布可能とは判定しない。
- 既存サーバー・共有Firebase設定・認証アカウントは変更していない。

## dev専用アプリ登録の準備
Firebaseプロジェクトはkirokun-dev。新規登録する識別子はiOS Bundle ID、Android applicationIdともに `com.alchembright.kirokun.dev` とする。これは登録予定値であり、登録済みではない。アプリ名はKIROKUN Devを予定。protoの識別子は維持する。

Firebase ConsoleでAppleアプリとAndroidアプリを追加し、GoogleService-Info.plistとgoogle-services.jsonをそれぞれ取得する。既存proto用設定ファイルへ上書きしない。Googleログイン用にAndroid署名フィンガープリント、iOSのOAuthクライアントとURLスキームの設定も必要。

Web用のFirebase設定だけをモバイル用として流用しない。Firebase登録、識別子分離の実装、起動時のprojectId照合、Googleログイン対応、UIDからAPI利用者IDへの解決、接続確認の順に進める。現状のアプリは旧IDにドメインを付加して認証し、メール文字列から利用者IDを作るため、devのGoogleアカウントでそのまま使用できない。

現在のdev WebはSSHトンネルで利用しており、devドメインの公開を前提にしない。シミュレーター向け接続経路と実機向け経路を別途用意する。既存アプリはRealtime Databaseを接続先以外の連絡先・管理者・チーム情報にも利用するため、dev側のRTDB依存の整理が必要。

## 次の検証
独立devでテストSurveyを用意し、取得・回答・再送・通知タップを確認。proto側は全回答者のUID対応、既存配布版と署名の互換性、未送信回答の引継ぎを確認してから配布・配信を有効化する。
