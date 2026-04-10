#!/bin/bash
# .appバンドルをビルドして起動するスクリプト
# 使い方: bash scripts/build-app.sh
set -e

# このスクリプトの場所からプロジェクトルートを特定する
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "ビルド中..."
cd "$PROJECT_ROOT/src"
swift build -c release 2>&1

BINARY="$PROJECT_ROOT/src/.build/release/WindowLayoutManager"
APP_DIR="$PROJECT_ROOT/dist/WindowLayoutManager.app"
CONTENTS="$APP_DIR/Contents"

# 既存の.appを削除して再作成
rm -rf "$APP_DIR"
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"

# バイナリとInfo.plistをコピー
cp "$BINARY" "$CONTENTS/MacOS/WindowLayoutManager"
cp "$SCRIPT_DIR/Info.plist" "$CONTENTS/Info.plist"

echo "✅ ビルド完了: $APP_DIR"
echo "アプリを起動します..."
open "$APP_DIR"
