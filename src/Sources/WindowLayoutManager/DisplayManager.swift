// ディスプレイ管理
// 現在接続されているディスプレイ数を取得する

import CoreGraphics
import Foundation

struct DisplayManager {
    /// 現在接続されているディスプレイの数を返す
    static func connectedDisplayCount() -> Int {
        var displayCount: UInt32 = 0
        // アクティブなディスプレイの一覧を取得（最大32枚まで）
        let result = CGGetActiveDisplayList(32, nil, &displayCount)
        guard result == .success else { return 1 }
        return max(1, Int(displayCount))
    }
}
