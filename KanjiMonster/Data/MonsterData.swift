//
//  MonsterData.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import Foundation

enum MonsterData {

    static func monsters(for level: KanjiLevel) -> [Monster] {
        allMonsters.filter { $0.baseLevel == level }
    }

    static func randomMonster(for level: KanjiLevel) -> Monster {
        let pool = monsters(for: level)
        return pool.randomElement() ?? allMonsters[0]
    }

    /// 各級3体ずつ、計15体。あとでイメージ画像を渡してもらいドット絵化する想定。
    static let allMonsters: [Monster] = [
        // 5級（3体）
        Monster(id: 1, name: "スライムン", imageName: "monster_01", baseLevel: .kyu5, pixelColor: .lime),
        Monster(id: 2, name: "コケモス", imageName: "monster_02", baseLevel: .kyu5, pixelColor: .green),
        Monster(id: 3, name: "ドクキノ", imageName: "monster_03", baseLevel: .kyu5, pixelColor: .darkGreen),

        // 4級（3体）
        Monster(id: 4, name: "ヤミネコ", imageName: "monster_04", baseLevel: .kyu4, pixelColor: .darkGreen),
        Monster(id: 5, name: "イシゴーレム", imageName: "monster_05", baseLevel: .kyu4, pixelColor: .green),
        Monster(id: 6, name: "カゲバット", imageName: "monster_06", baseLevel: .kyu4, pixelColor: .lime),

        // 3級（3体）
        Monster(id: 7, name: "リュウジン", imageName: "monster_07", baseLevel: .kyu3, pixelColor: .green),
        Monster(id: 8, name: "ヒノトリ", imageName: "monster_08", baseLevel: .kyu3, pixelColor: .yellow),
        Monster(id: 9, name: "コオリオオカミ", imageName: "monster_09", baseLevel: .kyu3, pixelColor: .lime),

        // 2級（3体）
        Monster(id: 10, name: "マジンガ", imageName: "monster_10", baseLevel: .kyu2, pixelColor: .darkGreen),
        Monster(id: 11, name: "ゲンブ", imageName: "monster_11", baseLevel: .kyu2, pixelColor: .green),
        Monster(id: 12, name: "スザク", imageName: "monster_12", baseLevel: .kyu2, pixelColor: .yellow),

        // 1級（3体）
        Monster(id: 13, name: "ダークロード", imageName: "monster_13", baseLevel: .kyu1, pixelColor: .darkGreen),
        Monster(id: 14, name: "バハムート", imageName: "monster_14", baseLevel: .kyu1, pixelColor: .green),
        Monster(id: 15, name: "オーディン", imageName: "monster_15", baseLevel: .kyu1, pixelColor: .lime),
    ]
}
