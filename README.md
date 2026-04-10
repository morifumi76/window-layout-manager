# Window Layout Manager

## 概要
macOSのウィンドウ配置をパターンとして保存・復元するDockアプリ。
接続中のディスプレイ数（1〜3枚）を自動検知し、対応するレイアウトパターンを選択・適用できる。

## 技術スタック
- 言語: Swift 6
- UIフレームワーク: SwiftUI
- ビルドツール: Swift Package Manager（Xcodeなし）
- macOS API: Accessibility API（AXUIElement）

## セットアップ
1. リポジトリをクローン
   ```bash
   git clone https://github.com/morifumi76/window-layout-manager.git
   ```
2. ビルド
   ```bash
   cd window-layout-manager/src
   swift build
   ```
3. 実行
   ```bash
   swift run
   ```
4. 初回起動時：システム設定 > プライバシーとセキュリティ > アクセシビリティ でアプリを許可する

## フォルダ構成
- `src/` : Swiftソースコード・Package.swift
- `docs/specs/` : 仕様書

## 作者
森田文弥 / ジョウホウソース株式会社
