//
//  KanjiDisplayView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct KanjiDisplayView: View {
    let kanji: String
    let hitCount: Int
    let maxHits: Int = 3

    var body: some View {
        VStack(spacing: 12) {
            Text(kanji)
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(GBColor.lightest)
                .frame(minWidth: 120, minHeight: 70)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .pixelBorder(color: GBColor.light, width: 2)

            hitIndicator
        }
    }

    private var hitIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<maxHits, id: \.self) { index in
                Circle()
                    .fill(index < hitCount ? GBColor.lightest : GBColor.dark)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .strokeBorder(GBColor.light, lineWidth: 1)
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        KanjiDisplayView(kanji: "蒲公英", hitCount: 0)
        KanjiDisplayView(kanji: "挨拶", hitCount: 2)
    }
    .padding()
    .gbScreen()
}
