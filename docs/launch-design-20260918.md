# 起動画面の更新（2026-09-18）

既存のKIROKUNアイコン（キロクン／kirokunの文字を含む）を維持し、その背面に淡いテーマカラーの光、半透明パネル、反射線を配置。新しい文字列・キャッチコピーは追加しない。

OSのLaunchScreenは静的表示のため、ランタイムのUIGlassEffectや起動待ち時間を追加しない。Liquid Glassと調和する静的な表現で、通常画面へ直接移る。

- LaunchGlass：ライト／ダークのベクターPDF。画面幅の58%、縦横比360:320。
- 既存アイコン：画面幅の24%、中央配置。元のアセットは編集しない。
- LaunchBackground：ライト／ダークそれぞれの背景色。
- ProtoとDevの共通の起動画面。Devの黄色いホーム画面アイコンは維持。
- 再生成：`swift scripts/design/render-launch.swift LangTrackApp/Assets.xcassets/LaunchGlass.imageset`

ベクター描画をレンダリングして確認。LaunchScreenの制約は画面幅に比例し、SEの375ポイント幅でも最大機種の幅でも中央に収まる。実機での初回起動表示・OS側キャッシュの更新は別途目視確認が必要。
