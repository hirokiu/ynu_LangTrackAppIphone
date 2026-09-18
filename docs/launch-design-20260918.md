# 起動画面：流れるガラス（2026-09-18）

3案の比較画像から、利用者が中央の案「流れるガラス」を選択。全面のコーラルレッド、白いキロクン／kirokunのロゴ、曲線状の透明なガラスと光の反射で構成。新しい文字列は追加しない。

## 実装

- `LaunchRibbon.imageset/launch-ribbon.png`を画面全体にaspect-fillで表示。
- ライト／ダークとも赤い背景を維持。Devの黄色いホーム画面アイコンとは独立。
- 中央のロゴは画像の中央付近に配置し、SEとPro Maxの縦横比差によるクロップでも残る構成。
- OSのLaunchScreenとして静的表示。アニメーションや人為的な起動待ち時間を加えない。
- 画像生成ツール（組み込みimage_gen）で、承認された比較画像の中央案から単体画像を生成。

## 生成指示

Create the production-ready standalone iPhone splash screen of ONLY THE MIDDLE DESIGN in the reference triptych. Match this approved middle design faithfully: full-bleed KIROKUN coral red #FF5857 backdrop; one flowing curved transparent liquid-glass ribbon sweeping from the upper-left around and behind the central white logo and toward lower-right; delicate luminous rim reflections and soft warm caustics. White Japanese キロクン above lowercase kirokun centered horizontally and vertically, preserve exactly the recognizable lettering from the middle reference. No extra text. Deliver ONE portrait image 1024x2208 (approximately 9:19.5); no white gutters, no other proposals, no frames, no phone bezel. All four edges must remain coral red, keep central logo and main glass turn within central 50% of height and central 75% of width so it survives aspect-fill cropping on iPhone SE as well as Pro Max. Elegant spacious launch screen, not a busy poster. Preserve the reference's soft polished glass appearance and brand saturation. No glass square panels, only the flowing ribbon from the middle proposal.

## Proto／Dev共通化の確認（2026-09-19）

利用者の方針：アイコン以外のUI/UXは共通。スプラッシュは両環境とも同一のLaunchScreen.storyboardとLaunchRibbonを使用し、環境別の表示時間やアニメーションは追加しない。接続先・認証方式・プロジェクト名は既定の環境分離を維持する。

高速起動ではOSの起動画面がごく短時間で切り替わる。背景のみが見えたという報告だけでは、表示時間の短さとOSによるキャッシュを区別できない。アプリの削除によるデータ消去は行わず、最新画像入りDevビルドへ更新する。

検証：Devビルド成功。Proto／Devのコンパイル済みAssets.carに含まれるLaunchRibbonの画像寸法（854×1842）とダイジェストが一致。通常確認用Devシミュレーターを更新し、起動成功。
