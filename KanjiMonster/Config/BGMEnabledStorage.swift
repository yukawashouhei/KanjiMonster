//
//  BGMEnabledStorage.swift
//  KanjiMonster
//
//  戦闘BGMのオン/オフ設定をUserDefaultsで永続化
//

import Foundation

enum BGMEnabledStorage {
    static let key = "bgmEnabled"

    /// BGMを再生するか。未設定時は true（オン）
    static var isEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: key) == nil { return true }
            return UserDefaults.standard.bool(forKey: key)
        }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    static func toggle() {
        isEnabled.toggle()
    }
}
