// 配置保存シート
// 「現在の配置を保存」ボタンを押したときに表示されるダイアログ

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

            // ディスプレイ数（自動取得・変更不可）
            HStack {
                Text("ディスプレイ数")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(displayCount)画面パターンとして保存")
                    .fontWeight(.medium)
            }

            // パターン名の入力欄
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

                Button(isSaving ? "取得中..." : "保存") {
                    Task { await saveCurrentLayout() }
                }
                .keyboardShortcut(.return)
                .disabled(patternName.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 340)
        .onAppear {
            // 権限がなければ許可を求める
            AccessibilityPermission.requestIfNeeded()
        }
    }

    // MARK: - 保存処理

    @MainActor
    private func saveCurrentLayout() async {
        let name = patternName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        // 権限チェック
        guard AccessibilityPermission.isGranted() else {
            errorMessage = "アクセシビリティ権限が必要です。\nシステム設定 > プライバシーとセキュリティ > アクセシビリティ で許可してください。"
            return
        }

        isSaving = true
        errorMessage = nil

        // バックグラウンドで現在のウィンドウ配置を取得する
        let windows = await Task.detached(priority: .userInitiated) {
            WindowCaptureManager.captureAll()
        }.value

        if windows.isEmpty {
            errorMessage = "ウィンドウが取得できませんでした。\nアクセシビリティ権限を確認してください。"
            isSaving = false
            return
        }

        let pattern = LayoutPattern(name: name, displayCount: displayCount, windows: windows)
        store.add(pattern)
        dismiss()
    }
}
