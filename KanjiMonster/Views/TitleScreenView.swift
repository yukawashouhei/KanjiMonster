//
//  TitleScreenView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct TitleScreenView: View {
    let onStart: (KanjiLevel?) -> Void

    private static let monsterCount = 15
    private static let rotationInterval: TimeInterval = 15
    private static let slotWidth: CGFloat = 80
    private static let slotSpacing: CGFloat = 35
    private static let slotHeight: CGFloat = 110
    private static let showcaseHorizontalPadding: CGFloat = 16
    private static let slideDuration: TimeInterval = 0.5

    @State private var titleScale: CGFloat = 0.8
    @State private var showStartButton = false
    @State private var blinkStart = false
    @State private var selectedLevel: KanjiLevel? = nil

    /// 常に4体保持（左3体が表示中、4体目は右の画面外で待機）
    @State private var monsterQueue: [Int] = [0, 1, 2, 3]
    /// コンテナ全体のスライド量
    @State private var scrollOffset: CGFloat = 0
    /// スライド中かどうか（アニメーション制御用）
    @State private var isSliding = false

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
            withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
                showStartButton = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.0)) {
                blinkStart = true
            }
            startMonsterRotationTimer()
        }
    }

    private func startMonsterRotationTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: Self.rotationInterval, repeats: true) { _ in
            rotateMonsters()
        }
    }

    private func rotateMonsters() {
        let step = Self.slotWidth + Self.slotSpacing
        isSliding = true
        withAnimation(.easeInOut(duration: Self.slideDuration)) {
            scrollOffset = -step
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.slideDuration + 0.02) {
            isSliding = false
            let next = (monsterQueue.last! + 1) % Self.monsterCount
            monsterQueue.removeFirst()
            monsterQueue.append(next)
            scrollOffset = 0
        }
    }

    private var titleText: some View {
        VStack(spacing: 8) {
            Image("TitleKanjiMonster")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 88)
                .foregroundStyle(GBColor.lightest)

            Rectangle()
                .fill(GBColor.dark)
                .frame(width: 200, height: 2)
                .padding(.top, 4)

            Image("TitleKanjiMonsterJa")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 18)
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
        let visibleWidth = Self.slotWidth * 3 + Self.slotSpacing * 2 + Self.showcaseHorizontalPadding * 2
        return HStack(spacing: Self.slotSpacing) {
            ForEach(monsterQueue, id: \.self) { idx in
                let monster = MonsterData.allMonsters[idx]
                MonsterSpriteView(monster: monster)
                    .frame(width: Self.slotWidth, height: Self.slotHeight)
            }
        }
        .padding(.horizontal, Self.showcaseHorizontalPadding)
        .offset(x: scrollOffset)
        .animation(isSliding ? .easeInOut(duration: Self.slideDuration) : nil, value: scrollOffset)
        .frame(width: visibleWidth, height: Self.slotHeight, alignment: .leading)
        .clipped()
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
