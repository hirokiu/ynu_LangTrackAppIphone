# 起動画面：流れるガラス（2026-09-18）

3案の比較画像から、利用者が中央の案「流れるガラス」を選択。全面のコーラルレッド、白いキロクン／kirokunのロゴ、曲線状の透明なガラスと光の反射で構成。新しい文字列は追加しない。

## 実装

- `KirokunLaunchRibbon.imageset/launch-ribbon.png`を画面全体にaspect-fillで表示。
- ライト／ダークとも赤い背景を維持。Devの黄色いホーム画面アイコンとは独立。
- 中央のロゴは画像の中央付近に配置し、SEとPro Maxの縦横比差によるクロップでも残る構成。
- OSの起動画面として静的表示。2026-09-19の修正で、起動直後にも同じ画像を0.8秒表示し、0.2秒でフェードアウトする共通処理を追加。画面・通信処理はその間も進める。「視差効果を減らす」が有効ならフェードせず切り替える。
- 画像生成ツール（組み込みimage_gen）で、承認された比較画像の中央案から単体画像を生成。

## 生成指示

Create the production-ready standalone iPhone splash screen of ONLY THE MIDDLE DESIGN in the reference triptych. Match this approved middle design faithfully: full-bleed KIROKUN coral red #FF5857 backdrop; one flowing curved transparent liquid-glass ribbon sweeping from the upper-left around and behind the central white logo and toward lower-right; delicate luminous rim reflections and soft warm caustics. White Japanese キロクン above lowercase kirokun centered horizontally and vertically, preserve exactly the recognizable lettering from the middle reference. No extra text. Deliver ONE portrait image 1024x2208 (approximately 9:19.5); no white gutters, no other proposals, no frames, no phone bezel. All four edges must remain coral red, keep central logo and main glass turn within central 50% of height and central 75% of width so it survives aspect-fill cropping on iPhone SE as well as Pro Max. Elegant spacious launch screen, not a busy poster. Preserve the reference's soft polished glass appearance and brand saturation. No glass square panels, only the flowing ribbon from the middle proposal.

## Proto／Dev共通化の確認（2026-09-19）

利用者の方針：アイコン以外のUI/UXは共通。スプラッシュは両環境とも同一のKirokunLaunch.storyboardとKirokunLaunchRibbon、KirokunTheme.showLaunchArtworkを使用。環境別の表示時間の違いは設けない。接続先・認証方式・プロジェクト名は既定の環境分離を維持する。

高速起動ではOSの起動画面がごく短時間で切り替わる。背景のみが見えたという報告だけでは、表示時間の短さとOSによるキャッシュを区別できない。アプリの削除によるデータ消去は行わず、最新画像入りDevビルドへ更新する。

検証：Devビルド成功。Proto／Devのコンパイル済みAssets.carに含まれるLaunchRibbonの画像寸法（854×1842）とダイジェストが一致。通常確認用Devシミュレーターを更新し、起動成功。

## 背景のみ表示される問題への対応（2026-09-19）

前回のAssets.carの比較は画像の梱包確認にとどまり、実際の起動表示の確認として不十分だった。

- 既存SEシミュレーターで背景だけの状態を再現。通常のStoryboard描画では画像を読み込めた。
- 起動Storyboard／画像の参照名を更新し、画像スケールを明示的に3x指定。ProtoとDevそれぞれのInfo.plistを更新。
- 新規シミュレーターでは起動待機中に画像を確認できた一方、既存SEでは再起動後も背景のみの表示が残った。OSのキャッシュを含む正確な内部原因は断定していない。
- OSの起動表示だけに依存しないよう、シーン作成時に同じ画像を重ね、0.8秒後に0.2秒で取り除く。Protoは起動時にログインモーダルを開くため、画像を専用の非キーウィンドウで前面表示し、ログイン画面に覆われないようにする。アプリ削除やデータ消去は不要。バックグラウンドから戻るたびには表示しない。
- Debugシミュレーターの `--launch-preview` は、通常起動と同じ画像オーバーレイを静止表示する検証専用引数。配布ビルドには静止動作を含めない。

検証：起動StoryboardをInfo.plistから読み込み、画像854×1842ピクセルとSE／Max寸法での全画面配置を確認するテスト成功。既存SE／Pro MaxのiOS27で共通オーバーレイのロゴ・ガラス模様を目視確認。Proto/iOS26.4でも画像と通常起動後のログイン画面への移行を確認。DevビルドとProto実機ビルド成功。通常確認用・SE・MaxのDevシミュレーター、iPhone11 ProのProto版を更新。実機の見え方は利用者の確認待ち。

参考：[Apple TN3118: Debugging your app’s launch screen](https://developer.apple.com/documentation/technotes/tn3118-debugging-your-apps-launch-screen)。アセットカタログ内のPNGと標準Storyboardを使用し、ユーザーデータを保持して更新する。
