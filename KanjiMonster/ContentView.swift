//
//  ContentView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        Group {
            switch viewModel.phase {
            case .title:
                TitleScreenView(onStart: { selectedLevel in
                    viewModel.geminiService = APIConfig.createGeminiService()
                    viewModel.startGame(initialLevel: selectedLevel)
                })

            case .playing:
                GameView(viewModel: viewModel)

            case .result:
                ResultView(
                    score: viewModel.score,
                    defeatedCount: viewModel.defeatedCount,
                    highestLevel: viewModel.highestLevel,
                    streak: viewModel.streak,
                    onRetry: { viewModel.startGame() },
                    onTitle: { viewModel.returnToTitle() }
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.phase)
    }
}

#Preview {
    ContentView()
}
