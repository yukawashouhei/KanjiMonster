//
//  GeminiService.swift
//  KanjiMonster
//
//  Created by 湯川昇平 on 2026/02/21.
//

import Foundation

actor GeminiService {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Hint Generation

    func generateHint(for kanji: KanjiQuestion) async -> String {
        let prompt = """
        あなたは漢字クイズゲームのヒント係です。
        漢字「\(kanji.kanji)」の読み方のヒントを出してください。
        - 成り立ちや覚え方を含めて1-2文で
        - 答え（読み）自体は絶対に言わないで
        - ゲームボーイ風のレトロなゲームのキャラクターっぽい口調で
        """

        let result = await callGemini(prompt: prompt)
        return result ?? "\(kanji.hint)\n最初の文字: \(String(kanji.readings[0].prefix(1)))..."
    }

    // MARK: - Monster Dialogue

    func generateMonsterDialogue(monsterName: String, scene: String, level: KanjiLevel) async -> String {
        let levelHint: String
        switch level {
        case .kyu5:
            levelHint = "知能は低く、鳴き声や叫び・うなりに近い短いセリフにしてください。言葉らしい言葉はほとんど話さない感じで。"
        case .kyu4:
            levelHint = "やや単純な口調。短い叫びや、ごく短い言葉にしてください。"
        case .kyu3:
            levelHint = "中程度の知能。短い挑発や一言にしてください。"
        case .kyu2:
            levelHint = "知能は高め。邪神に近い、やや複雑な挑発や言い回しにしてください。"
        case .kyu1:
            levelHint = "知能は最も高く、邪神や神のような存在が話しかけている口調で、威厳や畏怖を感じさせる短いセリフにしてください。"
        }
        let prompt = """
        あなたは「\(monsterName)」という名前のドット絵モンスターです。
        \(scene)時のセリフを1文だけ言ってください。
        - ゲームボーイ風のレトロRPGのモンスターらしい口調で
        - 15文字以内で短く
        - \(levelHint)
        """

        let result = await callGemini(prompt: prompt)
        return result ?? defaultDialogue(for: scene, level: level)
    }

    // MARK: - API Call

    private func callGemini(prompt: String) async -> String? {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else { return nil }

        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "maxOutputTokens": 100,
                "temperature": 0.8
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            return nil
        }

        return nil
    }

    private func defaultDialogue(for scene: String, level: KanjiLevel) -> String {
        let isDefeated = scene.contains("倒された")
        if isDefeated {
            switch level {
            case .kyu5:
                return [
                    "ウガ…", "グオ…", "……", "グヌ…", "ウウ…",
                    "ガ…", "グゥ…", "……", "ン…"
                ].randomElement()!
            case .kyu4:
                return [
                    "ぐふ…", "やられた…", "うう…", "ぐぬ…", "うぐ…",
                    "くっ…", "あう…", "んぐ…", "うっ…"
                ].randomElement()!
            case .kyu3:
                return [
                    "ぐふっ...やるな...", "覚えておけ...！", "まさか...",
                    "くっ...負けた...", "次は...負けん...！", "やるじゃねえか...",
                    "ひどい...！", "くやしい...！", "おぼえてろ...！"
                ].randomElement()!
            case .kyu2:
                return [
                    "覚えておけ...！", "まさか...負けるとは...", "次は負けんぞ...！",
                    "くっ...甘く見た...", "おのれ...！", "まだ終わってない...！",
                    "許さぬ...必ず...", "我が...退く...？", "次は...裁きだ..."
                ].randomElement()!
            case .kyu1:
                return [
                    "神が...負ける...？", "許す...覚悟せよ...", "ふっ...興が乗った...",
                    "愚かだが...認めよう。", "我を...退かせたか...", "面白い...次は本気だ。",
                    "裁きは...後日に...", "呪いを...受けよ...", "見事だ。認めよう。"
                ].randomElement()!
            }
        } else {
            switch level {
            case .kyu5:
                return [
                    "ウガー！", "グオォ！", "グルル…", "グゥ！", "ウォォ！",
                    "ガオ！", "グルル！", "ウウ！", "ンガ！"
                ].randomElement()!
            case .kyu4:
                return [
                    "グルルル...！", "甘い！", "ウォ！", "グヌ！", "ガル！",
                    "うぐっ！", "ぐお！", "まだまだ！", "ふん！"
                ].randomElement()!
            case .kyu3:
                return [
                    "甘いぞ！", "まだまだだな！", "ハハハ！",
                    "弱い弱い！", "その程度か！", "かかってこい！",
                    "ふざけるな！", "舐めてんのか！", "楽勝だ！"
                ].randomElement()!
            case .kyu2:
                return [
                    "甘いぞ、人間！", "許さぬ。", "神の怒りだ。",
                    "裁きを下す。", "愚か者め。", "消えよ、凡人。",
                    "ひれ伏せ。", "消滅せよ。", "舐めるな！"
                ].randomElement()!
            case .kyu1:
                return [
                    "愚かな者よ。", "我の前にひれ伏せ。", "裁きの時だ。",
                    "消えろ、虫けら。", "神の裁きだ。", "許しは請わぬ。",
                    "跪け。", "地の底に堕ちよ。", "我が怒りを味わえ。"
                ].randomElement()!
            }
        }
    }
}
