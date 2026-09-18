# devモバイル環境とGoogleログイン（2026-09-18）

## 現在地
保全・新環境準備・protoの共同研究者向け公開済み。共同研究者確認とアプリ開発を並行中。最終移行・旧サーバー解約は未実施。

## 実装
- iOS Kirokun-Dev（DevDebug/DevRelease）、Android dev flavorを追加。Bundle ID/applicationIdはcom.alchembright.kirokun.dev、表示名KIROKUN Dev。protoとは別アプリで認証キャッシュ・ローカルデータも分離。
- 提供されたkirokun-devのモバイル設定を組み込み。Androidは署名登録後の更新版を使用。含むのはアプリ配布用Firebase設定であり、サービスアカウント秘密鍵は含まない。
- iOSはビルド時にFirebase projectId/Bundle IDを検証して構成別にコピー。AndroidはGoogle Servicesプラグインのpackage一致とdev起動時のprojectIdチェック。
- GoogleログインとFirebase認証を実装。認証後、開発サーバーの管理者向けSurvey一覧APIをGETし、UIDマッピングによる許可を確認。応答内容は保存・画面表示しない。転送先リダイレクトは拒否。
- この画面は上松専用の接続確認段階。一般回答者の認証画面ではない。既存回答画面への接続、UIDからuserIdへの解決、Survey取得・回答・通知は未接続。メールの@以前をuserIdとして使う処理へは進めない。
- 日本語/英語の表示、再確認、ログアウト、認証失敗/権限不足/接続失敗の表示に対応。
- devは通知登録と旧Realtime Database経由のメニュー取得を起動しない。既存proto/legacyの動作と共有Firebase値は維持。

## 接続先
DevDebug/devDebugは http://localhost:18082/api/ を使う。MacのSSHトンネルが新サーバーの127.0.0.1:8082へ転送する。Androidエミュレーターはadb reverse tcp:18082 tcp:18082が必要。HTTP許可はdevのlocalhostだけで、外部ネットワークへ平文送信しない。
DevRelease/devReleaseの予定接続先は https://dev.kirokun.alchembright.com/api/ 。現在そのドメインでのモバイル利用準備は未完了。配布用ビルドではない。実機接続には別途経路と署名を整備する。

## 検証
DevDebug/devDebugとProtoDebug/protoDebugのビルド成功。両OSの日本語Googleログイン画面をシミュレーター/エミュレーターで確認。Androidの既存単体テストも実施。生成物でdev/protoの識別子・Firebaseプロジェクト分離を確認。Googleアカウントを使った本人操作と接続成功は未確認。ここは利用者による確認が必要。

## 上松さんによる確認
iOSシミュレーターでKIROKUN Devを開き、Googleボタンから、dev Webの管理者確認に使ったGoogleアカウントでログインする。「Googleログインと開発サーバーの利用権限を確認できました」と表示されれば認証とUIDによる認可が成功。Survey回答はまだ利用できない。
接続失敗の場合はSSHトンネル、権限不足の場合はアカウント/サーバーUIDマッピングを確認する。トークンやパスワードをログやチャットに貼らない。

## Android検証署名
このMacのdebug.keystoreに対応。上松さんがFirebase登録済み。端末や配布署名が変わる場合は追加登録する。
SHA-1: 77:DB:2E:47:32:24:B8:E8:24:F2:84:90:83:89:C8:48:90:E7:72:CE
SHA-256: DE:90:93:B6:CA:B7:95:E8:24:6A:49:EC:4D:C5:17:1C:1F:78:5F:F1:B1:A6:65:3E:7D:8A:BF:10:03:D3:CF:1A

## 実装参照
- https://firebase.google.com/docs/auth/ios/google-signin
- https://firebase.google.com/docs/auth/android/google-signin

## iOSログイン時のKeychainエラー修正
最初のシミュレーター配布はCODE_SIGNING_ALLOWED=NOでビルドしており、Firebase Auth起動時にSecItemCopyMatching(-34018)、ERROR_KEYCHAIN_ERROR(17995)が発生していた。Google側の認証同意完了はアプリ内の認証情報保存成功を意味しない。
シミュレーターもCODE_SIGNING_ALLOWED=YES、CODE_SIGN_IDENTITY=-でビルドし、application-identifierが組み込まれるよう修正。再現防止のビルド手順はscripts/build-dev-simulator.sh。実機配布署名とは別。
認証の失敗表示もGoogle→アプリ、Firebase認証、キャンセルに分離し、診断にはエラードメインとコードのみを記録する。トークンやuserInfoは記録しない。
