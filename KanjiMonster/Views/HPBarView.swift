//
//  HPBarView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct HPBarView: View {
    let currentHP: Int
    let maxHP: Int

    var body: some View {
        HStack(spacing: 4) {
            Text("HP")
                .pixelFont(12)
                .foregroundStyle(GBColor.light)

            HStack(spacing: 3) {
                ForEach(0..<maxHP, id: \.self) { index in
                    Rectangle()
                        .fill(index < currentHP ? GBColor.lightest : GBColor.dark)
                        .frame(width: 20, height: 12)
                        .pixelBorder(color: GBColor.light, width: 1)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        HPBarView(currentHP: 3, maxHP: 3)
        HPBarView(currentHP: 2, maxHP: 3)
        HPBarView(currentHP: 1, maxHP: 3)
        HPBarView(currentHP: 0, maxHP: 3)
    }
    .padding()
    .gbScreen()
}
