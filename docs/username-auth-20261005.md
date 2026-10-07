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

## 実Firebase・Dev APIへの統合テスト（2026-10-06）

専用iPhone SE (3rd generation)／iOS 18.0シミュレーターで
`testInvitedAccountAgainstDev`成功。実アプリのKirokunAccountSessionと
SurveyRepositoryを使用し、招待QAユーザー名認証→Firebaseサインイン→
/me本人識別→Survey取得→日本語の回答送信→再取得した回答一致を確認。
サーバーDBでも保存値を確認し、QA専用Assignmentを削除した。
既存の上松さんのシミュレーターとGoogleセッションは変更していない。

テストは専用DevシミュレーターのDocuments/kirokun-private-qa.jsonがない場合はskip。
DevのBundle ID、Firebase projectID、ローカルAPI URLを検査し、他のUIDでログイン済みなら拒否。
ファイルはサーバーのQA情報にiosAssignmentを加えた文字列辞書で、Gitへ保存しない。
試験後はサインアウトし、ファイルも削除。テストログへ秘密値を出さない。

これはSDKと通信・保存の統合テストで、画面をタップするUIテストやPush受信試験ではない。
Devは端末登録・topic購読停止を維持。Protoには/meと全利用者のUID対応が未反映のため、
引き続き一般利用者へ配布しない。Google追加連携の実操作はユーザー指定で後日。

## 通知の事前修正（2026-10-06）

UNUserNotificationCenterDelegateのwillPresentに前面通知処理を追加。
アプリを開いているときも標準バナー・通知センター・音を使い、Survey一覧の更新を通知する。
ProtoDebugシミュレータービルド成功。実APNs/FCMの受信、通知タップは未確認。
DevのPush登録停止は維持。ユーザーは実機を後で接続する予定。
配布・既存利用者への通知・稼働サーバーの設定変更は行っていない。

## iPhone実機Pushの準備（2026-10-06）

DevDebugで明示的な起動引数`--kirokun-push-qa`を付けた場合だけ、Dev Firebase／
Dev Bundle IDを検査して通知登録を許可する。ProtoとReleaseは同引数を無視する。
通常Dev起動ではMessagingの自動登録を停止し、既存のサーバー端末登録・topic購読停止を維持。
検証トークンとQAマーカー付き通知の受信・タップ記録は、バックアップ対象外・保護付きの
アプリDocuments内ファイルへ保存し、ログへトークンを出さない。

iPhone11 Pro/iOS26.6へ署名付きDevアプリを配置し、本人の通知許可とトークン取得を確認。
Dev Firebaseからそのトークン1件へ送信したが、messaging/third-party-auth-errorで拒否された。
ユーザーがkirokun-devのAPNsキー未登録を確認し、設定作業中。実受信は未確認。
設定完了後に1台限定で再送する。QAトークンはMacと新サーバーの非公開一時ファイルで保持。
完了後に削除し、検証引数なしで再起動する。ProtoDebugビルドも成功。

今回はPushの検証のみ。iPhoneのDevDebug APIはlocalhostのままであり、実機からDev APIへ
ログイン・回答する経路の準備と通し確認は別途必要。既存Protoアプリは変更していない。


## iPhone実機Push確認完了（2026-10-06追記）

APNsキー登録後、iPhone 11 Pro / iOS 26.6のKIROKUN DevでFCM送信成功、
前面受信（22:56:47 JST）、背景の通知タップ（22:58:59 JST）をアプリ記録で確認。
本人も通知からKIROKUN Devが開くことを確認した。
DevDebug専用の `--kirokun-push-qa-cleanup` で一時FCMトークンを失効し、
端末内QAファイルを削除。23:02:34 JSTの完了記録を確認し、通常起動へ戻した。
Mac・新サーバーの一時トークンファイルも削除済み。
Android実機と合わせ、単一Dev端末への通知受信・タップ起動確認が完了。
通常の通知スケジューラー、Proto、既存利用者への配信は変更していない。
これはDevの単一端末通知試験であり、実機のログイン→Survey回答、
通知から対象Surveyへの遷移、アプリ終了状態、Proto配信の通し確認は別途必要。
API通知処理の修正は未デプロイ。


## 通知から対象Surveyへの遷移（2026-10-07）

