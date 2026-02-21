//
//  ResultView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let defeatedCount: Int
    let highestLevel: KanjiLevel
    let streak: Int
    let onRetry: () -> Void
    let onTitle: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            headerText

            Spacer().frame(height: 30)

            if showContent {
                statsBox

                Spacer().frame(height: 30)

                buttons
            }

            Spacer()
        }
        .gbScreen()
        .onAppear {
            withAnimation(.easeIn(duration: 0.6).delay(0.5)) {
                showContent = true
            }
        }
    }

    private var headerText: some View {
        VStack(spacing: 8) {
            Text(isCleared ? "GAME CLEAR!" : "GAME OVER")
                .pixelFont(28)
                .foregroundStyle(isCleared ? GBColor.lightest : GBColor.dark)

            Rectangle()
                .fill(GBColor.dark)
                .frame(width: 180, height: 2)
        }
    }

    private var statsBox: some View {
        VStack(spacing: 12) {
            statRow(label: "SCORE", value: "\(score)")
            statRow(label: "DEFEATED", value: "\(defeatedCount)")
            statRow(label: "HIGHEST", value: highestLevel.displayName)
            statRow(label: "STREAK", value: "\(streak)")
        }
        .padding(16)
        .pixelBorder(color: GBColor.light, width: 2)
        .padding(.horizontal, 40)
        .transition(.opacity)
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .pixelFont(12)
                .foregroundStyle(GBColor.light)
            Spacer()
            Text(value)
                .pixelFont(14)
                .foregroundStyle(GBColor.lightest)
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            Button("▶ RETRY", action: onRetry)
                .buttonStyle(.pixel)

            Button("◀ TITLE", action: onTitle)
                .buttonStyle(.pixel)
        }
        .transition(.opacity)
    }

    private var isCleared: Bool {
        streak >= 5
    }
}

#Preview("Clear") {
    ResultView(
        score: 150,
        defeatedCount: 3,
        highestLevel: .kyu3,
        streak: 5,
        onRetry: {},
        onTitle: {}
    )
}

#Preview("Game Over") {
    ResultView(
        score: 40,
        defeatedCount: 1,
        highestLevel: .kyu4,
        streak: 2,
        onRetry: {},
        onTitle: {}
    )
}
