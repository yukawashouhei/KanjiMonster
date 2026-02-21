//
//  MonsterSpriteView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct MonsterSpriteView: View {
    let monster: Monster
    var isHit: Bool = false
    var isDefeated: Bool = false

    private let gridSize = MonsterPatterns.gridSize
    private let pixelSize: CGFloat = 5

    var body: some View {
        VStack(spacing: 4) {
            pixelGrid
                .opacity(isDefeated ? 0 : 1)
                .offset(x: isHit ? -5 : 0)
                .animation(
                    isHit ? .default.repeatCount(3, autoreverses: true).speed(4) : .default,
                    value: isHit
                )

            Text(monster.name)
                .pixelFont(12)
                .foregroundStyle(GBColor.light)
        }
    }

    private var pixelGrid: some View {
        let pattern = MonsterPatterns.pattern(for: monster.id)
        return VStack(spacing: 1) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 1) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        Rectangle()
                            .fill(pixelColor(for: pattern[row][col]))
                            .frame(width: pixelSize, height: pixelSize)
                    }
                }
            }
        }
    }

    private func pixelColor(for value: Int) -> Color {
        switch value {
        case 0: return GBColor.darkest
        case 1: return monster.pixelColor.primary
        case 2: return GBColor.light
        case 3: return GBColor.lightest
        default: return GBColor.darkest
        }
    }

}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
            ForEach(MonsterData.allMonsters) { monster in
                MonsterSpriteView(monster: monster)
            }
        }
        .padding()
    }
    .gbScreen()
}
