//
//  TitleScreenView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct TitleScreenView: View {
    let onStart: (KanjiLevel?) -> Void

    @State private var titleScale: CGFloat = 0.8
    @State private var monsterOffset: CGFloat = 20
    @State private var showStartButton = false
    @State private var blinkStart = false
    @State private var selectedLevel: KanjiLevel? = nil

    private var levelOrder: [KanjiLevel] {
        KanjiLevel.allCases.sorted { $0.rawValue > $1.rawValue }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            titleText

            Spacer().frame(height: 24)

            monsterShowcase

            Spacer().frame(height: 24)

            levelSelector

            Spacer().frame(height: 50)

            startButton

            Spacer()

            creditsText
        }
        .gbScreen()
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                titleScale = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                monsterOffset = -10
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
                showStartButton = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.0)) {
                blinkStart = true
            }
        }
    }

    private var titleText: some View {
        VStack(spacing: 8) {
            Text("KANJI")
                .pixelFont(36)
                .foregroundStyle(GBColor.lightest)

            Text("MONSTER")
                .pixelFont(36)
                .foregroundStyle(GBColor.light)

            Rectangle()
                .fill(GBColor.dark)
                .frame(width: 200, height: 2)
                .padding(.top, 4)

            Text("漢字モンスター")
                .pixelFont(14)
                .foregroundStyle(GBColor.dark)
        }
        .scaleEffect(titleScale)
    }

    private var levelSelector: some View {
        VStack(spacing: 6) {
            Text("LEVEL")
                .pixelFont(10)
                .foregroundStyle(GBColor.dark)

            HStack(spacing: 6) {
                ForEach(levelOrder, id: \.rawValue) { level in
                    Button {
                        if selectedLevel == level {
                            selectedLevel = nil
                        } else {
                            selectedLevel = level
                        }
                    } label: {
                        Text(level.displayName)
                            .pixelFont(12)
                            .frame(minWidth: 44)
                            .padding(.vertical, 6)
                            .background(selectedLevel == level ? GBColor.light : GBColor.darkest)
                            .foregroundStyle(selectedLevel == level ? GBColor.darkest : GBColor.light)
                            .pixelBorder(color: selectedLevel == level ? GBColor.lightest : GBColor.dark, width: 1)
                    }
                }
            }
        }
    }

    private var monsterShowcase: some View {
        HStack(spacing: 16) {
            ForEach([1, 9, 20], id: \.self) { monsterID in
                if let monster = MonsterData.allMonsters.first(where: { $0.id == monsterID }) {
                    MonsterSpriteView(monster: monster)
                        .offset(y: monsterOffset)
                }
            }
        }
    }

    private var startButton: some View {
        Group {
            if showStartButton {
                Button {
                    onStart(selectedLevel)
                } label: {
                    HStack(spacing: 8) {
                        Text("▶")
                        Text("START")
                    }
                }
                .buttonStyle(.pixel)
                .opacity(blinkStart ? 1.0 : 0.4)
            }
        }
    }

    private var creditsText: some View {
        VStack(spacing: 4) {
            Text("© 2026 KanjiMonster")
                .pixelFont(8)
                .foregroundStyle(GBColor.dark)

            if APIConfig.isAIEnabled {
                Text("Powered by Gemini AI")
                    .pixelFont(8)
                    .foregroundStyle(GBColor.dark)
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    TitleScreenView(onStart: { _ in })
}
