# 選択肢スクロール時の設問文の黒化

## 再現
Protoの「Survey アンケート2601」の設問JSONのみをDevへ複製。既存回答・利用者情報はコピーせず、Protoは変更なし。Dev Survey名 `__dev_scroll_2601_20261012`、ID `6acc7d4e7068aa544a293fc9`、配信先hiroki_u。通知済み日時を設定し試験通知は送らない。複製JSONは新サーバーDevのops/state/scroll-survey-2601-20261012.jsonに保管（Gitには含めない）。

iOS26.4のDevシミュレーターで設問1（単一選択12件）を末尾までスクロールすると設問文が黒い長方形になることを再現。標準UITableViewHeaderFooterViewへの置換のみ、旧影オーバーレイの非表示のみでは解消せず。

## 修正
単一選択・複数選択の設問文をテーブルの固定セクションヘッダーから独立したUILabelへ変更。Auto Layoutで選択肢の上に固定し、選択肢のみをスクロールする操作は維持。旧来の影用オーバーレイは非表示。テーマカラー、設問内容、回答保存方式は変更しない。

## 検証
- DevDebugのシミュレータービルド成功。
- iOS26.4: 同じJSONの設問1で末尾までスクロール、黒化なし、Other選択→設問2へ遷移。
- iPhone SE第3世代/iOS18.0: 同じJSONの設問5（複数選択10件）で末尾までスクロール、設問文可読・ボタン表示、Other選択→設問6へ遷移。
- iOS17.5はアプリ最低OS17.6未満のため対象外。17.6での検証は未実施。
- 表示検証はDevDebug・シミュレーター限定の既存layout-previewを拡張し、Documents/scroll-survey.jsonを読む。`--layout-preview --preview-survey-json --preview-page=1`。実Survey回答の送信は無効。分岐等の動作検証用ではなく設問表示確認用。
- 実機、Protoビルド、TestFlightは未実施。上松確認後に配布する。
