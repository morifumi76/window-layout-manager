// データモデル定義
// レイアウトパターン・ウィンドウ情報の構造体

import Foundation

/// 1枚のウィンドウの配置情報
struct WindowInfo: Codable, Identifiable {
    let id: UUID
    /// アプリのバンドルID（例: com.google.Chrome）
    let bundleID: String
    /// アプリ表示名（例: Google Chrome）
    let appName: String
    /// ウィンドウのx座標
    let x: Double
    /// ウィンドウのy座標
    let y: Double
    /// ウィンドウの幅
    let width: Double
    /// ウィンドウの高さ
    let height: Double
    /// 同一アプリ内でのウィンドウ順序（0始まり）
    let windowIndex: Int

    init(bundleID: String, appName: String, x: Double, y: Double, width: Double, height: Double, windowIndex: Int) {
        self.id = UUID()
        self.bundleID = bundleID
        self.appName = appName
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.windowIndex = windowIndex
    }
}

/// 1つのレイアウトパターン
struct LayoutPattern: Codable, Identifiable {
    let id: UUID
    /// パターン名（例: 自宅・通常作業）
    var name: String
    /// 対応ディスプレイ数（1〜3）
    let displayCount: Int
    /// 保存されたウィンドウ一覧
    let windows: [WindowInfo]
    /// 保存日時
    let savedAt: Date

    init(name: String, displayCount: Int, windows: [WindowInfo]) {
        self.id = UUID()
        self.name = name
        self.displayCount = displayCount
        self.windows = windows
        self.savedAt = Date()
    }
}
