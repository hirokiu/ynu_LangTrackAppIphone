# 起動画面：流れるガラス（2026-09-18）

3案の比較画像から、利用者が中央の案「流れるガラス」を選択。全面のコーラルレッド、白いキロクン／kirokunのロゴ、曲線状の透明なガラスと光の反射で構成。新しい文字列は追加しない。

## 実装

- `KirokunLaunchRibbon.imageset/launch-ribbon.png`を画面全体にaspect-fillで表示。
- ライト／ダークとも赤い背景を維持。Devの黄色いホーム画面アイコンとは独立。
- 中央のロゴは画像の中央付近に配置し、SEとPro Maxの縦横比差によるクロップでも残る構成。
- OS標準のLaunch Screenを使用。表示時間の固定・独自ウィンドウ・アニメーションは追加しない。
- 画像生成ツール（組み込みimage_gen）で、承認された比較画像の中央案から単体画像を生成。

## 生成指示

Create the production-ready standalone iPhone splash screen of ONLY THE MIDDLE DESIGN in the reference triptych. Match this approved middle design faithfully: full-bleed KIROKUN coral red #FF5857 backdrop; one flowing curved transparent liquid-glass ribbon sweeping from the upper-left around and behind the central white logo and toward lower-right; delicate luminous rim reflections and soft warm caustics. White Japanese キロクン above lowercase kirokun centered horizontally and vertically, preserve exactly the recognizable lettering from the middle reference. No extra text. Deliver ONE portrait image 1024x2208 (approximately 9:19.5); no white gutters, no other proposals, no frames, no phone bezel. All four edges must remain coral red, keep central logo and main glass turn within central 50% of height and central 75% of width so it survives aspect-fill cropping on iPhone SE as well as Pro Max. Elegant spacious launch screen, not a busy poster. Preserve the reference's soft polished glass appearance and brand saturation. No glass square panels, only the flowing ribbon from the middle proposal.

## 標準起動方式への復帰（2026-09-19）

利用者の方針：iOS標準の開発手法とフレームワークの処理に従う。Proto／Devの起動方法は共通。

- `UILaunchStoryboardName` で `KirokunLaunch` を指定し、OSが起動画面の表示・終了を管理する。
- 独自のUIWindow、起動後の画像オーバーレイ、0.8秒の固定待機、0.2秒のフェード、検証専用 `--launch-preview` は削除。
- ProtoのSceneDelegateに追加した `makeKeyAndVisible` も取り除き、既存のStoryboardによる画面生成に戻す。Devは従来どおりコードで通常ウィンドウを作成する。
- キャッシュ更新のために既存アプリやユーザーデータを削除しない。
- 起動が速い場合、起動画面はごく短時間の表示になる。アプリ側で最低表示時間を保証しない。復帰時にはOSが直前の画面のスナップショットを使う場合がある。

前回の実装では、背景だけの表示に対処するため起動後にも画像を重ねたが、今回はその回避策を取り除く。前回の画像オーバーレイの目視確認は、標準Launch Screenの実表示を証明するものではない。

## 参照する公式仕様

- [Apple TN3118: Debugging your app’s launch screen](https://developer.apple.com/documentation/technotes/tn3118-debugging-your-apps-launch-screen)：Storyboard名、初期ViewController、アセットカタログ由来のPNG/JPG、キャッシュ・復帰時のスナップショットを確認する。
- [Apple HIG: Launching](https://developer.apple.com/design/human-interface-guidelines/launching)：Launch Screenとブランド演出用Splash Screenを区別する。Launch Screenは最初の画面に近い外観とし、ロゴなどの宣伝的要素を避ける。標準の技術的な表示方式と、デザイン推奨への適合は別々に扱う。

## 今回の検証・デザイン判断

DevのStoryboard画像読み込み・SE/Maxサイズのレイアウトテスト成功。Protoの実機ビルド成功。独自表示関数・待機・検証専用静止表示への参照がないことを確認。

今回まず表示方法を標準化し、承認済みの画像素材は維持する。画像を最初の画面に近いシンプルな背景に変更するかは利用者に選択肢を提示している。静止画像の技術的対応を確認したことをもって、ブランド画像のデザインがHIGの推奨に完全適合するとはしない。
