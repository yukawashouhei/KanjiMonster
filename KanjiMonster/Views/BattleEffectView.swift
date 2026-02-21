//
//  BattleEffectView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct BattleEffectView: View {
    let event: BattleEvent
    let correctReading: String
    let monsterDialogue: String?

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var offset: CGFloat = 0

    var body: some View {
        Group {
            switch event {
            case .none:
                EmptyView()

            case .correct:
                effectLabel(text: "HIT!", color: GBColor.lightest)

            case .wrong:
                VStack(spacing: 6) {
                    effectLabel(text: "MISS!", color: GBColor.dark)
                    Text("正解: \(correctReading)")
                        .pixelFont(14)
                        .foregroundStyle(GBColor.light)
                    if let dialogue = monsterDialogue {
                        dialogueBubble(text: dialogue)
                    }
                }

            case .monsterDefeated:
                VStack(spacing: 6) {
                    effectLabel(text: "DEFEATED!", color: GBColor.lightest)
                    if let dialogue = monsterDialogue {
                        dialogueBubble(text: dialogue)
                    }
                }

            case .levelUp(let level):
                VStack(spacing: 6) {
                    effectLabel(text: "LEVEL UP!", color: GBColor.lightest)
                    Text("\(level.displayName)に昇格！")
                        .pixelFont(14)
                        .foregroundStyle(GBColor.light)
                }

            case .levelDown(let level):
                VStack(spacing: 6) {
                    effectLabel(text: "LEVEL DOWN...", color: GBColor.dark)
                    Text("\(level.displayName)に降格...")
                        .pixelFont(14)
                        .foregroundStyle(GBColor.dark)
                }

            case .gameCleared:
                VStack(spacing: 8) {
                    effectLabel(text: "CLEAR!", color: GBColor.lightest)
                    Text("5問連続正解！")
                        .pixelFont(14)
                        .foregroundStyle(GBColor.light)
                }
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .offset(y: offset)
        .onChange(of: event) { _, _ in
            opacity = 0
            scale = 0.5
            offset = 20
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                opacity = 1
                scale = 1.0
                offset = 0
            }
        }
    }

    private func effectLabel(text: String, color: Color) -> some View {
        Text(text)
            .pixelFont(24)
            .foregroundStyle(color)
            .shadow(color: GBColor.darkest, radius: 2, x: 2, y: 2)
    }

    private func dialogueBubble(text: String) -> some View {
        Text("「\(text)」")
            .pixelFont(10)
            .foregroundStyle(GBColor.light)
            .padding(8)
            .background(GBColor.darkest.opacity(0.8))
            .pixelBorder(color: GBColor.dark, width: 1)
    }
}

#Preview {
    VStack(spacing: 30) {
        BattleEffectView(event: .correct, correctReading: "", monsterDialogue: nil)
        BattleEffectView(event: .wrong, correctReading: "ひまわり", monsterDialogue: "甘いぞ！")
        BattleEffectView(event: .monsterDefeated, correctReading: "", monsterDialogue: "ぐふっ...")
        BattleEffectView(event: .levelUp(.kyu3), correctReading: "", monsterDialogue: nil)
    }
    .padding()
    .gbScreen()
}
