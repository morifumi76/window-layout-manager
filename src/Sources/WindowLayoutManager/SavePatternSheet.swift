// 配置保存シート
// 「現在の配置を保存」ボタンを押したときに表示されるダイアログ
// パターン名を入力して保存する

import SwiftUI

struct SavePatternSheet: View {
    let store: LayoutStore
    let displayCount: Int

    @Environment(\.dismiss) private var dismiss
    @State private var patternName = ""
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("現在の配置を保存")
                .font(.headline)

            // ディスプレイ数の表示（自動入力・変更不可）
            HStack {
                Text("ディスプレイ数")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(displayCount)画面")
                    .fontWeight(.medium)
            }

            // パターン名入力欄
            TextField("パターン名（例：自宅・通常作業）", text: $patternName)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 12) {
                Button("キャンセル") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Button("保存") {
                    saveCurrentLayout()
                }
                .keyboardShortcut(.return)
                .disabled(patternName.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 320)
    }

    private func saveCurrentLayout() {
        let name = patternName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        // 現在のウィンドウ配置を取得して保存
        // TODO: F2実装時にWindowCaptureManager.captureAll()で実際の配置を取得する
        let windows: [WindowInfo] = []
        let pattern = LayoutPattern(name: name, displayCount: displayCount, windows: windows)
        store.add(pattern)
        dismiss()
    }
}
