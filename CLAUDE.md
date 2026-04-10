# window-layout-manager

## 概要
macOSのウィンドウ配置をパターンとして保存・復元するDockアプリ。
接続中のディスプレイ数を自動検知し、最適なレイアウトパターンを選択・適用する。

## 技術スタック
- 言語: Swift 6
- UIフレームワーク: SwiftUI
- ビルドツール: Swift Package Manager（Xcodeなし）
- macOS API: Accessibility API（AXUIElement）、CoreGraphics
- 対象OS: macOS 13（Ventura）以降

## フォルダ構成
- src/Sources/WindowLayoutManager/ : Swiftソースコード本体
- src/Package.swift : Swift Package Manager 設定ファイル
- docs/specs/ : 仕様書・指示書
- public/ : （未使用・テンプレート由来）

## このプロジェクト固有のルール
- Xcodeは使用しない。ビルドは `swift build`、実行は `swift run` で行う
- .appバンドルはビルドスクリプト（`scripts/build-app.sh`）で生成する
- Accessibility権限が必要。初回起動時にmacOSのシステム設定で許可すること
- ウィンドウの中身（タブ・ドキュメント）は管理しない（位置・サイズ・アプリ名のみ）

## ビルド・実行方法
```bash
# ビルド
cd src && swift build

# 実行（開発時）
cd src && swift run

# .appバンドル生成（配置用）
bash scripts/build-app.sh
```

## 現在の状態
初期構築中
