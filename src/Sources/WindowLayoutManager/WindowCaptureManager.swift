// ウィンドウ配置の取得（F2）
// Accessibility APIを使って、現在開いているすべてのウィンドウの
// アプリ名・位置・サイズを取得する

import AppKit
import ApplicationServices

struct WindowCaptureManager {
    /// 現在開いているすべてのウィンドウ情報を取得して返す
    static func captureAll() -> [WindowInfo] {
        var result: [WindowInfo] = []

        // 通常のUIアプリ（Dock表示あり）のみを対象とする
        let apps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }

        for app in apps {
            guard let bundleID = app.bundleIdentifier else { continue }
            let appName = app.localizedName ?? bundleID
            let pid = app.processIdentifier

            // AXUIElementでアプリのウィンドウ一覧を取得
            let axApp = AXUIElementCreateApplication(pid)
            var windowsRef: CFTypeRef?
            let status = AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &windowsRef)
            guard status == .success, let windows = windowsRef as? [AXUIElement] else { continue }

            for (index, window) in windows.enumerated() {
                guard let info = captureWindow(
                    window,
                    bundleID: bundleID,
                    appName: appName,
                    index: index
                ) else { continue }
                result.append(info)
            }
        }

        return result
    }

    // 1枚のウィンドウから位置・サイズを取得する
    private static func captureWindow(
        _ window: AXUIElement,
        bundleID: String,
        appName: String,
        index: Int
    ) -> WindowInfo? {
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?

        // 位置（x, y）を取得
        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef) == .success else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero

        // CFTypeRef → AXValue → CGPoint / CGSize に変換
        if let axPos = positionRef, CFGetTypeID(axPos) == AXValueGetTypeID() {
            // swiftlint:disable:next force_cast
            AXValueGetValue(axPos as! AXValue, .cgPoint, &position)
        }
        if let axSize = sizeRef, CFGetTypeID(axSize) == AXValueGetTypeID() {
            // swiftlint:disable:next force_cast
            AXValueGetValue(axSize as! AXValue, .cgSize, &size)
        }

        return WindowInfo(
            bundleID: bundleID,
            appName: appName,
            x: Double(position.x),
            y: Double(position.y),
            width: Double(size.width),
            height: Double(size.height),
            windowIndex: index
        )
    }
}
