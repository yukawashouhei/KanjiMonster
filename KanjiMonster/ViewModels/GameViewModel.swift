//
//  GameViewModel.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import SwiftUI
import Observation

enum GamePhase: Equatable {
    case title
    case playing
    case result
}

enum BattleEvent: Equatable {
    case none
    case correct
    case wrong
    case monsterDefeated
    case levelUp(KanjiLevel)
    case levelDown(KanjiLevel)
    case gameCleared
}

@Observable
final class GameViewModel {

    // MARK: - Game State

    var phase: GamePhase = .title
    var currentLevel: KanjiLevel = .kyu5
    var playerHP: Int = 3
    let maxHP: Int = 3
    var streak: Int = 0
    var score: Int = 0
    var monsterHitCount: Int = 0
    var defeatedCount: Int = 0
    var highestLevel: KanjiLevel = .kyu5

    // MARK: - Current Battle

    var currentMonster: Monster = MonsterData.allMonsters[0]
    var currentKanji: KanjiQuestion = KanjiData.kyu5[0]
    var answerText: String = ""
    var timeRemaining: Double = 10.0
    var isTimerRunning: Bool = false
    var battleEvent: BattleEvent = .none

    // MARK: - AI Features

    var hintText: String? = nil
    var monsterDialogue: String? = nil
    var isLoadingHint: Bool = false
    var geminiService: GeminiService? = nil

    // MARK: - Timer

    private var timer: Timer?
    private var usedKanjiIDs: Set<UUID> = []
    private let timerInterval: Double = 0.05

    // MARK: - Game Flow

    func startGame() {
        phase = .playing
        currentLevel = .kyu5
        playerHP = maxHP
        streak = 0
        score = 0
        monsterHitCount = 0
        defeatedCount = 0
        highestLevel = .kyu5
        usedKanjiIDs = []
        battleEvent = .none
        hintText = nil
        monsterDialogue = nil

        spawnMonster()
    }

    func submitAnswer() {
        guard isTimerRunning else { return }
        let answer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else { return }

        stopTimer()

        if currentKanji.isCorrect(answer) {
            handleCorrect()
        } else {
            handleWrong()
        }

        answerText = ""
    }

    func returnToTitle() {
        phase = .title
        stopTimer()
    }

    // MARK: - Battle Logic

    private func handleCorrect() {
        streak += 1
        monsterHitCount += 1
        score += 10 * currentLevel.scoreMultiplier

        if monsterHitCount >= 3 {
            battleEvent = .monsterDefeated
            defeatedCount += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.afterMonsterDefeated()
            }
        } else if streak >= 5 {
            battleEvent = .gameCleared
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.phase = .result
            }
        } else {
            battleEvent = .correct
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.nextQuestion()
            }
        }
    }

    private func afterMonsterDefeated() {
        if streak >= 5 {
            battleEvent = .gameCleared
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.phase = .result
            }
            return
        }

        if let nextLevel = currentLevel.next {
            currentLevel = nextLevel
            if nextLevel > highestLevel {
                highestLevel = nextLevel
            }
            battleEvent = .levelUp(nextLevel)
        }

        monsterHitCount = 0
        hintText = nil
        monsterDialogue = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.spawnMonster()
        }
    }

    private func handleWrong() {
        streak = 0
        playerHP -= 1
        battleEvent = .wrong

        generateMonsterAttackDialogue()

        if playerHP <= 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.handlePlayerDefeated()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.nextQuestion()
            }
        }
    }

    private func handlePlayerDefeated() {
        if let prevLevel = currentLevel.previous {
            currentLevel = prevLevel
            battleEvent = .levelDown(prevLevel)
        }

        playerHP = maxHP
        monsterHitCount = 0
        hintText = nil
        monsterDialogue = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.spawnMonster()
        }
    }

    // MARK: - Monster & Kanji Management

    private func spawnMonster() {
        currentMonster = MonsterData.randomMonster(for: currentLevel)
        monsterHitCount = 0
        monsterDialogue = nil
        nextQuestion()
    }

    private func nextQuestion() {
        battleEvent = .none
        hintText = nil

        let pool = KanjiData.questions(for: currentLevel)
            .filter { !usedKanjiIDs.contains($0.id) }

        if pool.isEmpty {
            usedKanjiIDs = []
            currentKanji = KanjiData.questions(for: currentLevel).randomElement()
                ?? KanjiData.kyu5[0]
        } else {
            currentKanji = pool.randomElement() ?? KanjiData.kyu5[0]
        }

        usedKanjiIDs.insert(currentKanji.id)
        timeRemaining = 10.0
        startTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        isTimerRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.timeRemaining -= self.timerInterval
            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                self.stopTimer()
                self.handleWrong()
            }
        }
    }

    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    // MARK: - AI Features (Optional)

    func requestHint() {
        guard hintText == nil else { return }

        if let service = geminiService {
            isLoadingHint = true
            Task {
                let hint = await service.generateHint(for: currentKanji)
                await MainActor.run {
                    self.hintText = hint
                    self.isLoadingHint = false
                }
            }
        } else {
            let reading = currentKanji.readings[0]
            let firstChar = String(reading.prefix(1))
            hintText = "\(currentKanji.hint)\n最初の文字: \(firstChar)..."
        }
    }

    private func generateMonsterAttackDialogue() {
        if let service = geminiService {
            Task {
                let dialogue = await service.generateMonsterDialogue(
                    monsterName: currentMonster.name,
                    scene: "攻撃した"
                )
                await MainActor.run {
                    self.monsterDialogue = dialogue
                }
            }
        } else {
            let fallbacks = [
                "グルルル...！",
                "まだまだだな！",
                "甘いぞ、人間！",
                "ハハハ！弱い！",
                "もう一度来い！",
            ]
            monsterDialogue = fallbacks.randomElement()
        }
    }

    func generateMonsterDefeatDialogue() {
        if let service = geminiService {
            Task {
                let dialogue = await service.generateMonsterDialogue(
                    monsterName: currentMonster.name,
                    scene: "倒された"
                )
                await MainActor.run {
                    self.monsterDialogue = dialogue
                }
            }
        } else {
            let fallbacks = [
                "ぐふっ...やるな...",
                "覚えておけ...！",
                "まさか...負けるとは...",
                "次は負けんぞ...！",
            ]
            monsterDialogue = fallbacks.randomElement()
        }
    }
}
