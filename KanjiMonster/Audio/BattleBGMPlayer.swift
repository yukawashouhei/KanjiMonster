//
//  BattleBGMPlayer.swift
//  KanjiMonster
//
//  戦闘BGM: 4・5級用と1・2・3級用の2種類をレベルに応じて再生・切り替え
//

import AVFoundation
import Foundation

final class BattleBGMPlayer {

    private var player: AVAudioPlayer?
    /// 現在再生中のトラック（4_5 または 1_2_3）
    private var currentFileName: String?

    /// 戦闘BGMを再生（ループ）。4・5級＝4_5.mp3、1・2・3級＝1_2_3.mp3。既に同じトラックなら何もしない。
    func play(for level: KanjiLevel) {
        let fileName: String
        switch level {
        case .kyu5, .kyu4: fileName = "4_5"
        case .kyu3, .kyu2, .kyu1: fileName = "1_2_3"
        }
        if currentFileName == fileName, player?.isPlaying == true {
            return
        }
        stop()
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3", subdirectory: "Audio")
            ?? Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.prepareToPlay()
            newPlayer.play()
            player = newPlayer
            currentFileName = fileName
        } catch {
            // 再生失敗時は静かに無視（BGMは必須ではない）
        }
    }

    func stop() {
        player?.stop()
        player = nil
        currentFileName = nil
    }
}
