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

    func generateMonsterDialogue(monsterName: String, scene: String) async -> String {
        let prompt = """
        あなたは「\(monsterName)」という名前のドット絵モンスターです。
        \(scene)時のセリフを1文だけ言ってください。
        - ゲームボーイ風のレトロRPGのモンスターらしい口調で
        - 15文字以内で短く
        """

        let result = await callGemini(prompt: prompt)
        return result ?? defaultDialogue(for: scene)
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

    private func defaultDialogue(for scene: String) -> String {
        if scene.contains("倒された") {
            return ["ぐふっ...やるな...", "覚えておけ...！", "まさか...負けるとは..."].randomElement()!
        } else {
            return ["グルルル...！", "甘いぞ！", "まだまだだな！"].randomElement()!
        }
    }
}
