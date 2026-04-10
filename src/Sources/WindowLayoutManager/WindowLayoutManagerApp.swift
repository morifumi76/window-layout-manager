// アプリのルート定義
// SwiftUIのAppプロトコルに準拠したエントリーポイント

import SwiftUI
import AppKit

struct WindowLayoutManagerApp: App {
    var body: some Scene {
        // メインウィンドウ
        WindowGroup {
            ContentView()
                .onAppear {
                    // swift run で起動した場合、自動でフォーカスが当たらないため
                    // アプリ自身でフォアグラウンドに出る処理を行う
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
        .windowResizability(.contentSize)
    }
}
