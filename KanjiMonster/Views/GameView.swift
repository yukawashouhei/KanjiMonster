//
//  GameView.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI

struct GameView: View {
    @Bindable var viewModel: GameViewModel

    @State private var shakeOffset: CGFloat = 0
    @State private var flashOpacity: Double = 0
    @State private var bgmPlayer = BattleBGMPlayer()
    @AppStorage(BGMEnabledStorage.key) private var bgmEnabled: Bool = true

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                statusBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Spacer().frame(height: 16)

                monsterArea

                Spacer().frame(height: 12)

                kanjiArea

                Spacer().frame(height: 12)

                timerArea
                    .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                inputArea
                    .padding(.horizontal, 16)

                Spacer().frame(height: 8)

                hintArea
                    .padding(.horizontal, 16)

                Spacer()
            }

            effectOverlay

            flashOverlay
        }
        .gbScreen()
        .offset(x: shakeOffset)
        .onAppear {
            if bgmEnabled { bgmPlayer.play(for: viewModel.currentLevel) }
            else { bgmPlayer.stop() }
        }
        .onDisappear {
            bgmPlayer.stop()
        }
        .onChange(of: viewModel.currentLevel) { _, newLevel in
            if bgmEnabled { bgmPlayer.play(for: newLevel) }
            else { bgmPlayer.stop() }
        }
        .onChange(of: bgmEnabled) { _, enabled in
            if enabled { bgmPlayer.play(for: viewModel.currentLevel) }
            else { bgmPlayer.stop() }
        }
        .onChange(of: viewModel.battleEvent) { _, newEvent in
            handleBattleEvent(newEvent)
        }
    }

    // MARK: - Status Bar

    private var statusBar: some View {
        HStack {
            Button {
                viewModel.returnToTitle()
            } label: {
                Text("←")
                    .pixelFont(14)
                    .frame(width: 36, height: 32)
                    .background(GBColor.dark)
                    .foregroundStyle(GBColor.lightest)
                    .pixelBorder(color: GBColor.light, width: 1)
            }

            Text(viewModel.currentLevel.displayName)
                .pixelFont(14)
                .foregroundStyle(GBColor.lightest)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .pixelBorder(color: GBColor.light, width: 1)

            Spacer()

            HPBarView(currentHP: viewModel.playerHP, maxHP: viewModel.maxHP)

            Spacer()

            streakIndicator

            Button {
                bgmEnabled.toggle()
            } label: {
                Image(systemName: bgmEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(bgmEnabled ? GBColor.lightest : GBColor.dark)
                    .frame(width: 36, height: 32)
                    .background(GBColor.dark)
                    .pixelBorder(color: GBColor.light, width: 1)
            }
            .buttonStyle(.plain)
        }
    }

    private var streakIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Rectangle()
                    .fill(index < viewModel.streak ? GBColor.lightest : GBColor.dark)
                    .frame(width: 8, height: 12)
                    .pixelBorder(color: GBColor.light, width: 1)
            }
        }
    }

    // MARK: - Monster Area

    private var monsterArea: some View {
        VStack(spacing: 6) {
            MonsterSpriteView(
                monster: viewModel.currentMonster,
                isHit: viewModel.battleEvent == .correct,
                isDefeated: viewModel.battleEvent == .monsterDefeated
            )
            .frame(height: 120)

            if let dialogue = viewModel.monsterDialogue {
                Text("「\(dialogue)」")
                    .pixelFont(10)
                    .foregroundStyle(GBColor.light)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(GBColor.darkest.opacity(0.8))
                    .pixelBorder(color: GBColor.dark, width: 1)
            }
        }
    }

    // MARK: - Kanji Area

    private var kanjiArea: some View {
        KanjiDisplayView(
            kanji: viewModel.currentKanji.kanji,
            hitCount: viewModel.monsterHitCount
        )
    }

    // MARK: - Timer

    private var timerArea: some View {
        TimerBarView(timeRemaining: viewModel.timeRemaining)
    }

    // MARK: - Input

    private var inputArea: some View {
        AnswerInputView(
            text: $viewModel.answerText,
            isEnabled: viewModel.isTimerRunning,
            onSubmit: { viewModel.submitAnswer() }
        )
    }

    // MARK: - Hint

    private var hintArea: some View {
        HintView(
            hintText: viewModel.hintText,
            isLoading: viewModel.isLoadingHint,
            onRequestHint: { viewModel.requestHint() }
        )
    }

    // MARK: - Effects

    private var effectOverlay: some View {
        VStack {
            Spacer()
            BattleEffectView(
                event: viewModel.battleEvent,
                correctReading: viewModel.currentKanji.readings.first ?? ""
            )
            Spacer()
        }
    }

    private var flashOverlay: some View {
        Rectangle()
            .fill(GBColor.lightest)
            .opacity(flashOpacity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    private func handleBattleEvent(_ event: BattleEvent) {
        switch event {
        case .correct, .monsterDefeated, .gameCleared:
            withAnimation(.easeOut(duration: 0.1)) { flashOpacity = 0.4 }
            withAnimation(.easeIn(duration: 0.3).delay(0.1)) { flashOpacity = 0 }

        case .wrong:
            shakeScreen()

        case .levelUp:
            withAnimation(.easeOut(duration: 0.15)) { flashOpacity = 0.6 }
            withAnimation(.easeIn(duration: 0.4).delay(0.15)) { flashOpacity = 0 }

        case .levelDown, .none:
            break
        }
    }

    private func shakeScreen() {
        let duration = 0.06
        withAnimation(.linear(duration: duration)) { shakeOffset = 8 }
        withAnimation(.linear(duration: duration).delay(duration)) { shakeOffset = -8 }
        withAnimation(.linear(duration: duration).delay(duration * 2)) { shakeOffset = 6 }
        withAnimation(.linear(duration: duration).delay(duration * 3)) { shakeOffset = -6 }
        withAnimation(.linear(duration: duration).delay(duration * 4)) { shakeOffset = 0 }
    }
}

#Preview {
    let vm = GameViewModel()
    GameView(viewModel: vm)
        .onAppear { vm.startGame() }
}
