//
//  Monster.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct Monster: Identifiable, Sendable {
    let id: Int
    let name: String
    let imageName: String
    let baseLevel: KanjiLevel
    let pixelColor: PixelMonsterColor

    enum PixelMonsterColor: Sendable {
        case green, darkGreen, lime, yellow

        var primary: Color {
            switch self {
            case .green: return Color(red: 0.55, green: 0.67, blue: 0.06)
            case .darkGreen: return Color(red: 0.19, green: 0.38, blue: 0.19)
            case .lime: return Color(red: 0.55, green: 0.74, blue: 0.06)
            case .yellow: return Color(red: 0.61, green: 0.74, blue: 0.06)
            }
        }
    }
}
