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

    static let allMonsters: [Monster] = [
        // 5級 モンスター（4体）
        Monster(id: 1, name: "スライムン", imageName: "monster_01", baseLevel: .kyu5, pixelColor: .lime),
        Monster(id: 2, name: "コケモス", imageName: "monster_02", baseLevel: .kyu5, pixelColor: .green),
        Monster(id: 3, name: "ドクキノ", imageName: "monster_03", baseLevel: .kyu5, pixelColor: .darkGreen),
        Monster(id: 4, name: "ホネガメ", imageName: "monster_04", baseLevel: .kyu5, pixelColor: .yellow),

        // 4級 モンスター（4体）
        Monster(id: 5, name: "ヤミネコ", imageName: "monster_05", baseLevel: .kyu4, pixelColor: .darkGreen),
        Monster(id: 6, name: "イシゴーレム", imageName: "monster_06", baseLevel: .kyu4, pixelColor: .green),
        Monster(id: 7, name: "カゲバット", imageName: "monster_07", baseLevel: .kyu4, pixelColor: .lime),
        Monster(id: 8, name: "ツノムシ", imageName: "monster_08", baseLevel: .kyu4, pixelColor: .yellow),

        // 3級 モンスター（4体）
        Monster(id: 9, name: "リュウジン", imageName: "monster_09", baseLevel: .kyu3, pixelColor: .green),
        Monster(id: 10, name: "ヒノトリ", imageName: "monster_10", baseLevel: .kyu3, pixelColor: .yellow),
        Monster(id: 11, name: "コオリオオカミ", imageName: "monster_11", baseLevel: .kyu3, pixelColor: .lime),
        Monster(id: 12, name: "カミナリグマ", imageName: "monster_12", baseLevel: .kyu3, pixelColor: .darkGreen),

        // 2級 モンスター（4体）
        Monster(id: 13, name: "マジンガ", imageName: "monster_13", baseLevel: .kyu2, pixelColor: .darkGreen),
        Monster(id: 14, name: "ゲンブ", imageName: "monster_14", baseLevel: .kyu2, pixelColor: .green),
        Monster(id: 15, name: "ビャッコ", imageName: "monster_15", baseLevel: .kyu2, pixelColor: .lime),
        Monster(id: 16, name: "スザク", imageName: "monster_16", baseLevel: .kyu2, pixelColor: .yellow),

        // 1級 モンスター（4体）
        Monster(id: 17, name: "セイリュウ", imageName: "monster_17", baseLevel: .kyu1, pixelColor: .green),
        Monster(id: 18, name: "ダークロード", imageName: "monster_18", baseLevel: .kyu1, pixelColor: .darkGreen),
        Monster(id: 19, name: "カオスキング", imageName: "monster_19", baseLevel: .kyu1, pixelColor: .lime),
        Monster(id: 20, name: "ラスボス", imageName: "monster_20", baseLevel: .kyu1, pixelColor: .yellow),
    ]
}
