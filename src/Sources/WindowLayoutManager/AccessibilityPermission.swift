// Accessibility（アクセシビリティ）権限の管理
// ウィンドウの位置・サイズを操作するにはmacOSの許可が必要

import ApplicationServices

struct AccessibilityPermission {
    /// 権限が付与されているか確認する
    static func isGranted() -> Bool {
        return AXIsProcessTrusted()
    }

    /// 権限がなければmacOSの許可ダイアログを表示する
    static func requestIfNeeded() {
        guard !isGranted() else { return }
        // "AXTrustedCheckOptionPrompt": trueにすると許可ダイアログを自動表示する
        // kAXTrustedCheckOptionPromptはSwift 6の並行性チェックに引っかかるため文字列リテラルで指定する
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
