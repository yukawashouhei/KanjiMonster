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

    func startGame(initialLevel: KanjiLevel? = nil) {
        phase = .playing
        let startLevel = initialLevel ?? LastPlayedLevelStorage.load() ?? .kyu5
        currentLevel = startLevel
        highestLevel = startLevel
        playerHP = maxHP
        streak = 0
        score = 0
        monsterHitCount = 0
        defeatedCount = 0
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
        LastPlayedLevelStorage.save(currentLevel)
        phase = .title
        stopTimer()
    }

    // MARK: - Battle Logic

    private func handleCorrect() {
        streak += 1
        monsterHitCount += 1
        score += 10 * currentLevel.scoreMultiplier

        if monsterHitCount >= 3 {
            generateMonsterDefeatDialogue()
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
                    scene: "攻撃した",
                    level: currentLevel
                )
                await MainActor.run {
                    self.monsterDialogue = dialogue
                }
            }
        } else {
            monsterDialogue = Self.localAttackDialogue(for: currentLevel)
        }
    }

    func generateMonsterDefeatDialogue() {
        if let service = geminiService {
            Task {
                let dialogue = await service.generateMonsterDialogue(
                    monsterName: currentMonster.name,
                    scene: "倒された",
                    level: currentLevel
                )
                await MainActor.run {
                    self.monsterDialogue = dialogue
                }
            }
        } else {
            monsterDialogue = Self.localDefeatDialogue(for: currentLevel)
        }
    }

    private static func localAttackDialogue(for level: KanjiLevel) -> String {
        let fallbacks: [String]
        switch level {
        case .kyu5:
            fallbacks = [
                "ウガー！", "グオォ！", "グルル…", "グゥ！", "ウォォ！",
                "ガオ！", "グルル！", "ウウ！", "ンガ！"
            ]
        case .kyu4:
            fallbacks = [
                "グルルル...！", "甘い！", "ウォ！", "グヌ！", "ガル！",
                "うぐっ！", "ぐお！", "まだまだ！", "ふん！"
            ]
        case .kyu3:
            fallbacks = [
                "甘いぞ！", "まだまだだな！", "ハハハ！",
                "弱い弱い！", "その程度か！", "かかってこい！",
                "ふざけるな！", "舐めてんのか！", "楽勝だ！"
            ]
        case .kyu2:
            fallbacks = [
                "甘いぞ、人間！", "許さぬ。", "神の怒りだ。",
                "裁きを下す。", "愚か者め。", "消えよ、凡人。",
                "ひれ伏せ。", "消滅せよ。", "舐めるな！"
            ]
        case .kyu1:
            fallbacks = [
                "愚かな者よ。", "我の前にひれ伏せ。", "裁きの時だ。",
                "消えろ、虫けら。", "神の裁きだ。", "許しは請わぬ。",
                "跪け。", "地の底に堕ちよ。", "我が怒りを味わえ。"
            ]
        }
        return fallbacks.randomElement()!
    }

    private static func localDefeatDialogue(for level: KanjiLevel) -> String {
        let fallbacks: [String]
        switch level {
        case .kyu5:
            fallbacks = [
                "ウガ…", "グオ…", "……", "グヌ…", "ウウ…",
                "ガ…", "グゥ…", "……", "ン…"
            ]
        case .kyu4:
            fallbacks = [
                "ぐふ…", "やられた…", "うう…", "ぐぬ…", "うぐ…",
                "くっ…", "あう…", "んぐ…", "うっ…"
            ]
        case .kyu3:
            fallbacks = [
                "ぐふっ...やるな...", "覚えておけ...！", "まさか...",
                "くっ...負けた...", "次は...負けん...！", "やるじゃねえか...",
                "ひどい...！", "くやしい...！", "おぼえてろ...！"
            ]
        case .kyu2:
            fallbacks = [
                "覚えておけ...！", "まさか...負けるとは...", "次は負けんぞ...！",
                "くっ...甘く見た...", "おのれ...！", "まだ終わってない...！",
                "許さぬ...必ず...", "我が...退く...？", "次は...裁きだ..."
            ]
        case .kyu1:
            fallbacks = [
                "神が...負ける...？", "許す...覚悟せよ...", "ふっ...興が乗った...",
                "愚かだが...認めよう。", "我を...退かせたか...", "面白い...次は本気だ。",
                "裁きは...後日に...", "呪いを...受けよ...", "見事だ。認めよう。"
            ]
        }
        return fallbacks.randomElement()!
    }
}
