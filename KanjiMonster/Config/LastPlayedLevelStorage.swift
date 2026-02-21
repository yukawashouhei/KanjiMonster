//
//  LastPlayedLevelStorage.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import Foundation

enum LastPlayedLevelStorage {
    private static let key = "lastPlayedLevel"

    static func save(_ level: KanjiLevel) {
        UserDefaults.standard.set(level.rawValue, forKey: key)
    }

    static func load() -> KanjiLevel? {
        let raw = UserDefaults.standard.integer(forKey: key)
        guard raw > 0 else { return nil }
        return KanjiLevel(rawValue: raw)
    }
}
