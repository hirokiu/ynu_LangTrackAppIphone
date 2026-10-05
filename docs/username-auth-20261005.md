# iOS ユーザー名認証対応（2026-10-05）

## 接続と互換性

- Protoは従来のログイン画面を維持。Devは既存Googleログインとユーザー名ログインを選択可能。
- `/api/auth/options` の usernameLogin が true なら、ユーザー名・パスワードを `/api/auth/username-login` に送信し、返却されたcustomTokenでFirebaseへサインインする。
- username-login が401の場合のみ、未移行利用者向けの従来Firebase認証を試す。429、503、接続障害、不正な成功応答では切り替えない。
- options正常falseまたは404（旧版）は従来方式。その他のoptions障害では失敗扱い。メール入力は従来Firebase方式。
- パスワードをtrimしない。トークン・パスワード・Firebase認証結果全体をログへ出さない。
- ログイン完了後と起動時、Dev/Protoとも `/api/me` のuserIdを使用。Firebase email前半を回答・通知用IDとして推測しない。
- `/api/me`失敗時はログイン画面を閉じず、回答画面へ進ませない。新規ログイン直後の失敗はFirebaseセッションを終了する。
- DevのPush登録停止は維持。既存Protoの通知topicは取得したuserIdを用いる。

## 導入順と未確認

1. APIの`/api/me`と認証オプション、旧利用者を含むUID対応を先に検証・配備。
2. Devで既存/新規/移行済み利用者、誤PW、サービス停止、再起動、Google連携、回答を確認。
3. Proto対応アプリを配布・更新したあと、対象2名の旧password providerを削除。

今回、実Firebaseの利用者や公開APIは変更していない。実接続によるログイン、回答、Push受信・タップは未検証。招待・再設定はWebで提供し、アプリ内フォームは増やしていない。ProtoのネイティブGoogleログイン入口追加は別途対応が必要（Devでは既存Google入口を維持）。

## 検証記録

- DevDebug、ProtoDebugのシミュレーター向けビルド成功。
- iOS 18.0 / iPhone SE (3rd generation) で`testAuthenticationOptionsFailClosed`成功。options有効・無効・404互換・401/429/503/通信失敗/不正応答の分岐を検証。実認証通信を置き換えるテストではない。
- 2026-10-05、親タスクの未ログイン読取確認：現行Protoは `/api/me` と `/api/auth/options` が404。Devは `/api/me` が401（実装あり）、optionsが404。**現段階でこのアプリをProto利用者に配布しない。APIを先に更新する必要がある。**
