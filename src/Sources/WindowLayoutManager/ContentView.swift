// メイン画面
// パターン一覧の表示・選択・削除・保存操作を行うUI

import SwiftUI

struct ContentView: View {
    @StateObject private var store = LayoutStore()
    @State private var currentDisplayCount = DisplayManager.connectedDisplayCount()
    @State private var showSaveSheet = false
    @State private var deleteTarget: LayoutPattern? = nil
    @State private var showDeleteConfirm = false

    // ディスプレイ数ごとにグループ化したパターン（表示可能なものだけ）
    private var filteredPatterns: [LayoutPattern] {
        store.patterns(for: currentDisplayCount)
    }

    private var groupedPatterns: [(Int, [LayoutPattern])] {
        let counts = [3, 2, 1]
        return counts.compactMap { count in
            let group = filteredPatterns.filter { $0.displayCount == count }
            return group.isEmpty ? nil : (count, group)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
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
            // グループヘッダー
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

            // パターン行
            ForEach(patterns) { pattern in
                patternRow(pattern)
                Divider()
                    .padding(.leading, 16)
            }
        }
    }

    // 個別パターン行
    private func patternRow(_ pattern: LayoutPattern) -> some View {
        HStack {
            Text(pattern.name)
                .font(.body)
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
        // TODO: クリックでレイアウト復元（F3実装時に追加）
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
