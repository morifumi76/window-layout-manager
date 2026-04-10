// レイアウトパターンの永続化管理
// JSONファイルとして ~/Library/Application Support/ に保存する

import Foundation

@MainActor
class LayoutStore: ObservableObject {
    @Published var patterns: [LayoutPattern] = []

    // 保存先ファイルパス
    private let saveURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("WindowLayoutManager")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("layouts.json")
    }()

    init() {
        load()
    }

    /// パターンを追加して保存する
    func add(_ pattern: LayoutPattern) {
        patterns.append(pattern)
        save()
    }

    /// 指定IDのパターンを削除して保存する
    func remove(id: UUID) {
        patterns.removeAll { $0.id == id }
        save()
    }

    /// ディスプレイ数でフィルタリング（少ない画面数のパターンも表示する）
    func patterns(for displayCount: Int) -> [LayoutPattern] {
        patterns.filter { $0.displayCount <= displayCount }
    }

    // MARK: - 永続化

    private func save() {
        do {
            let data = try JSONEncoder().encode(patterns)
            try data.write(to: saveURL)
        } catch {
            print("保存エラー: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return }
        do {
            let data = try Data(contentsOf: saveURL)
            patterns = try JSONDecoder().decode([LayoutPattern].self, from: data)
        } catch {
            print("読み込みエラー: \(error)")
        }
    }
}
