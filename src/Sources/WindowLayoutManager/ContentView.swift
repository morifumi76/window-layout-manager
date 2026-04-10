// メイン画面
// パターン一覧の表示・選択（復元）・削除・保存操作を行うUI

import SwiftUI

struct ContentView: View {
    @StateObject private var store = LayoutStore()
    @State private var currentDisplayCount = DisplayManager.connectedDisplayCount()
    @State private var showSaveSheet = false
    @State private var deleteTarget: LayoutPattern? = nil
    @State private var showDeleteConfirm = false
    @State private var isRestoring = false
    @State private var restoringPatternID: UUID? = nil
    @State private var permissionGranted = AccessibilityPermission.isGranted()

    // ディスプレイ数でフィルタリング・グループ化したパターン
    private var groupedPatterns: [(Int, [LayoutPattern])] {
        let counts = [3, 2, 1]
        return counts.compactMap { count in
            let group = store.patterns(for: currentDisplayCount).filter { $0.displayCount == count }
            return group.isEmpty ? nil : (count, group)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if !permissionGranted {
                permissionWarning
                Divider()
            }
            patternList
            Divider()
            footer
        }
        .frame(width: 300)
        .sheet(isPresented: $showSaveSheet) {
            SavePatternSheet(store: store, displayCount: currentDisplayCount)
        }
        .alert("パターンを削除しますか？", isPresented: $showDeleteConfirm, presenting: deleteTarget) { target in
            Button("削除", role: .destructive) {
                store.remove(id: target.id)
            }
            Button("キャンセル", role: .cancel) {}
        } message: { target in
            Text("「\(target.name)」を削除します。この操作は元に戻せません。")
        }
        .onAppear {
            // 権限状態を最新化
            permissionGranted = AccessibilityPermission.isGranted()
        }
    }

    // MARK: - ヘッダー

    private var header: some View {
        HStack {
            Text("Window Layout Manager")
                .font(.headline)
            Spacer()
            // ディスプレイ数を再検知するボタン
            Button {
                currentDisplayCount = DisplayManager.connectedDisplayCount()
                permissionGranted = AccessibilityPermission.isGranted()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("ディスプレイ数を再検知")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - 権限警告バー

    private var permissionWarning: some View {
        Button {
            AccessibilityPermission.requestIfNeeded()
            // 少し待ってから権限状態を再確認する
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                permissionGranted = AccessibilityPermission.isGranted()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("アクセシビリティ権限が必要です。タップして許可")
                    .font(.caption)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.orange.opacity(0.1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - ディスプレイ情報バー

    private var displayInfoBar: some View {
        HStack {
            Image(systemName: "display")
                .foregroundStyle(.blue)
            Text("現在のディスプレイ: \(currentDisplayCount)枚")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.quaternary)
    }

    // MARK: - パターン一覧

    private var patternList: some View {
        ScrollView {
            VStack(spacing: 0) {
                displayInfoBar

                if groupedPatterns.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedPatterns, id: \.0) { count, patterns in
                        patternGroup(count: count, patterns: patterns)
                    }
                }
            }
        }
        .frame(minHeight: 200, maxHeight: 400)
    }

    // パターンが0件のとき
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("保存済みパターンがありません")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }

    // ディスプレイ数ごとのグループ
    private func patternGroup(count: Int, patterns: [LayoutPattern]) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(count)画面パターン")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.quinary)

            ForEach(patterns) { pattern in
                patternRow(pattern)
                Divider()
                    .padding(.leading, 16)
            }
        }
    }

    // 個別パターン行（クリックで復元）
    private func patternRow(_ pattern: LayoutPattern) -> some View {
        HStack {
            // 復元中はスピナーを表示
            if restoringPatternID == pattern.id {
                ProgressView()
                    .scaleEffect(0.7)
                    .padding(.trailing, 4)
            }

            Text(pattern.name)
                .font(.body)
                .opacity(restoringPatternID == pattern.id ? 0.5 : 1.0)

            Spacer()

            // 削除ボタン
            Button {
                deleteTarget = pattern
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
            .help("このパターンを削除")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isRestoring else { return }
            Task { await restorePattern(pattern) }
        }
    }

    // MARK: - 復元処理

    @MainActor
    private func restorePattern(_ pattern: LayoutPattern) async {
        guard AccessibilityPermission.isGranted() else {
            AccessibilityPermission.requestIfNeeded()
            return
        }

        isRestoring = true
        restoringPatternID = pattern.id

        await WindowRestoreManager.restore(pattern: pattern)

        isRestoring = false
        restoringPatternID = nil
    }

    // MARK: - フッター（保存ボタン）

    private var footer: some View {
        Button {
            showSaveSheet = true
        } label: {
            Label("現在の配置を保存", systemImage: "plus")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .padding(14)
    }
}
