// アプリのルート定義
// SwiftUIのAppプロトコルに準拠したエントリーポイント

import SwiftUI

struct WindowLayoutManagerApp: App {
    var body: some Scene {
        // メインウィンドウ
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
