// メイン画面（仮実装）
// 今後、レイアウト一覧・保存・復元UIに差し替える

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Window Layout Manager")
                .font(.headline)
            Text("初期構築中...")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 280)
    }
}
