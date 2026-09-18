# KIROKUN for iOS

KIROKUN is a Japanese research participant app derived from Lang-Track-App.

## ビルド先と実機確認

**Proto実機確認は `Kirokun-Proto`、開発シミュレーターは `Kirokun-Dev` を選択してください。**
[切り替え・実機確認の手順](docs/ios-build-and-device-check.md)

## Development

Use Xcode 27 and CocoaPods 1.16.2. Minimum deployment target: iOS 17.6.

```sh
pod install
open Kirokun.xcworkspace
xcodebuild -workspace Kirokun.xcworkspace -scheme Kirokun -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Open **Kirokun.xcworkspace**. Choose **Kirokun-Proto** or **Kirokun-Dev** as described above; **Kirokun** is the legacy routing scheme. Podfile.lock is version-controlled; do not use `pod update` for ordinary checkout setup.

The next development version is 2.0.1 (2). This is NOT an App Store release. The bundle identifier remains `com.alchembright.dev.ynu-lta-dev` for update compatibility. The App Store currently displays version 1.0; its association with the local 2.0.0 (1) archive still requires verification in App Store Connect. See [source provenance](docs/SOURCE_BASELINE.md).

Firebase is updated to 12.19.0, Alamofire to 5.12.2, DGCharts to 5.1.0 and SwiftyJSON to 5.0.2. Firebase states future major versions will require Swift Package Manager; schedule that migration separately from this consolidation.

## Validation

Xcode 27 simulator build; iOS 27 login-screen smoke test and server timestamp parsing tests. Authentication with a real study account, remote Push delivery, survey submission and App Store upload require separate acceptance testing.

## Provenance

Original project: https://github.com/HumlabLu/HumlabLu
Original authors and research references are retained.
