# TestFlight候補（2026-10-08）

ProtoRelease archive/export成功。2026-10-08 08:00:52 JSTにAppleへのアップロード成功。Apple側の処理開始を確認。処理完了・審査・配布は未確認／未実施。

## アップロード結果

- 同じArchiveからApp Store Connectへアップロード。バージョン2.0.0、ビルド2026100801を維持。
- Xcodeの結果は `Upload succeeded` / `EXPORT SUCCEEDED`（終了コード0）。
- 最終状態は `Uploaded package is processing`。これを審査通過・配布可能と扱わない。
- 上松のブラウザーログイン後、TestFlightのBuild Uploadsで2.0.0 (2026100801)がProcessing、作成時刻Oct 8, 2026 8:00 AMであることを確認。まだビルド詳細リンクは表示されていない。処理完了後に輸出コンプライアンスと外部テスト審査情報を確認する。
- テスターへの招待送信、旧認証の削除、通常通知の有効化は行っていない。

- Scheme Kirokun-Proto / ProtoRelease、ソース40d144f。
- バージョン2.0.0、ビルド2026100801（ビルド時に明示指定）。
- Bundle ID com.alchembright.dev.ynu-lta-dev、最低iOS17.6。
- Proto HTTPS API、Firebase ynu-lta-devを生成IPA内で確認。
- 配布署名: APNs production、get-task-allow=false。
- IPA SHA256: 69211f3930d29b1379ba35d4597575ffa99bfc1236913b998da92a8b69441a60。
- 成果物はリポジトリ外の ../releases/ios/20261008/ にArchiveとexportを保持。

## テスターへの案内案

KIROKUNの新しい管理環境（Proto）へ接続する確認版です。研究者ご自身のユーザー名と新しいパスワードでログインし、既存アンケートの表示、検証用アンケートへの回答、通知からの画面表示をご確認ください。普段の調査にはまだ使用せず、検証用アンケートをお使いください。不具合は端末名、操作、表示内容を上松へお知らせください。

## 配布前・配布後の確認

1. App Store Connectでビルド番号の重複、アプリ情報、輸出コンプライアンス、外部テスト用説明・審査用ログイン情報を確認する。実利用者の認証情報を審査用として渡さず専用アカウントを用意する。
2. Appleへアップロードして処理・検証結果を確認する。Archive/export成功はAppleの審査通過を意味しない。
3. 共同研究者のTestFlight招待先メールを確認して配布する。既存アカウントの新パスワード設定と本人確認を待ち、旧認証は残す。
4. TestFlight版の本番APNs経由の通知も確認する。実機開発署名でのPush成功とは別の確認。
5. 本人のログイン・既存データ・回答・通知が確認できてから旧認証削除を検討する。

GoogleログインのProtoアプリ入口と本人の追加連携は後続。通常通知は停止中。旧サーバー解約は別工程。
