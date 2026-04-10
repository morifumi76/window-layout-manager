// ウィンドウ配置の復元（F3）
// 保存済みパターンを選択したときに、ウィンドウを記憶した位置・サイズに移動する

import AppKit
import ApplicationServices

struct WindowRestoreManager {
    /// 保存済みパターンを復元する
    static func restore(pattern: LayoutPattern) async {
        // アプリ名でグループ化（同一アプリの複数ウィンドウに対応）
        let grouped = Dictionary(grouping: pattern.windows, by: { $0.bundleID })

        for (bundleID, windowInfos) in grouped {
            // アプリが起動しているか確認
            var runningApp = findRunningApp(bundleID: bundleID)

            // 起動していなければ自動で起動する
            if runningApp == nil {
                runningApp = await launchApp(bundleID: bundleID)
            }

            guard let app = runningApp else {
                print("アプリを起動できませんでした: \(bundleID)")
                continue
            }

            // ウィンドウ一覧を取得して配置を復元
            applyLayout(to: app, windowInfos: windowInfos)
        }
    }

    // MARK: - 内部処理

    /// 起動中のアプリを探す
    private static func findRunningApp(bundleID: String) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first {
            $0.bundleIdentifier == bundleID && $0.activationPolicy == .regular
        }
    }

    /// アプリを起動して、準備完了まで待つ
    private static func launchApp(bundleID: String) async -> NSRunningApplication? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }

        do {
            let config = NSWorkspace.OpenConfiguration()
            config.activates = false  // フォアグラウンドに移動しない
            let app = try await NSWorkspace.shared.openApplication(at: url, configuration: config)
            // 起動完了まで最大5秒待つ
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                if app.isFinishedLaunching { break }
            }
            return app
        } catch {
            print("起動エラー (\(bundleID)): \(error)")
            return nil
        }
    }

    /// ウィンドウに位置・サイズを適用する
    private static func applyLayout(to app: NSRunningApplication, windowInfos: [WindowInfo]) {
        let pid = app.processIdentifier
        let axApp = AXUIElementCreateApplication(pid)

        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement] else { return }

        for info in windowInfos {
            // 記録したインデックスのウィンドウが存在する場合のみ配置する
            guard info.windowIndex < windows.count else {
                print("ウィンドウが足りないためスキップ: \(info.appName)[\(info.windowIndex)]")
                continue
            }

            let window = windows[info.windowIndex]

            // 位置を設定
            var position = CGPoint(x: info.x, y: info.y)
            if let posValue = AXValueCreate(.cgPoint, &position) {
                AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posValue)
            }

            // サイズを設定
            var size = CGSize(width: info.width, height: info.height)
            if let sizeValue = AXValueCreate(.cgSize, &size) {
                AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
            }
        }
    }
}
