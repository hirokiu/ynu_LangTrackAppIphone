# iOS：Proto／Devの切り替えと実機確認

## 最初に開く場所

この改修が入っているのは `consolidation/mobile-migration/ios/Kirokun.xcworkspace`。元のDocuments/git側のコピーではなく、この作業コピーをXcodeで開く。`.xcodeproj`ではなく`.xcworkspace`を選ぶ。

## 切り替えはXcode上部のSchemeで行う

停止ボタンで実行を止め、Xcode上部のアプリ名をクリックしてSchemeを変更し、その右側で実行先を選ぶ。ソース内のURL、Bundle ID、Firebase設定を手で書き換える必要はない。

|目的|Scheme|実行先|接続・認証|
|---|---|---|---|
|今回のProto実機確認|Kirokun-Proto|接続したiPhone|Protoサーバー・従来のID/パスワード|
|開発中の画面・回答確認|Kirokun-Dev|iPhoneシミュレーター|Mac経由のDevサーバー・上松のGoogleログイン|
|旧接続方式の保守|Kirokun|通常は選択しない|旧Firebaseの接続先設定を使用|

アプリ内のプロジェクト選択は、ビルド先の切り替えではない。ProtoとDevはFirebaseもアプリIDも別で、現在はそれぞれのプロジェクトだけを表示する。

- Proto：`com.alchembright.dev.ynu-lta-dev`、Firebase `ynu-lta-dev`、`https://proto.kirokun.alchembright.com/api/`
- Dev：`com.alchembright.kirokun.dev`、Firebase `kirokun-dev`

## 今回：iPhoneにProtoを入れる

1. iPhoneをMacにつなぎ、端末側の「このコンピュータを信頼」を許可する。開発者モードが必要と表示された場合は端末で有効にする。
2. Schemeを **Kirokun-Proto**、実行先をそのiPhoneにする。
3. 署名エラーの場合はアプリのTarget「Kirokun」→ Signing & Capabilitiesで上松の開発者Teamを確認する。Bundle Identifierは変更しない。
4. ▶︎（Run）を押す。`ProtoDebug`が自動的に選ばれる。
5. アプリのプロジェクト表示が **Proto** であることを確認し、従来のアカウントでログインする。
6. 以下の確認項目を試す。送信するとProto側に回答が記録されるため、回答テストには確認用Surveyを使用する。

Protoは既存ストア版と同じアプリIDなので、その端末の既存版を更新・置換する。未送信の回答がある端末では先に状態を確認する。Devの「全入力形式の確認」Surveyは別DBにあり、Protoには自動的には現れない。

## Devの注意点

Runは`DevDebug`を使い、接続先は`http://localhost:18082/api/`。MacのSSHトンネルが必要で、iPhone実機のlocalhostはMacを指さない。この構成のまま実機でDevを実行してもサーバー接続はできない。

DevのArchiveは`DevRelease`で、設定上の接続先は`https://dev.kirokun.alchembright.com/api/`。この経路のモバイル利用と署名・通知は別途検証が必要。実機Dev対応済み、TestFlight配布済みという意味ではない。

## 将来のTestFlight／配布

ProtoはScheme **Kirokun-Proto** のまま、実行先を汎用iOS端末にして Product → Archive。`ProtoRelease`が自動的に選ばれる。ArchiveのBundle ID・バージョン・ビルド番号を確認し、OrganizerからTestFlightにアップロードする。今回はアップロード／配布しない。Devも別Scheme・別アプリ登録で管理し、ProtoのArchiveにDev用Firebase設定を混ぜない。

## 実機で見る箇所

- SE第2・第3世代（375×667ポイント）を優先。初代SEは現行の最低対応OS iOS 17.6の対象外。
- トップ：赤地の白文字、中央のプロジェクト名、回答率の円、緑の回答済み印、未回答の文字と印。
- 回答：長いアンケート名・設問文でも、問題番号と「前へ」「次へ」が読める。
- 5件法：1〜5がすべて見え、端の選択肢も押せる。最小・最大の説明が欠けない。
- 自由入力：キーボード表示中も入力・移動が可能。
- 単一／複数選択・空欄補充：長い選択肢とスクロール。
- スライダー・時間：値と操作部品が切れない。
- 確認：全回答をスクロールで見られ、「前へ」で修正し、「回答を送信」を押せる。
- 通常／大きめの文字設定、ライト／ダークで確認。Push配信は現在停止中のため、画面の実機確認とは別に実施する。

## 今回の確認結果（2026-09-18）

- 赤い帯・モーダル見出し・主要ボタンは、ユーザーの指定により元のアイコン色（#FF5857）＋白文字に戻した。深い赤の背景は採用しない。淡い背景の文字は従来どおり。
- Devの単体テスト3件成功。SE第2・第3世代の幅375ポイント、ヘッダー分を除いた高さ480ポイントで、標準の設問文とリッカート5選択肢・両端説明の領域が画面内かつ次へボタンより上に収まることを検証。
- ProtoDebugビルド成功。Devシミュレーターでトップ、回答開始ヘッダー、開始ボタンの配色を目視確認。
- このレイアウトテストは実際のSE端末、全設問形式、任意の長文、拡大文字設定での確認を代替しない。実機確認はこれから。

## Devアイコンと実機準備（追記）

DevDebug / DevReleaseだけ黄色＋黒い「DEV」表示のAppIcon-Devを使用。Protoと旧ビルドは元のAppIcon-KIROKUNを維持。アプリ内部はDevでも黄色に変更しない。

Devがシミュレーター専用という恒久的な制約はない。現在のDevDebugの接続経路がMac向けであることが制約。別のアプリIDで実機に共存させることは可能だが、今回はiPhone 11 ProにProtoを入れる。

署名時にAppleアカウントのログイン拒否が出る場合、Xcode Settings → Accountsで再認証する。Push Notifications付きの署名プロファイルが必要で、エラー回避のために通知権限を削除しない。

## iPhone 11 Proへの導入結果（2026-09-18）

Appleアカウントの再認証後、Kirokun-Proto / ProtoDebugの実機署名付きビルドに成功。接続したiPhone 11 Proへのインストールとプロセス起動を確認した。接続先はProto、アプリIDは既存版と同一。端末でのログイン・回答・小型端末での表示確認は利用者による次の確認項目。Push配信確認は未実施。