通知にkirokunAssignmentId・kirokunUserId・kirokunEnvironmentを付与。
グループ配信はAssignmentResultsではなく、本人一覧に返る親AssignmentのIDを使用。
アプリはタップ情報をログイン後まで保持（最大1時間）、環境と宛先を照合し、
認証後に取得した本人のSurvey一覧にある対象だけを開く。一度消費した情報は再利用しない。
回答可能なら回答開始、回答済みなら結果、期限切れなら期限情報。見つからない場合は案内。
Androidの前面通知もpayloadを維持し、PendingIntentを通知ごとに分離する。

検証: API TypeScriptビルド、隔離MongoDB＋FCMモックの個人/グループID・送信結果・再試行テスト成功。
Android Dev/Protoビルド成功。OPPOで環境違い・宛先違い・ID形式・期限・一度限り消費テスト成功。
iOS Dev実機ビルド成功。回答済み検証Survey宛のPush1通をDev iPhoneへ送信受付成功。
本人による回答済み画面への遷移確認待ち。通常API配信は未デプロイ・無効のまま。
新サーバーのops/state/push-qa-ios-20261007.jsonとMac非公開一時ファイルに検証トークン保持。
確認後はiOS QA cleanup起動でトークン失効・ファイル削除し、通常起動へ戻すこと。
未回答・期限切れ・削除済みの画面遷移、ログアウトからの復帰、Android実Push遷移は未確認。


## 未回答バッジ（2026-10-07）

共通定義: 公開日時<=現在<期限、datasetなし。同一配信IDの重複は1件。
不正な日付は件数へ含めない。一覧取得成功時に更新し、回答成功後は一覧を再取得。
利用者切替・ログアウトでは消去。通信失敗時には以前の件数が残る場合がある。
iOSは標準setBadgeCountを使用。Androidは低重要度・無音の専用通知にsetNumberを設定し、
通知本文にも件数を表示。数字/点の表示はホームアプリ依存。0件で件数通知を削除。
Androidの一覧取得後は古い個別Survey通知を整理して件数の重複表示を避ける。
通知/バッジの権限は利用者設定を尊重する。

Android Dev/Protoビルドと件数境界の単体テスト成功。OPPOへ配置済み。
iOS Dev実機ビルド成功。件数XCTestは端末ロック解除待ち。
終了中の自動更新・期限到来による自動再計算は今回未対応。サーバーPushへの件数付与も未実装。
現時点で「常にリアルタイムの件数」とは案内しない。実機の数字表示・回答後0件の確認は次の操作。
Androidの前回実Push遷移は本人確認済み、検証トークン失効と一時ファイル削除完了。

### 再接続後のバッジ検証

iPhone 11 ProでtestUnansweredBadgeCount成功（1 test、2026-10-07）。
実機のDev版を通常起動し、上松Devアカウント専用qa_badge_manual_20261007を1件準備。
開始・自由入力・送信確認の3ページと連番を保存後に検査。未回答の個人配信は1件。
本人へ両端末の一覧取得後のアイコン/通知件数確認を依頼中。まだ回答・0件消去は未確認。
通知文面プリセットはユーザー指示により追加せず、既存JSON設定を維持。


### 実機バッジ確認完了（2026-10-07）

検証用Survey `qa_badge_manual_20261007` について、利用者から表示確認を受領。
OPPOでは数字ではなく点のバッジが表示された。続いて「回答後、バッジも消えました」と報告を受領。
Dev DBを読み取り照合し、回答保存済み・回答数1・当該利用者の公開中かつ期限内の個人未回答配信0件を確認した。
回答内容自体は記録していない。検証データの削除やProtoの変更は行っていない。
iOSの件数計算XCTestは接続したiPhone上で成功済み。
この確認は回答後の一覧更新に伴う消去を対象とする。アプリ終了中や期限到来時の自動更新は未対応のまま。


### Proto実機確認の準備（2026-10-07）
Protoサーバーに/meと45名UID対応、更新APIを反映済み。通常通知・配信準備と新規認証モジュールは停止中。
Kirokun-Proto / ProtoDebugのiPhone実機ビルド成功。生成plistで環境proto・HTTPSのProto API・既存Bundle IDを確認し、iPhone 11 Proへ上書き配置・起動成功。
本人に従来アカウントでのログイン・Proto表示・Survey一覧を確認依頼中。回答送信・Proto実Pushはまだ未確認。一般配布は行っていない。

本人がiOS/Androidともにログアウト→従来認証で再ログイン→Proto Survey一覧表示を確認済み。
続いてhiroki_u専用にqa_proto_answer_20261007_ios / qa_proto_answer_20261007_androidを用意。各header/open/footerの3ページ、個人情報不要の端末名入力1問。既存データ変更なし、通常通知停止。回答送信確認待ち。
