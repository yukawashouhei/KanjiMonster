//
//  KanjiQuestion.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import Foundation

enum KanjiLevel: Int, CaseIterable, Comparable, Sendable {
    case kyu5 = 5
    case kyu4 = 4
    case kyu3 = 3
    case kyu2 = 2
    case kyu1 = 1

    var displayName: String {
        "\(rawValue)級"
    }

    var scoreMultiplier: Int {
        6 - rawValue
    }

    var next: KanjiLevel? {
        KanjiLevel(rawValue: rawValue - 1)
    }

    var previous: KanjiLevel? {
        KanjiLevel(rawValue: rawValue + 1)
    }

    static func < (lhs: KanjiLevel, rhs: KanjiLevel) -> Bool {
        lhs.rawValue > rhs.rawValue
    }
}

struct KanjiQuestion: Identifiable, Sendable {
    let id = UUID()
    let kanji: String
    let readings: [String]
    let meaning: String
    let level: KanjiLevel
    let hint: String

    func isCorrect(_ answer: String) -> Bool {
        let normalized = answer
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .katakanaToHiragana()
            .lowercased()
        return readings.contains(normalized)
    }
}

extension String {
    func katakanaToHiragana() -> String {
        let mutable = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutable, nil, kCFStringTransformHiraganaKatakana, true)
        return mutable as String
    }
}
